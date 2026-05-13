# Guide 6 — Deployment

Build, sign, and submit your app to Google Play Store and Apple App Store.

---

## Pre-Build Checklist

Before every release build:

- [ ] Update version in `pubspec.yaml`: `version: 1.0.0+1` (version+buildNumber)
- [ ] Update `.env.production` with production `BASE_URL` and `SENTRY_DSN`
- [ ] Run `flutter analyze --fatal-infos --fatal-warnings` — zero errors
- [ ] Run `flutter test` — all tests pass
- [ ] Run `./scripts/clean.sh` to ensure clean generated code
- [ ] Test on a physical device in production mode
- [ ] Verify offline behavior works
- [ ] Verify all accessibility labels are present
- [ ] Remove any debug prints or `AppLogger` verbose logs (auto-disabled in release)
- [ ] Verify splash screen and app icon are correct
- [ ] Test deep links on both platforms

---

## Android — Google Play Store

### 1. Generate Signing Key

```bash
keytool -genkey -v -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

Store this file securely — you cannot recover it. Back it up.

### 2. Configure Signing

Create `android/key.properties`:

```properties
storePassword=your-keystore-password
keyPassword=your-key-password
keyAlias=upload
storeFile=/path/to/upload-keystore.jks
```

Add to `.gitignore`:
```
android/key.properties
*.jks
```

### 3. Update Android Manifest

`android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Required permissions -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

    <application
        android:label="My App Name"
        android:icon="@mipmap/ic_launcher">
        <activity
            android:name=".MainActivity"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
        </activity>

        <!-- Deep linking -->
        <intent-filter>
            <action android:name="android.intent.action.VIEW" />
            <category android:name="android.intent.category.DEFAULT" />
            <category android:name="android.intent.category.BROWSABLE" />
            <data android:scheme="https" android:host="yourapp.com" />
        </intent-filter>
    </application>
</manifest>
```

### 4. Build AAB (Android App Bundle)

```bash
flutter build appbundle \
  -t lib/flavors/main_production.dart \
  --release \
  --obfuscate \
  --split-debug-info=build/debug-info
```

The output is at `build/app/outputs/bundle/release/app-release.aab`.

### 5. Upload to Google Play Console

1. Go to [Google Play Console](https://play.google.com/console)
2. Create app → fill store listing (title, description, screenshots, icon)
3. Go to **Production** → **Create new release**
4. Upload the `.aab` file
5. Complete all store listing sections:
   - App content (privacy policy, data safety)
   - Content rating questionnaire
   - Target audience
6. **Review release** → **Start rollout**

### Google Play Data Safety

Declare in Play Console:
- App uses internet (for API calls)
- App stores data locally (shared_preferences, flutter_secure_storage)
- App collects crash reports (Sentry — if enabled)
- No ads, no analytics (unless you add them)

---

## iOS — Apple App Store

### 1. Configure Xcode Project

Open `ios/Runner.xcworkspace` in Xcode:

1. Select **Runner** target → **Signing & Capabilities**
2. Set **Team** to your Apple Developer account
3. Set **Bundle Identifier** to your app's ID (e.g., `com.yourcompany.yourapp`)
4. Enable capabilities as needed:
   - **Push Notifications** (if needed)
   - **Associated Domains** (for universal links / deep linking)

### 2. Update Info.plist

`ios/Runner/Info.plist`:

```xml
<key>CFBundleDisplayName</key>
<string>My App Name</string>
<key>CFBundleName</key>
<string>My App Name</string>
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
</dict>
```

### 3. Configure App Store Connect

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. **My Apps** → **+** → **New App**
3. Fill in: name, primary language, bundle ID, SKU
4. Complete all sections:
   - App information
   - Screenshots (6.5" and 5.5" required)
   - Description, keywords, support URL, marketing URL
   - App review information

### 4. Build IPA

```bash
flutter build ipa \
  -t lib/flavors/main_production.dart \
  --release \
  --obfuscate \
  --split-debug-info=build/debug-info
