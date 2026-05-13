# Guide 1 — Getting Started

Everything you need to go from this template to **your own app** and run it for the first time.

---

## Prerequisites

| Tool | Version |
|---|---|
| Flutter SDK | 3.41+ (stable channel) |
| Dart SDK | 3.11+ (bundled with Flutter) |
| Xcode | 15+ (for iOS) |
| Android Studio | Latest (for Android) |
| Mason CLI | `dart pub global activate mason_cli` (optional, for feature scaffolding) |

---

## Step 1 — Clone and Install

```bash
git clone <template-repo-url> my_app
cd my_app

flutter pub get
./scripts/codegen.sh
```

---

## Step 2 — Detach from the Template Repo

This template ships with its own `.git` history. Before pushing to your own repository you must replace it with a fresh git history.

```bash
# Remove the template's git history
rm -rf .git

# Start a clean repo for your app
git init
git add .
git commit -m "chore: init from flutter_specialized_temp"

# Point to your new remote and push
git remote add origin <your-new-repo-url>
git push -u origin main
```

### Exclude template development artifacts from your app's repo

The following files and folders exist only to help build and maintain the template itself. They carry no runtime value for apps built on top of it. Add them to your app's `.gitignore` so they are never committed:

```gitignore
# Template development artifacts — not needed in your app's repo
docs/
CLAUDE.md
WORKFLOW.md
.claude/
mason.yaml
```

> **Why?** `docs/` contains the template guide you are reading now. `CLAUDE.md` and `WORKFLOW.md` are AI-assistant memory files. `.claude/` holds agent personas and skill files. `mason.yaml` is the template scaffolding config. None of these belong in a production app repo.

---

## Step 3 — Configure Environments

The template uses three environments. Each has its own entry point and `.env` file.

```bash
# Copy the provided templates
cp ".env copy.development" .env.development
cp ".env copy.staging"     .env.staging
cp ".env copy.production"  .env.production
```

Edit each file and fill in:

| Key | Description |
|---|---|
| `BASE_URL` | Your API base URL (e.g. `https://api.myapp.com/`) |
| `SENTRY_DSN` | Your Sentry project DSN (leave empty for dev) |

| File | Entry Point | Purpose |
|---|---|---|
| `.env.development` | `lib/flavors/main_development.dart` | Verbose logging, Sentry disabled |
| `.env.staging` | `lib/flavors/main_staging.dart` | Sentry enabled, traces disabled |
| `.env.production` | `lib/flavors/main_production.dart` | Full Sentry + performance traces |

---

## Step 4 — Change App Name

### Android

Edit `android/app/src/main/AndroidManifest.xml`:
```xml
<application android:label="My App Name">
```

### iOS

Edit `ios/Runner/Info.plist`:
```xml
<key>CFBundleDisplayName</key>
<string>My App Name</string>
<key>CFBundleName</key>
<string>My App Name</string>
```

### All Platforms (Recommended)

Use the `flutter_launcher_icons` approach (see Step 6) — it handles naming alongside icons.

---

## Step 5 — Change Package Name / Bundle ID

### Android

1. Edit `android/app/build.gradle`:
   ```groovy
   android {
       defaultConfig {
           applicationId "com.yourcompany.yourapp"
       }
   }
   ```

2. Update the namespace in `android/app/build.gradle`:
   ```groovy
   android {
       namespace "com.yourcompany.yourapp"
   }
   ```

3. Update the package in `android/app/src/main/kotlin/` — create the correct directory structure and move `MainActivity.kt`:
   ```kotlin
   package com.yourcompany.yourapp
   import io.flutter.embedding.android.FlutterActivity
   class MainActivity: FlutterActivity()
   ```

4. Update `android/app/src/debug/AndroidManifest.xml` and `android/app/src/profile/AndroidManifest.xml` if they reference the old package.

### iOS

Edit `ios/Runner.xcodeproj/project.pbxproj` — search for `PRODUCT_BUNDLE_IDENTIFIER` and change to:
```
com.yourcompany.yourapp
```

