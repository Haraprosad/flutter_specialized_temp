# Guide 11 — Local Storage

Complete guide to the persistence layer in `lib/core/storage/`. This is where the app stores **durable key-value data** that must survive app restarts: auth tokens, the logged-in user's id/email/role, and user preferences like theme and language.

**The golden rule: sensitive data goes in `SecureStorageManager`, everything else in `PreferencesManager`. Always reach both through the `AppStorage` facade, injected by constructor.**

> Don't confuse this with [`MemoryManagementService`](../lib/core/services/memory_management_service.dart) (RAM / image-cache pressure) or the SWR network cache in `docs/08_NETWORK.md` (in-memory, not durable). Those are runtime memory; this guide is about data written to disk.

---

## Architecture overview

```
lib/core/storage/
├── app_storage.dart            # AppStorage — unified facade (inject this)
├── secure_storage_manager.dart # SecureStorageManager — encrypted (flutter_secure_storage)
├── preferences_manager.dart    # PreferencesManager — plaintext (SharedPreferences)
└── storage_keys.dart           # StorageKeys — every key string lives here, nowhere else
```

`AppStorage` is a `@lazySingleton` that composes the two managers and exposes them:

```dart
@lazySingleton
class AppStorage {
  AppStorage(this._secureStorage, this._preferences);

  SecureStorageManager get secure => _secureStorage;
  PreferencesManager get preferences => _preferences;

  Future<void> clearAllData() async {
    await _secureStorage.deleteAllSecureData();
    await _preferences.clearAll();
  }
}
```

Both underlying clients are registered in [`lib/core/di/register_module.dart`](../lib/core/di/register_module.dart):
`SharedPreferences.getInstance()` is `@preResolve`d (it's async), and `FlutterSecureStorage` is configured with a `securePrefs` namespace and `secure_` key prefix.

---

## Which manager do I use?

| Data | Sensitive? | Manager | Key |
|---|---|---|---|
| Access token, refresh token | **Yes** | `secure` | `authToken`, `refreshToken` |
| User PIN, biometric-enabled flag | **Yes** | `secure` | `userPin`, `biometricEnabled` |
| User id / login id | No | `preferences` | `userId` |
| User email, name, role | No | `preferences` | `userEmail`, `userName`, `userRole` |
| `isAuthenticated` flag | No | `preferences` | `isAuthenticated` |
| Theme (dark mode), language, font size, notifications | No | `preferences` | `isDarkMode`, `language`, … |

**Decision rule:** if leaking the value would harm the user (credentials, tokens, PINs) → `secure`. If it's a convenience/UX value (preferences, non-secret identifiers, flags) → `preferences`. SharedPreferences is **plaintext on disk** — never put a token or secret there.

---

## Tokens & login — the auth path

This is the case in the question: *"for token or login id … we can store using storage, right?"* — yes.

**Save tokens after login** (encrypted). There's a purpose-built pair so you don't hand-write keys:

```dart
await appStorage.secure.saveAuthTokens(
  accessToken: response.accessToken,
  refreshToken: response.refreshToken,
);

final tokens = await appStorage.secure.getAuthTokens();
// { 'accessToken': ..., 'refreshToken': ... }
```

**Save the login id / profile** (non-sensitive, fast synchronous reads):

```dart
await appStorage.preferences.setUserId(user.id);
await appStorage.preferences.setUserEmail(user.email);
await appStorage.preferences.setUserRole(user.role);
await appStorage.preferences.setIsAuthenticated(isAuthenticated: true);
```

**The token is read for you on every request.** [`AuthInterceptor`](../lib/core/network/config/interceptors/auth_interceptor.dart) reads `StorageKeys.authToken` from `SecureStorageManager` and injects `Authorization: Bearer <token>` — on every call, so a freshly-refreshed token is always picked up. Public paths (`/auth/login`, `/auth/register`, `/auth/refresh`) are skipped. You do **not** add the header yourself.

**Logout** clears everything in one call:

```dart
await appStorage.clearAllData(); // wipes secure + preferences
```

---

## Usage rules

1. **Inject `AppStorage` (or a specific manager) by constructor — never `sl<AppStorage>()`** inside a repository/datasource/BLoC. This is Non-Negotiable #3.

   ```dart
   @LazySingleton(as: AuthLocalDataSource)
   class AuthLocalDataSourceImpl implements AuthLocalDataSource {
     AuthLocalDataSourceImpl(this._storage);
     final AppStorage _storage;
   }
   ```

2. **Storage belongs in the `data` layer** — typically a `*LocalDataSource`. Domain entities and use cases never touch `AppStorage` directly; they go through a repository.

3. **Every key is a `StorageKeys` constant.** Never pass a raw `'authToken'` string into `read`/`write`. Add new keys to [`storage_keys.dart`](../lib/core/storage/storage_keys.dart) and group them by sensitivity (the file already separates "secure" vs "non-sensitive" sections).

4. **Wrap nothing in try/catch at the call site for control flow.** Both managers already throw `SecureStorageException` / `PreferencesException` (see `lib/core/exceptions/storage_exception.dart`). Let the repository convert failures into the app's error type, the same way network errors are handled.

5. **Reads from `PreferencesManager` are synchronous** (`getUserId()` returns `String?` directly); **secure reads are async** (`Future<String?>`). Plan your data flow accordingly.

---

## Adding a new stored value — checklist

- [ ] Decide sensitivity → `secure` (encrypted) or `preferences` (plaintext).
- [ ] Add the key to `StorageKeys` in the correct section.
- [ ] Add a typed getter/setter to the relevant manager (mirror the existing `setUserId`/`getUserId` style) rather than scattering raw `read`/`write` calls.
- [ ] Access it from a `data`-layer datasource via injected `AppStorage`.
- [ ] If it must be cleared on logout, confirm `clearAllData()` covers it (it clears *all* keys in both stores).