```

Output: `build/ios/ipa/*.ipa`

### 5. Upload via Xcode or Transporter

```bash
# Via Xcode:
open build/ios/archive/Runner.xcarchive
# → Distribute App → App Store Connect

# Or via Transporter app:
# Open Transporter → Add the .ipa → Deliver
```

### 6. Submit for Review

In App Store Connect:
1. Select the build you just uploaded
2. Complete "Build Details" (what's new, etc.)
3. **Add for Review**

### Common Apple Rejection Reasons to Avoid

| Issue | Prevention |
|---|---|
| Blank screen on launch | Test splash → auth check → home flow |
| Force unwrap crashes | Use `JsonParseUtils` (never `as Type` without null check) |
| Missing privacy policy | Add a real privacy policy URL |
| Broken offline behavior | Test with airplane mode — show offline banner, don't crash |
| Missing accessibility labels | Add `tooltip` on IconButtons, `semanticsLabel` on Images |
| Hardcoded pricing | Use locale-aware formatting |
| Missing app tracking transparency (if applicable) | Don't collect data without permission |
| Broken deep links | Test universal links on real device |

---

## Deep Linking Setup

### Android (App Links)

1. Host a `assetlinks.json` file at `https://yourapp.com/.well-known/assetlinks.json`
2. Add intent filter in `AndroidManifest.xml` (see above)
3. Verify with: `adb shell am start -a android.intent.action.VIEW -d "https://yourapp.com/path"`

### iOS (Universal Links)

1. Host an `apple-app-site-association` file at `https://yourapp.com/.well-known/apple-app-site-association`
2. Add **Associated Domains** capability in Xcode: `applinks:yourapp.com`
3. Handle in `AppDelegate.swift` if needed

### Flutter Configuration

Deep links are handled by GoRouter. Add them to your route definitions:

```dart
GoRoute(
  path: '/orders/:id',
  builder: (context, state) {
    final id = state.pathParameters['id']!;
    return OrderDetailScreen(orderId: id);
  },
),
```

Test:
```bash
# Android
adb shell am start -a android.intent.action.VIEW -d "yourapp://orders/123"

# iOS
xcrun simctl openurl booted "yourapp://orders/123"
```

---

## Sentry Error Monitoring

The template integrates Sentry for production error tracking.

### Setup

1. Create a project at [sentry.io](https://sentry.io)
2. Copy the DSN into `.env.production` and `.env.staging`:
   ```
   SENTRY_DSN=https://xxx@xxx.ingest.sentry.io/xxx
   ```
3. Sentry is automatically initialized in `app_initializer.dart`
4. In development, Sentry is disabled

### What's Tracked Automatically

- Unhandled exceptions (via Zone guard)
- Flutter framework errors (via `FlutterError.onError`)
- Platform errors (via `WidgetsBindingObserver`)
- BLoC errors (via `AppBlocObserver`)
- HTTP errors (via `DioClient`)
- Navigation events (via `RouterObserver`)

---

## CI/CD Pipeline

### GitHub Actions

The template includes `.github/workflows/`:

**test.yml** — runs on every push and PR:
- `flutter analyze --fatal-infos`
- `flutter test --coverage`
- Uploads coverage artifact

**deploy.yml** — runs on tag push (e.g., `v1.0.0`):
- Builds Android AAB
- Builds iOS IPA
- Uploads to stores (configure secrets)

### Required GitHub Secrets

| Secret | Purpose |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | Base64-encoded keystore file |
| `ANDROID_KEY_PASSWORD` | Keystore key password |
| `ANDROID_STORE_PASSWORD` | Keystore store password |
| `ANDROID_KEY_ALIAS` | Key alias |
| `APPLE_ISSUER_ID` | App Store Connect API issuer |
| `APPLE_KEY_ID` | App Store Connect API key ID |
| `APPLE_PRIVATE_KEY` | App Store Connect API private key |

---

## Build Flavors Reference

| Command | Flavor | Sentry | Logging |
|---|---|---|---|
| `flutter run -t lib/flavors/main_development.dart` | Dev | Disabled | Verbose |
| `flutter run -t lib/flavors/main_staging.dart` | Staging | Enabled | Normal |
| `flutter run -t lib/flavors/main_production.dart` | Prod | Enabled + traces | Minimal |

### Release Build Commands

```bash
# Android AAB
flutter build appbundle -t lib/flavors/main_production.dart --release \
  --obfuscate --split-debug-info=build/debug-info

# Android APK (for testing)
flutter build apk -t lib/flavors/main_production.dart --release \
  --obfuscate --split-debug-info=build/debug-info

# iOS IPA
flutter build ipa -t lib/flavors/main_production.dart --release \
  --obfuscate --split-debug-info=build/debug-info
```

---

## Obfuscation

All release builds use `--obfuscate` which:
- Renames classes and functions to short, meaningless names
- Makes reverse engineering significantly harder
- Debug info is saved to `build/debug-info/` — **keep these files** to decode crash stack traces

To de-obfuscate a stack trace:
```bash
flutter symbolize --input=crash_stacktrace.txt \
  --debug-info=build/debug-info/app.android-arm64.symbols
```