Also update the bundle ID in Xcode: Runner → Signing & Capabilities → Bundle Identifier.

---

## Step 6 — Set App Icon

1. Add `flutter_launcher_icons` to `pubspec.yaml` under `dev_dependencies`:
   ```yaml
   dev_dependencies:
     flutter_launcher_icons: ^0.14.3
   ```

2. Add configuration in `pubspec.yaml`:
   ```yaml
   flutter_launcher_icons:
     android: true
     ios: true
     image_path: "assets/icons/app_icon.png"
     adaptive_icon_background: "#FFFFFF"
     adaptive_icon_foreground: "assets/icons/app_icon_foreground.png"
   ```

3. Prepare your icon files:
   - `app_icon.png` — 1024x1024 PNG
   - `app_icon_foreground.png` — 1024x1024 PNG with safe zone (adaptive icon for Android)

4. Generate:
   ```bash
   dart run flutter_launcher_icons
   ```

---

## Step 7 — Set Splash Screen

1. Add `flutter_native_splash` to `dev_dependencies`:
   ```yaml
   dev_dependencies:
     flutter_native_splash: ^2.4.3
   ```

2. Configure in `pubspec.yaml`:
   ```yaml
   flutter_native_splash:
     color: "#FFFFFF"
     image: assets/icons/splash_logo.png
     android_12:
       image: assets/icons/splash_logo.png
   ```

3. Generate:
   ```bash
   dart run flutter_native_splash:create
   ```

---

## Step 8 — Update Import Paths (Optional)

If you change the project name in `pubspec.yaml` (the `name:` field), all imports will change:
```dart
// Before
import 'package:flutter_specialized_temp/core/...';

// After (if you rename to 'my_app')
import 'package:my_app/core/...';
```

To rename:
1. Change `name:` in `pubspec.yaml`
2. Run a project-wide find-and-replace: `flutter_specialized_temp` → `my_app`
3. Run `./scripts/clean.sh` to regenerate everything

---

## Step 9 — Run the App

### Development
```bash
flutter run -t lib/flavors/main_development.dart
```

### Staging
```bash
flutter run -t lib/flavors/main_staging.dart
```

### Production
```bash
flutter run -t lib/flavors/main_production.dart
```

### Responsive Preview (multi-device preview)
```bash
flutter run -t lib/main_preview.dart
```

### VS Code

The project includes ready-to-use launch configurations in `.vscode/launch.json`. Open the Run & Debug panel and select:
- **Development**
- **Staging**
- **Production**
- **Preview (Device Preview)**

---

## Step 10 — Verify Everything Works

1. App launches with the home screen
2. Theme toggle works (light/dark)
3. Locale switch works (EN/BN)
4. Navigation between screens works
5. Network-aware banner shows when offline
6. `flutter analyze` passes with no errors
7. `flutter test` passes all tests

---

## Common First Modifications

| What | Where |
|---|---|
| Change theme colors | `lib/core/design_management_system/themes/app_color_scheme.dart` |
| Change fonts | Add to `assets/fonts/` and update `pubspec.yaml` `fonts:` section, then edit `app_typography.dart` |
| Add a language | Add `app_xx.arb` in `lib/core/localization/l10n/`, run `flutter gen-l10n` |
| Change API base URL | Edit the `.env.*` files |
| Add Sentry DSN | Edit `.env.production` and `.env.staging` |
| Add app-level providers | Edit `lib/main.dart` — add to `MultiBlocProvider` |
| Add routes | Edit `lib/core/router/app_routes.dart` and `app_router.dart` |

---

## Project Scripts

| Script | Purpose |
|---|---|
| `./scripts/codegen.sh` | Run `build_runner` — generates Freezed, Injectable, Drift, JSON code |
| `./scripts/clean.sh` | Delete all generated files, `flutter clean`, `pub get`, regenerate |

Run `codegen.sh` every time you:
- Add or modify a `@freezed` model
- Add or modify an `@injectable` / `@singleton` / `@lazySingleton` annotation
- Add or modify a Drift table or DAO
- Add or modify a `@JsonSerializable` class
