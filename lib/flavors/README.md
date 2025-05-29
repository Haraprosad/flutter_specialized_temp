# 🚀 Flutter Flavor Management System

## 📋 Table of Contents
- [Overview](#overview)
- [Architecture](#architecture)
- [Quick Start](#quick-start)
- [Environment Setup](#environment-setup)
- [Environment Key Management](#environment-key-management)
- [Development Workflows](#development-workflows)
- [Build & Deployment](#build--deployment)
- [IDE Configuration](#ide-configuration)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)
- [Advanced Usage](#advanced-usage)

## 🎯 Overview

The Flutter Flavor Management System enables you to maintain multiple app configurations for different environments (Development, Staging, Production) within a single codebase. This professional-grade system follows industry best practices and software engineering principles.

### 🌟 Key Features

- **🏗️ Clean Architecture**: Separation of concerns with dedicated configuration layers
- **🔒 Type Safety**: Compile-time type checking for environment configurations  
- **🛡️ Input Validation**: Runtime validation of configuration parameters
- **🔄 DRY Principle**: Centralized configuration management without code duplication
- **⚡ Performance**: Optimized singleton pattern with lazy initialization
- **🧪 Testability**: Easy mocking and testing of environment configurations
- **📱 Platform Support**: Android, iOS, Web, Desktop
- **🔧 IDE Integration**: VS Code, Android Studio, IntelliJ support

### 🎭 Supported Flavors

| Flavor | Purpose | Use Cases |
|--------|---------|-----------|
| **Development** | Active development | Debugging, hot reload, mock data |
| **Staging** | Pre-production testing | QA, client demos, integration testing |
| **Production** | Live app deployment | App stores, end users, maximum performance |

## 🏛️ Architecture

### Core Components

```
lib/flavors/
├── environment.dart          # Environment enumeration with helper methods
├── env_config.dart          # Thread-safe configuration singleton
├── app_initializer.dart     # App initialization with error handling
├── main_development.dart    # Development flavor entry point
├── main_staging.dart        # Staging flavor entry point
├── main_production.dart     # Production flavor entry point
└── README.md               # This documentation
```

### Design Patterns

- **Singleton Pattern**: `EnvConfig` ensures single configuration instance
- **Factory Pattern**: Environment-specific app initialization  
- **Strategy Pattern**: Environment-specific behaviors
- **Observer Pattern**: Configuration change notifications

### SOLID Principles Implementation

- **Single Responsibility**: Each class has one clear purpose
- **Open/Closed**: Extensible for new environments without modification
- **Liskov Substitution**: Environment implementations are interchangeable
- **Interface Segregation**: Minimal, focused interfaces
- **Dependency Inversion**: Abstractions over concrete implementations

## 🚀 Quick Start

### 1. Environment Files Setup

Create environment files in your project root:

```bash
# Create environment files
touch .env.development .env.staging .env.production

# Add to .gitignore (keep templates only)
echo ".env.*" >> .gitignore
echo "!.env.*.template" >> .gitignore
```

### 2. Configure Environment Variables

#### `.env.development`
```env
BASE_URL=https://dev-api.yourapp.com
API_KEY=dev_api_key_here
ENABLE_LOGGING=true
DEBUG_MODE=true
MOCK_DATA=false
ANALYTICS_ENABLED=false
CRASH_REPORTING=false
```

#### `.env.staging`
```env
BASE_URL=https://staging-api.yourapp.com
API_KEY=staging_api_key_here
ENABLE_LOGGING=true
DEBUG_MODE=false
MOCK_DATA=false
ANALYTICS_ENABLED=true
CRASH_REPORTING=true
```

#### `.env.production`
```env
BASE_URL=https://api.yourapp.com
API_KEY=prod_api_key_here
ENABLE_LOGGING=false
DEBUG_MODE=false
MOCK_DATA=false
ANALYTICS_ENABLED=true
CRASH_REPORTING=true
```

### 3. Update pubspec.yaml

Ensure environment files are included in assets:

```yaml
flutter:
  assets:
    - .env.development
    - .env.staging
    - .env.production
```

### 4. Run Your App

```bash
# Development
flutter run -t lib/flavors/main_development.dart

# Staging
flutter run -t lib/flavors/main_staging.dart

# Production
flutter run -t lib/flavors/main_production.dart
```

## ⚙️ Environment Setup

### Prerequisites

- Flutter SDK 3.5.3+
- Dart SDK 3.0+
- IDE with Flutter support

### Dependencies

The system uses these packages (already included):

```yaml
dependencies:
  flutter_dotenv: ^5.2.1    # Environment file loading
  get_it: ^8.0.2            # Dependency injection
  injectable: ^2.5.0        # DI code generation

dev_dependencies:
  injectable_generator: ^2.6.2  # DI code generation
  build_runner: ^2.4.13        # Code generation runner
```

### Initial Setup

1. **Clone/Download** the template
2. **Install dependencies**: `flutter pub get`
3. **Generate DI code**: `flutter packages pub run build_runner build`
4. **Create environment files** (see Quick Start)
5. **Configure IDE** (see IDE Configuration)

## 🔄 Development Workflows

### Daily Development Workflow

```bash
# 1. Start development environment
flutter run -t lib/flavors/main_development.dart

# 2. Make code changes with hot reload
# Hot reload: Cmd+R (macOS) / Ctrl+R (Windows/Linux)
# Hot restart: Cmd+Shift+R (macOS) / Ctrl+Shift+R (Windows/Linux)

# 3. Run tests
flutter test

# 4. Check code quality
flutter analyze
dart format .
```

### Testing Workflow

```bash
# Unit tests
flutter test

# Integration tests on staging
flutter run -t lib/flavors/main_staging.dart --profile

# Performance testing on production build
flutter run -t lib/flavors/main_production.dart --release
```

### Code Review Workflow

1. **Lint checks**: `flutter analyze`
2. **Format code**: `dart format .`
3. **Test coverage**: `flutter test --coverage`
4. **Build verification**: Build all flavors
5. **Environment validation**: Verify all environment files

## 📦 Build & Deployment

### Android Builds

```bash
# Development APK
flutter build apk -t lib/flavors/main_development.dart --debug

# Staging APK
flutter build apk -t lib/flavors/main_staging.dart --release

# Production App Bundle (Play Store)
flutter build appbundle -t lib/flavors/main_production.dart --release
```

### iOS Builds

```bash
# Development build
flutter build ios -t lib/flavors/main_development.dart --debug

# Staging build (TestFlight)
flutter build ios -t lib/flavors/main_staging.dart --release

# Production build (App Store)
flutter build ios -t lib/flavors/main_production.dart --release
```

### Web Builds

```bash
# Development
flutter build web -t lib/flavors/main_development.dart

# Staging
flutter build web -t lib/flavors/main_staging.dart --release

# Production
flutter build web -t lib/flavors/main_production.dart --release
```

## 🎯 IDE Configuration

### Visual Studio Code

Create `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Development",
      "request": "launch",
      "type": "dart",
      "program": "lib/flavors/main_development.dart",
      "args": ["--flavor", "development"]
    },
    {
      "name": "Staging",
      "request": "launch",
      "type": "dart",
      "program": "lib/flavors/main_staging.dart",
      "args": ["--flavor", "staging"]
    },
    {
      "name": "Production",
      "request": "launch",
      "type": "dart",
      "program": "lib/flavors/main_production.dart",
      "args": ["--flavor", "production"]
    }
  ]
}
```

### Android Studio / IntelliJ

1. **Run/Debug Configurations** → **+** → **Flutter**
2. Set **Dart entrypoint** to flavor-specific main file
3. Add **Additional arguments**: `--flavor development`
4. Repeat for each flavor

### Tasks Configuration

Create `.vscode/tasks.json`:

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Build All Flavors",
      "type": "shell",
      "command": "flutter",
      "args": ["build", "apk", "--split-per-abi"],
      "group": "build",
      "presentation": {
        "echo": true,
        "reveal": "always",
        "panel": "new"
      }
    }
  ]
}
```

## 📐 Best Practices

### Environment Variable Management

✅ **DO:**
- **Always define new keys in `.env.production` first**
- **Use constants from `env_constants.dart` for all key references**
- **Update `EnvConfig` class when adding/removing environment variables**
- **Synchronize `app_initializer.dart` with `EnvConfig` changes**
- Use descriptive variable names (`API_BASE_URL` not `URL`)
- Include all environments in version control templates
- Validate required variables at startup
- Use consistent naming across environments

❌ **DON'T:**
- Add environment keys only to development/staging without production
- Use hardcoded strings for environment key names
- Skip updating `EnvConfig` when adding new environment variables
- Forget to update `app_initializer.dart` after `EnvConfig` changes
- Store secrets in version control
- Use hardcoded values in code
- Skip environment validation
- Mix environment-specific logic in business code

### Configuration Synchronization

✅ **Proper Synchronization Flow:**
```dart
// 1. Production environment defines all keys
// .env.production
API_TIMEOUT=30

// 2. Constant defined in env_constants.dart
static const String envKeyApiTimeout = 'API_TIMEOUT';

// 3. Field added to EnvConfig
final int apiTimeout;

// 4. Parameter added to instantiate method
required int apiTimeout,

// 5. Used in app_initializer.dart
apiTimeout: dotenv.getInt(EnvConstants.envKeyApiTimeout, fallback: 30),
```

❌ **Avoid Desynchronization:**
```dart
// ❌ Bad: Using hardcoded string
final timeout = dotenv.env['API_TIMEOUT'];

// ❌ Bad: Missing from EnvConfig but used directly
final setting = dotenv.env[EnvConstants.envKeySomeSetting];

// ❌ Bad: EnvConfig has field but not passed in initializer
// EnvConfig has 'newField' but initializeApp doesn't pass it
```

### Code Review Checklist

When adding new environment variables, verify:

- [ ] Key exists in `.env.production`
- [ ] Constant defined in `env_constants.dart`
- [ ] Field added to `EnvConfig` class
- [ ] Constructor parameter added
- [ ] `instantiate` method updated
- [ ] `app_initializer.dart` passes the parameter
- [ ] All environment files updated consistently
- [ ] Type conversion handled properly (string, bool, int)
- [ ] Default/fallback values provided where appropriate
- [ ] Validation logic updated if needed

### Configuration Management

```dart
// ✅ Good: Use EnvConfig for environment-specific values
final apiUrl = EnvConfig.instance.baseUrl;
final isDebug = EnvConfig.instance.env.isDebugMode;

// ❌ Bad: Hardcoded values
final apiUrl = 'https://api.example.com';
final isDebug = true;
```

### Error Handling

```dart
// ✅ Good: Proper error handling
try {
  final config = EnvConfig.instantiate(
    appName: appName,
    baseUrl: baseUrl,
    env: env,
  );
} on EnvConfigException catch (e) {
  logger.error('Configuration error: ${e.message}');
  rethrow;
}

// ❌ Bad: No error handling
final config = EnvConfig.instantiate(
  appName: appName,
  baseUrl: baseUrl,
  env: env,
);
```

### Code Organization

```dart
// ✅ Good: Environment-specific behavior
void initializeAnalytics() {
  if (EnvConfig.instance.env.isProduction) {
    // Initialize production analytics
  } else if (EnvConfig.instance.env.isStaging) {
    // Initialize staging analytics
  }
  // No analytics in development
}

// ❌ Bad: Scattered environment checks
void someFunction() {
  if (kDebugMode) {
    // This mixes debug mode with environment logic
  }
}
```

## 🚨 Troubleshooting

### Common Issues

#### 1. Environment File Not Loading

**Problem**: App crashes with "File not found" error

**Solution**:
```bash
# Check if files exist
ls -la .env.*

# Verify pubspec.yaml assets section
grep -A 5 "assets:" pubspec.yaml

# Clean and rebuild
flutter clean && flutter pub get
```

#### 2. Configuration Not Initialized

**Problem**: `StateError: EnvConfig has not been initialized`

**Solution**:
- Ensure `initializeApp()` is called first
- Check main file entry point
- Verify environment file format

#### 3. Invalid URL Format

**Problem**: `EnvConfigException: Invalid base URL format`

**Solution**:
```env
# ✅ Correct format
BASE_URL=https://api.example.com

# ❌ Incorrect formats
BASE_URL=api.example.com        # Missing protocol
BASE_URL=ftp://api.example.com  # Wrong protocol
```

#### 4. Build Failures

**Problem**: Build fails with flavor-specific errors

**Solution**:
```bash
# Clean everything
flutter clean
rm -rf .dart_tool/
flutter pub get

# Regenerate generated code
flutter packages pub run build_runner clean
flutter packages pub run build_runner build
```

### Debug Commands

```bash
# Check environment loading
flutter run -t lib/flavors/main_development.dart --verbose

# Analyze code issues
flutter analyze --verbose

# Check dependencies
flutter doctor -v

# Clean build artifacts
flutter clean && rm -rf .dart_tool/
```

## 🔬 Advanced Usage

### Custom Environment Variables

Add custom variables to your environment files:

```env
# .env.development
FEATURE_FLAG_NEW_UI=true
MOCK_USER_DATA=true
LOG_LEVEL=debug
CACHE_DURATION=300
```

Access in code:

```dart
class FeatureFlags {
  static bool get newUIEnabled => 
    dotenv.getBool('FEATURE_FLAG_NEW_UI', fallback: false);
    
  static bool get mockDataEnabled => 
    dotenv.getBool('MOCK_USER_DATA', fallback: false);
}
```

### Multiple API Endpoints

```env
# Support multiple services
API_BASE_URL=https://api.example.com
AUTH_SERVICE_URL=https://auth.example.com
ANALYTICS_URL=https://analytics.example.com
CDN_BASE_URL=https://cdn.example.com
```

### Conditional Dependency Injection

```dart
@module
abstract class NetworkModule {
  @Environment('development')
  @injectable
  HttpClient get devHttpClient => MockHttpClient();
  
  @Environment('production')
  @injectable  
  HttpClient get prodHttpClient => DioHttpClient();
}
```

### Environment-Specific Widgets

```dart
class EnvironmentBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final env = EnvConfig.instance.env;
    
    if (env.isProduction) return const SizedBox.shrink();
    
    return Container(
      color: env.isDevelopment ? Colors.red : Colors.orange,
      child: Text('${env.displayName} Mode'),
    );
  }
}
```

### CI/CD Integration

#### GitHub Actions Example

```yaml
name: Build All Flavors
on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        flavor: [development, staging, production]
    
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      
      - name: Install dependencies
        run: flutter pub get
        
      - name: Build ${{ matrix.flavor }}
        run: |
          flutter build apk \
            -t lib/flavors/main_${{ matrix.flavor }}.dart \
            --release
```

### Security Considerations

1. **Environment Files**: Use CI/CD secrets for sensitive values
2. **Code Obfuscation**: Enable for production builds
3. **Certificate Pinning**: Implement for production API calls
4. **Debug Information**: Strip debug info from production builds

### Performance Optimization

1. **Lazy Loading**: Environment config loads only when needed
2. **Caching**: Configuration values cached after first access
3. **Tree Shaking**: Unused environment code eliminated in builds
4. **Compilation**: Dead code elimination for unused flavors

---

## 📞 Support

For questions or issues:

1. **Check documentation** in individual flavor files
2. **Review error messages** - they provide specific guidance
3. **Use debug logging** in development builds
4. **Check GitHub issues** for known problems

## 🤝 Contributing

1. Follow existing code patterns and documentation style
2. Add tests for new features
3. Update documentation for changes
4. Ensure all flavors build successfully

---

**Made with ❤️ for professional Flutter development** 

## 🔑 Environment Key Management

### Core Principles

The flavor system follows strict guidelines for environment variable management to ensure consistency and maintainability:

#### 1. Master Environment File (`.env.production`)
- **All environment keys must be defined in `.env.production`**
- This serves as the master reference for all available environment variables
- Other environment files (development, staging) should only contain subset or variations of these keys
- New environment variables should always be added to production first, then propagated to other environments

```env
# .env.production (Master reference)
BASE_URL=https://api.yourapp.com
API_KEY=your_production_api_key
ENABLE_LOGGING=false
DEBUG_MODE=false
MOCK_DATA=false
ANALYTICS_ENABLED=true
CRASH_REPORTING=true
DATABASE_URL=https://prod-db.yourapp.com
PAYMENT_GATEWAY_URL=https://payments.yourapp.com
TIMEOUT_DURATION=30
MAX_RETRY_ATTEMPTS=3
```

#### 2. Environment Constants (`env_constants.dart`)
- **All environment keys must be defined as constants in `lib/core/constants/env_constants.dart`**
- Use descriptive, typed constant names
- Follow consistent naming conventions
- Provide clear documentation for each constant

```dart
// lib/core/constants/env_constants.dart
class EnvConstants {
  // Environment file names
  static const String envDevelopment = '.env.development';
  static const String envStaging = '.env.staging';
  static const String envProduction = '.env.production';
  
  // Environment keys (must match .env.production keys)
  static const String envKeyBaseUrl = 'BASE_URL';
  static const String envKeyApiKey = 'API_KEY';
  static const String envKeyEnableLogging = 'ENABLE_LOGGING';
  static const String envKeyDebugMode = 'DEBUG_MODE';
  static const String envKeyMockData = 'MOCK_DATA';
  static const String envKeyAnalyticsEnabled = 'ANALYTICS_ENABLED';
  static const String envKeyCrashReporting = 'CRASH_REPORTING';
  static const String envKeyDatabaseUrl = 'DATABASE_URL';
  static const String envKeyPaymentGatewayUrl = 'PAYMENT_GATEWAY_URL';
  static const String envKeyTimeoutDuration = 'TIMEOUT_DURATION';
  static const String envKeyMaxRetryAttempts = 'MAX_RETRY_ATTEMPTS';
}
```

#### 3. Environment Configuration Updates (`env_config.dart`)
- **Update `EnvConfig` class fields based on needed environment keys**
- Add or remove fields according to your application requirements
- Maintain type safety and validation
- Update constructor and instantiate method accordingly

```dart
// lib/flavors/env_config.dart
class EnvConfig {
  // Core fields (always required)
  final String appName;
  final String baseUrl;
  final Env env;
  
  // Additional fields based on env keys
  final String apiKey;
  final bool enableLogging;
  final bool debugMode;
  final bool mockData;
  final bool analyticsEnabled;
  final bool crashReporting;
  final String databaseUrl;
  final String paymentGatewayUrl;
  final int timeoutDuration;
  final int maxRetryAttempts;
  
  const EnvConfig._({
    required this.appName,
    required this.baseUrl,
    required this.env,
    required this.apiKey,
    required this.enableLogging,
    required this.debugMode,
    required this.mockData,
    required this.analyticsEnabled,
    required this.crashReporting,
    required this.databaseUrl,
    required this.paymentGatewayUrl,
    required this.timeoutDuration,
    required this.maxRetryAttempts,
  });
  
  factory EnvConfig.instantiate({
    required String appName,
    required String baseUrl,
    required Env env,
    required String apiKey,
    required bool enableLogging,
    required bool debugMode,
    required bool mockData,
    required bool analyticsEnabled,
    required bool crashReporting,
    required String databaseUrl,
    required String paymentGatewayUrl,
    required int timeoutDuration,
    required int maxRetryAttempts,
  }) {
    // Validation logic
    _validateConfiguration(
      appName: appName,
      baseUrl: baseUrl,
      apiKey: apiKey,
      databaseUrl: databaseUrl,
      paymentGatewayUrl: paymentGatewayUrl,
      timeoutDuration: timeoutDuration,
      maxRetryAttempts: maxRetryAttempts,
    );
    
    return _instance = EnvConfig._(
      appName: appName,
      baseUrl: baseUrl,
      env: env,
      apiKey: apiKey,
      enableLogging: enableLogging,
      debugMode: debugMode,
      mockData: mockData,
      analyticsEnabled: analyticsEnabled,
      crashReporting: crashReporting,
      databaseUrl: databaseUrl,
      paymentGatewayUrl: paymentGatewayUrl,
      timeoutDuration: timeoutDuration,
      maxRetryAttempts: maxRetryAttempts,
    );
  }
}
```

#### 4. App Initializer Updates (`app_initializer.dart`)
- **Update `EnvConfig.instantiate()` call in `initializeApp()` function**
- Pass all required parameters from environment variables
- Use environment constants for key references
- Provide proper type conversion and defaults

```dart
// lib/flavors/app_initializer.dart
Future<void> initializeApp(String envFileName, String appName, Env env) async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    await dotenv.load(fileName: envFileName);

    // Configure environment with all required fields
    EnvConfig.instantiate(
      appName: appName,
      baseUrl: dotenv.env[EnvConstants.envKeyBaseUrl]!,
      env: env,
      apiKey: dotenv.env[EnvConstants.envKeyApiKey]!,
      enableLogging: dotenv.getBool(EnvConstants.envKeyEnableLogging, fallback: false),
      debugMode: dotenv.getBool(EnvConstants.envKeyDebugMode, fallback: false),
      mockData: dotenv.getBool(EnvConstants.envKeyMockData, fallback: false),
      analyticsEnabled: dotenv.getBool(EnvConstants.envKeyAnalyticsEnabled, fallback: true),
      crashReporting: dotenv.getBool(EnvConstants.envKeyCrashReporting, fallback: true),
      databaseUrl: dotenv.env[EnvConstants.envKeyDatabaseUrl]!,
      paymentGatewayUrl: dotenv.env[EnvConstants.envKeyPaymentGatewayUrl]!,
      timeoutDuration: dotenv.getInt(EnvConstants.envKeyTimeoutDuration, fallback: 30),
      maxRetryAttempts: dotenv.getInt(EnvConstants.envKeyMaxRetryAttempts, fallback: 3),
    );
    
    await configureDependencies();
    Bloc.observer = AppBlocObserver();
    runApp(const MyApp());
  }, (exception, stackTrace) async {
    AppLogger.f(
      message: "runZonedGuarded caught error",
      error: exception,
      stackTrace: stackTrace,
    );
  });
  
  // ... rest of error handling code
}
```

### Workflow for Adding New Environment Variables

1. **Add to Production Environment**
   ```env
   # .env.production
   NEW_FEATURE_ENDPOINT=https://new-feature-api.yourapp.com
   ```

2. **Define Constant**
   ```dart
   // env_constants.dart
   static const String envKeyNewFeatureEndpoint = 'NEW_FEATURE_ENDPOINT';
   ```

3. **Update EnvConfig Class**
   ```dart
   // env_config.dart
   final String newFeatureEndpoint;
   
   // Add to constructor and instantiate method
   required this.newFeatureEndpoint,
   ```

4. **Update App Initializer**
   ```dart
   // app_initializer.dart
   newFeatureEndpoint: dotenv.env[EnvConstants.envKeyNewFeatureEndpoint]!,
   ```

5. **Add to Other Environment Files**
   ```env
   # .env.development
   NEW_FEATURE_ENDPOINT=https://dev-new-feature-api.yourapp.com
   
   # .env.staging  
   NEW_FEATURE_ENDPOINT=https://staging-new-feature-api.yourapp.com
   ``` 