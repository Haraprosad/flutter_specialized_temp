/// Environment-related constants for Flutter application configuration.
/// 
/// This class contains constants that are shared across the **entire application**,
/// including the flavor management system, network layer, configuration services,
/// and any other components that need to access environment variables.
/// 
/// ## Usage Throughout the App
/// These constants should be used by **any part of the application** that needs
/// to access environment variables from .env files:
/// 
/// ```dart
/// // ✅ In network services
/// class ApiClient {
///   String get baseUrl => dotenv.env[EnvConstants.envKeyBaseUrl] ?? '';
/// }
/// 
/// // ✅ In configuration services  
/// class AppConfig {
///   bool get isLoggingEnabled => 
///     dotenv.env[EnvConstants.envKeyEnableLogging] == 'true';
/// }
/// 
/// // ✅ In repositories
/// class UserRepository {
///   String get apiKey => dotenv.env[EnvConstants.envKeyApiKey] ?? '';
/// }
/// 
/// // ✅ In testing utilities
/// class TestHelper {
///   static void setupTestEnv() {
///     dotenv.testLoad(fileInput: '''
///       ${EnvConstants.envKeyBaseUrl}=https://test-api.com
///     ''');
///   }
/// }
/// ```
/// 
/// ## Design Principles
/// - **Single Source of Truth**: All environment variable keys defined here
/// - **Application-Wide Access**: Available to all layers and features
/// - **Type Safety**: Compile-time constants prevent typos
/// - **Maintainability**: Changes in one place affect the entire app
/// 
/// ## Note
/// File names are managed by the [Env] enum through [Env.envFileName].
/// This class focuses on environment variable keys and shared constants.
class EnvConstants {
  /// Private constructor to prevent instantiation.
  EnvConstants._();

  /// Key for the base URL in environment files.
  /// 
  /// This is the standard key used across all environment files
  /// to specify the API base URL.
  /// 
  /// Example usage in .env files:
  /// ```env
  /// BASE_URL=https://api.example.com
  /// ```
  static const String envKeyBaseUrl = "BASE_URL";

  /// Key for the API key in environment files.
  /// 
  /// This is the standard key used across all environment files
  /// to specify the API authentication key.
  /// 
  /// Example usage in .env files:
  /// ```env
  /// API_KEY=your_api_key_here
  /// ```
  static const String envKeyApiKey = "API_KEY";

  /// Key for enabling/disabling logging in environment files.
  /// 
  /// This is the standard key used to control application logging.
  /// 
  /// Example usage in .env files:
  /// ```env
  /// ENABLE_LOGGING=true
  /// ```
  static const String envKeyEnableLogging = "ENABLE_LOGGING";

  /// Key for enabling/disabling debug mode in environment files.
  /// 
  /// This is the standard key used to control debug features.
  /// 
  /// Example usage in .env files:
  /// ```env
  /// DEBUG_MODE=true
  /// ```
  static const String envKeyDebugMode = "DEBUG_MODE";

  /// Key for enabling/disabling analytics in environment files.
  /// 
  /// This is the standard key used to control analytics collection.
  /// 
  /// Example usage in .env files:
  /// ```env
  /// ANALYTICS_ENABLED=true
  /// ```
  static const String envKeyAnalyticsEnabled = "ANALYTICS_ENABLED";

  /// Key for enabling/disabling crash reporting in environment files.
  /// 
  /// This is the standard key used to control crash reporting.
  /// 
  /// Example usage in .env files:
  /// ```env
  /// CRASH_REPORTING=true
  /// ```
  static const String envKeyCrashReporting = "CRASH_REPORTING";
}
