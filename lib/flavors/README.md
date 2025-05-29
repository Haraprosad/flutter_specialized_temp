# 🚀 Flutter Flavor Management System

## Why Use Flavor Management?

Flavor management allows you to maintain multiple app configurations (Development, Staging, Production) in a single codebase. This enables:
- Seamless switching between environments for development, QA, and production.
- Environment-specific variables (API endpoints, feature flags, etc.).
- Safer deployments and easier debugging.

---

## 🏗️ How Flavor Management Works in This Project

### 1. **Environment Files (`.env.*`)**

- Each environment has its own `.env` file at the project root:
  - `.env.development`
  - `.env.staging`
  - `.env.production`
- These files contain key-value pairs for environment-specific variables.

**Example:**
```env
# .env.development
BASE_URL=https://dev-api.yourapp.com
API_KEY=dev_api_key
ENABLE_LOGGING=true
```

---

### 2. **Define Keys in `env_constants.dart`**

- All environment variable keys are defined as constants in:
  - `lib/core/constants/env_constants.dart`

**Example:**
```dart
// ...existing code...
static const String envKeyBaseUrl = "BASE_URL";
static const String envKeyApiKey = "API_KEY";
static const String envKeyEnableLogging = "ENABLE_LOGGING";
// ...existing code...
```

---

### 3. **Update `EnvConfig` for All Variables**

- `EnvConfig` (in `lib/flavors/env_config.dart`) is the singleton that holds all environment values.
- For every variable in your `.env.*` files and `EnvConstants`, add a corresponding field in `EnvConfig`.
- Update the constructor and `instantiate` method to accept and store these values.

**Example:**
```dart
// ...existing code...
final String baseUrl;
final String apiKey;
final bool enableLogging;
// ...existing code...
```

---

### 4. **Instantiate `EnvConfig` in `app_initializer.dart`**

- In `lib/flavors/app_initializer.dart`, the `initializeApp` function loads the correct `.env` file and instantiates `EnvConfig` with all required fields.

**Example:**
```dart
// ...existing code...
await dotenv.load(fileName: env.envFileName);
EnvConfig.instantiate(
  appName: EnvConfig.createAppName(StringConstants.appName, env),
  baseUrl: dotenv.env[EnvConstants.envKeyBaseUrl]!,
  env: env,
  // Add all other fields here...
);
// ...existing code...
```

---

### 5. **Flavor Entry Points (`main_*.dart`)**

- Each flavor has its own entry point in `lib/flavors/`:
  - `main_development.dart`
  - `main_staging.dart`
  - `main_production.dart`
- Each calls `initializeApp` with the appropriate environment.

**Example:**
```dart
void main() async {
  const environment = Env.DEVELOPMENT; // or STAGING/PRODUCTION
  await initializeApp(environment);
}
```

---

### 6. **Accessing Environment Variables Anywhere**

- Use `EnvConfig.instance` to access environment variables anywhere in your app.

**Example Usage:**
```dart
import 'package:flutter_specialized_temp/flavors/env_config.dart';

final apiUrl = EnvConfig.instance.baseUrl;
final isLoggingEnabled = EnvConfig.instance.enableLogging;
```

You can use these fields in:
- Network services
- Feature flags
- Logging setup
- UI widgets (for banners, etc.)

---

## 👩‍💻 Step-by-Step: Using This Template Professionally

1. **Add all environment variables** to `.env.development`, `.env.staging`, `.env.production`.
2. **Define each variable's key** as a constant in `lib/core/constants/env_constants.dart`.
3. **Add a field for each variable** in `EnvConfig` (`lib/flavors/env_config.dart`).
4. **Update the constructor and instantiate method** in `EnvConfig` to accept all variables.
5. **In `app_initializer.dart`**, pass all variables from `dotenv.env` to `EnvConfig.instantiate`.
6. **Use the correct entry point** (`main_development.dart`, `main_staging.dart`, `main_production.dart`) to run the app for each environment.
7. **Access environment variables** anywhere in your code via `EnvConfig.instance`.

---

## 📦 Example: Adding a New Environment Variable

Suppose you want to add `FEATURE_FLAG_NEW_UI`.

1. **Add to all `.env.*` files:**
   ```
   FEATURE_FLAG_NEW_UI=true
   ```

2. **Add to `env_constants.dart`:**
   ```dart
   static const String envKeyFeatureFlagNewUi = "FEATURE_FLAG_NEW_UI";
   ```

3. **Add to `EnvConfig`:**
   ```dart
   final bool featureFlagNewUi;
   ```

4. **Update constructor and instantiate method in `EnvConfig`:**
   ```dart
   required this.featureFlagNewUi,
   ```

5. **Update `app_initializer.dart`:**
   ```dart
   featureFlagNewUi: dotenv.getBool(EnvConstants.envKeyFeatureFlagNewUi, fallback: false),
   ```

6. **Access anywhere:**
   ```dart
   if (EnvConfig.instance.featureFlagNewUi) {
     // Show new UI
   }
   ```

---

## 📝 Summary

- **All environment variables**: Define in `.env.*` and `env_constants.dart`.
- **Central access**: Use `EnvConfig.instance` everywhere.
- **Entry points**: Use the correct `main_*.dart` for each flavor.
- **Easy to extend**: Add new variables by updating `.env.*`, `env_constants.dart`, `EnvConfig`, and `app_initializer.dart`.

This ensures a robust, maintainable, and professional flavor management workflow for your Flutter project.