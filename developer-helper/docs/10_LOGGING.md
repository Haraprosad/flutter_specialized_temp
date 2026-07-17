# Guide 10 — Logging

Complete guide to the logging facility in `lib/core/logger/`. **Every diagnostic message in this app goes through `AppLogger`** — never a raw `print()` or `debugPrint()`. `AppLogger` is a thin, Sentry-aware wrapper around the [`logger`](https://pub.dev/packages/logger) package that does the right thing in each build mode automatically: pretty console output in debug, silent-but-reported crash signal in release.

---

## Why a wrapper, not raw `print`

`print()` ships to production, has no severity, no formatting, and never reaches your crash dashboard. `AppLogger` gives you:

- **One call site, two behaviors.** In debug it prints a formatted, timestamped line. In release the low-severity levels go silent and the high-severity ones forward to **Sentry** with stack trace and metadata.
- **Severity that means something.** The level you pick decides whether a message is dev-only noise or a production incident.
- **No leak risk.** Verbose `d`/`i` logging is compiled out of release behavior — it never runs in production, so debugging breadcrumbs can't leak to the console or cost performance.

---

## Architecture overview

```
lib/core/logger/
└── app_logger.dart        # AppLogger — static facade over `logger` + Sentry
```

`AppLogger` is a singleton facade exposing five static methods, one per severity. It holds a single configured `Logger`:

```dart
static final Logger _logger = Logger(
  printer: PrettyPrinter(dateTimeFormat: DateTimeFormat.dateAndTime),
  level: kDebugMode ? Level.trace : Level.error,
);
```

Two things to note:
- The printer is `PrettyPrinter` with date+time, so every debug line is timestamped and boxed.
- The package-level `level` is `trace` in debug and `error` in release — a second guard on top of the `kDebugMode` checks inside each method.

### How it connects to the rest of the app

Logging is wired into the app's global error spine in [`lib/flavors/app_initializer.dart`](../lib/flavors/app_initializer.dart):

| Hook | Method used | Catches |
|---|---|---|
| `runZonedGuarded` | `AppLogger.f` | Unhandled async errors |
| `FlutterError.onError` | `AppLogger.f` | Widget tree / framework errors |
| `PlatformDispatcher.instance.onError` | `AppLogger.e` | Native platform errors |
| `AppBlocObserver.onError` | `AppLogger.e` | Errors thrown inside any BLoC |

Sentry itself is initialized in the same file from the `SENTRY_DSN` env value. When the DSN is empty (development), Sentry runs as a no-op, so the forwarding path is harmless. See [Guide 6 — Deployment](06_DEPLOYMENT.md) for the flavor/Sentry/logging matrix.

---

## The five levels (and when forwarding happens)

| Method | Level | Console (debug) | Forwards to Sentry (release) | Use for |
|---|---|---|---|---|
| `AppLogger.d` | debug | ✅ | ❌ | Verbose tracing, cache hits/misses, flow breadcrumbs |
| `AppLogger.i` | info | ✅ | ❌ | Lifecycle milestones, "service started", successful batches |
| `AppLogger.w` | warning | ✅ | ✅ | Recoverable problems — retry, stale cache served, token missing |
| `AppLogger.e` | error | ✅ | ✅ | Failures that broke an operation but not the app |
| `AppLogger.f` | fatal | ✅ | ✅ | Crashes / unrecoverable state (used by the global error spine) |

**The rule of thumb:** `d` and `i` are *dev-only breadcrumbs* — they never reach production. `w`, `e`, and `f` are *signals you'd want to see in Sentry* — they always forward in release. Choose the level by asking "would I want a Sentry event for this in production?"

---

## API

Every method takes a required named `message`. The three forwarding levels (`w`, `e`, `f`) also take an optional `metadata` map that becomes Sentry tags.

```dart
// Breadcrumb — debug console only.
AppLogger.d(message: '🎯 Cache HIT (Memory): $key');

// Milestone — debug console only.
AppLogger.i(message: '✅ Dependencies configured successfully');

// Recoverable problem — console in debug, Sentry warning in release.
AppLogger.w(message: '🔄 Returning stale cache due to network error');

// Failure with the original error + stack — Sentry error in release.
AppLogger.e(
  message: '❌ API error loading posts: ${e.message}',
  error: e,
  stackTrace: stackTrace,
);

// Crash with extra context tags on the Sentry event.
AppLogger.f(
  message: 'runZonedGuarded caught error',
  error: exception,
  stackTrace: stackTrace,
  metadata: {'feature': 'checkout', 'orderId': orderId},
);
```

Signatures:

```dart
AppLogger.d({required String message, dynamic error, StackTrace? stackTrace});
AppLogger.i({required String message, dynamic error, StackTrace? stackTrace});
AppLogger.w({required String message, dynamic error, StackTrace? stackTrace, Map<String, dynamic>? metadata});
AppLogger.e({required String message, dynamic error, StackTrace? stackTrace, Map<String, dynamic>? metadata});
AppLogger.f({required String message, dynamic error, StackTrace? stackTrace, Map<String, dynamic>? metadata});
```

When you have the caught error and its stack, **always pass both `error:` and `stackTrace:`** — they are what make a Sentry event actionable. The `error` becomes the captured exception; `message` becomes a Sentry hint; each `metadata` entry becomes a searchable tag.

---

## Where to log (by layer)

Logging is a cross-cutting concern, but it lives mostly in `core/` and the data layer — not in widgets or use cases doing pure logic.

| Layer | Log? | What |
|---|---|---|
| **Datasource** | ✅ | API call start/result, parse errors, cache decisions (`d`/`e`) |
| **Repository** | ✅ | Already done for you by `BaseApiRepository` / `ScalableBaseRepository` — `safeApiCall` logs success (`d`) and failure (`e`). Don't double-log. |
| **Use case** | sparingly | Only meaningful flow milestones; most use cases need none |
| **BLoC** | sparingly | Lifecycle / notable transitions. Routine state changes are already traced by `AppBlocObserver`. |
| **Widget / UI** | ❌ | Never. UI emits no diagnostics. |

Because the network stack (`safeApiCall`, interceptors, cache manager, mutation queue, connection manager) already logs richly, most feature code needs very little logging of its own. See [Guide 8 — Network](08_NETWORK.md).

---

## Conventions

- **Pick the level honestly.** A swallowed exception that the user never notices is a `w`, not a `d`. A failed save is an `e`. Don't downgrade real problems to hide them from Sentry.
- **Message is for humans.** Lead with what happened, include the key identifier (`cacheKey`, `start=`, `orderId`). Emoji prefixes are used throughout the template for fast visual scanning — match the existing style if you add logs near them.
- **Never log secrets or PII.** No tokens, passwords, full auth headers, or personal data — release `w`/`e`/`f` lines go to Sentry. `sendDefaultPii` is `false` by design; keep it that way in your messages and metadata.
- **Don't log and rethrow at every layer.** Log once, at the layer that actually decides the outcome (usually the repository/datasource boundary). Re-logging the same error on the way up just creates duplicate Sentry events.
- **No `print` / `debugPrint` in committed code.** They're auto-stripped from the deployment checklist's perspective only because we don't use them — use `AppLogger`.

---

## Anti-patterns

```dart
// ❌ Raw print — no severity, ships to production, never reaches Sentry.
print('user $id failed to load');

// ❌ Logging an error as debug — hides a real failure from production monitoring.
AppLogger.d(message: 'save failed: $e');

// ❌ Forwarding error without the stack trace — Sentry event is unactionable.
AppLogger.e(message: 'save failed: $e');

// ❌ Logging secrets — leaks to Sentry in release.
AppLogger.w(message: 'auth failed with token $accessToken');

// ✅ Right: correct level, error + stack, no secrets.
AppLogger.e(
  message: '❌ Failed to save profile for user $id',
  error: e,
  stackTrace: stackTrace,
  metadata: {'feature': 'profile'},
);
```

---

## Quick reference

```dart
import 'package:flutter_specialized_temp/core/logger/app_logger.dart';

AppLogger.d(message: '...');                                 // dev breadcrumb
AppLogger.i(message: '...');                                 // dev milestone
AppLogger.w(message: '...', metadata: {...});                // recoverable → Sentry (release)
AppLogger.e(message: '...', error: e, stackTrace: st);       // failure → Sentry (release)
AppLogger.f(message: '...', error: e, stackTrace: st);       // crash → Sentry (release)
```

- Debug build → everything prints, nothing forwards.
- Release build → `d`/`i` go silent; `w`/`e`/`f` forward to Sentry (if `SENTRY_DSN` is set).
- Global errors (zone, framework, platform, BLoC) are already wired to `AppLogger` in `app_initializer.dart`.
