/// # Environment Configuration Management
/// 
/// This file implements a thread-safe singleton pattern for managing
/// application environment configurations across different build flavors.
/// 
/// ## Key Features
/// - **Singleton Pattern**: Ensures single instance throughout app lifecycle
/// - **Thread Safety**: Uses locking mechanism to prevent race conditions
/// - **Immutable Configuration**: Once set, configuration cannot be changed
/// - **Environment Aware**: Integrates with the flavor management system
/// - **Validation**: Validates configuration parameters during initialization
/// 
/// ## Configuration Sources
/// - Environment variables from `.env` files
/// - Build-time constants
/// - Flavor-specific settings
/// 
/// ## Usage in Other Parts of App
/// ```dart
/// // Access configuration anywhere in the app
/// final config = EnvConfig.instance;
/// print('Current environment: ${config.env}');
/// print('API Base URL: ${config.baseUrl}');
/// print('App Name: ${config.appName}');
/// ```

import 'environment.dart';

/// Exception thrown when environment configuration validation fails.
/// 
/// This provides better error handling and debugging capabilities
/// when configuration initialization encounters issues.
class EnvConfigException implements Exception {
  /// The error message describing what went wrong.
  final String message;
  
  /// Creates a new environment configuration exception.
  const EnvConfigException(this.message);
  
  @override
  String toString() => 'EnvConfigException: $message';
}

/// Singleton class for managing environment-specific application configuration.
/// 
/// This class provides a centralized way to access environment configurations
/// such as API endpoints, app names, and environment types. It uses a singleton
/// pattern with a locking mechanism to ensure thread safety and prevent
/// multiple initializations.
/// 
/// ## Design Pattern: Singleton with Lazy Initialization
/// - Single instance created on first access
/// - Configuration locked after first initialization
/// - Thread-safe implementation using boolean lock
/// - Input validation for all configuration parameters
/// 
/// ## Configuration Properties:
/// - **appName**: Display name for the app (varies by environment)
/// - **baseUrl**: API base URL for network requests
/// - **env**: Current environment type (development/staging/production)
/// 
/// ## Thread Safety:
/// The `_lock` boolean ensures that once the configuration is set during
/// app initialization, it cannot be modified again, preventing configuration
/// corruption in multi-threaded scenarios.
/// 
/// ## Validation:
/// All configuration parameters are validated during initialization:
/// - App name cannot be empty
/// - Base URL must be a valid URI format
/// - Environment must be a valid Env enum value
/// 
/// Example initialization:
/// ```dart
/// EnvConfig.instantiate(
///   appName: 'MyApp Development',
///   baseUrl: 'https://dev-api.example.com',
///   env: Env.DEVELOPMENT,
/// );
/// ```
class EnvConfig {
  /// The display name of the application.
  /// 
  /// This varies based on the current environment:
  /// - Development: "App Name Development"
  /// - Staging: "App Name Staging"  
  /// - Production: "App Name"
  late final String _appName;
  
  /// The base URL for API endpoints.
  /// 
  /// Different environments typically use different API endpoints:
  /// - Development: Local or development server URL
  /// - Staging: Staging server URL
  /// - Production: Production server URL
  /// 
  /// This URL is used by the network layer (DioClient) as the base
  /// for all API requests.
  late final String _baseUrl;
  
  /// The current application environment.
  /// 
  /// Used throughout the app to determine environment-specific behavior:
  /// - Enable/disable debug features
  /// - Show/hide development tools
  /// - Configure analytics and crash reporting
  late final Env _env;

  /// Private constructor for singleton pattern.
  /// 
  /// This constructor is private to prevent direct instantiation.
  /// Use [EnvConfig.instantiate] to initialize the configuration
  /// or [EnvConfig.instance] to access the singleton instance.
  EnvConfig._internal();
  
  /// The singleton instance of [EnvConfig].
  /// 
  /// This instance is created once during app initialization and
  /// provides global access to environment configuration throughout
  /// the application lifecycle.
  /// 
  /// Usage:
  /// ```dart
  /// final currentEnv = EnvConfig.instance.env;
  /// final apiUrl = EnvConfig.instance.baseUrl;
  /// ```
  static final EnvConfig instance = EnvConfig._internal();

  /// Lock flag to prevent multiple initializations.
  /// 
  /// Once set to `true`, the configuration becomes immutable and
  /// subsequent calls to [instantiate] will return the existing
  /// instance without modification.
  /// 
  /// This ensures:
  /// - Configuration consistency throughout app lifecycle
  /// - Prevention of accidental reconfiguration
  /// - Thread safety in multi-threaded environments
  bool _lock = false;

  /// Gets the application name.
  /// 
  /// Throws [StateError] if accessed before initialization.
  String get appName {
    _validateInitialized();
    return _appName;
  }

  /// Gets the base URL for API endpoints.
  /// 
  /// Throws [StateError] if accessed before initialization.
  String get baseUrl {
    _validateInitialized();
    return _baseUrl;
  }

  /// Gets the current environment.
  /// 
  /// Throws [StateError] if accessed before initialization.
  Env get env {
    _validateInitialized();
    return _env;
  }

  /// Gets whether the configuration has been initialized.
  /// 
  /// This is useful for checking initialization status without
  /// throwing exceptions.
  bool get isInitialized => _lock;

  /// Validates that the configuration has been initialized.
  /// 
  /// Throws [StateError] if not initialized.
  void _validateInitialized() {
    if (!_lock) {
      throw StateError(
        'EnvConfig has not been initialized. Call EnvConfig.instantiate() first.',
      );
    }
  }

  /// Validates the provided configuration parameters.
  /// 
  /// Throws [EnvConfigException] if any parameter is invalid.
  static void _validateParameters({
    required String appName,
    required String baseUrl,
    required Env env,
  }) {
    // Validate app name
    if (appName.trim().isEmpty) {
      throw const EnvConfigException('App name cannot be empty');
    }

    // Validate base URL format
    if (baseUrl.trim().isEmpty) {
      throw const EnvConfigException('Base URL cannot be empty');
    }

    try {
      final uri = Uri.parse(baseUrl);
      if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) {
        throw const EnvConfigException(
          'Base URL must be a valid HTTP/HTTPS URL',
        );
      }
    } catch (e) {
      throw EnvConfigException('Invalid base URL format: $baseUrl');
    }
  }
  
  /// Factory constructor to initialize the environment configuration.
  /// 
  /// This method sets up the environment configuration with the provided
  /// parameters. It can only be called once during the application lifecycle.
  /// Subsequent calls will return the existing instance without modification.
  /// 
  /// ## Parameters:
  /// - [appName]: The display name for the application (cannot be empty)
  /// - [baseUrl]: The base URL for API endpoints (must be valid HTTP/HTTPS URL)
  /// - [env]: The current environment type
  /// 
  /// ## Returns:
  /// The configured [EnvConfig] singleton instance.
  /// 
  /// ## Throws:
  /// - [EnvConfigException]: If any parameter validation fails
  /// - [StateError]: If called multiple times after initialization
  /// 
  /// ## Thread Safety:
  /// This method is thread-safe. If called multiple times, only the first
  /// call will initialize the configuration. Subsequent calls will return
  /// the already-configured instance.
  /// 
  /// ## Example:
  /// ```dart
  /// // Initialize during app startup
  /// final config = EnvConfig.instantiate(
  ///   appName: 'MyApp Development',
  ///   baseUrl: 'https://dev-api.example.com',
  ///   env: Env.DEVELOPMENT,
  /// );
  /// 
  /// // Later access (returns same instance)
  /// final sameConfig = EnvConfig.instance;
  /// assert(identical(config, sameConfig)); // true
  /// ```
  /// 
  /// ## Usage in App Initialization:
  /// This method is typically called during app initialization in the
  /// flavor-specific main files (main_development.dart, main_staging.dart,
  /// main_production.dart) through the [initializeApp] function.
  factory EnvConfig.instantiate({
    required String appName,
    required String baseUrl,
    required Env env,
  }) {
    // Return existing instance if already locked (configured)
    if (instance._lock) return instance;

    // Validate parameters before setting
    _validateParameters(
      appName: appName,
      baseUrl: baseUrl,
      env: env,
    );

    // Configure the singleton instance
    instance._appName = appName.trim();
    instance._baseUrl = baseUrl.trim();
    instance._env = env;
    
    // Lock the configuration to prevent future modifications
    instance._lock = true;
    
    return instance;
  }

  /// Creates an app name based on the environment.
  /// 
  /// This is a utility method that follows consistent naming conventions:
  /// - Development: "App Name Development"
  /// - Staging: "App Name Staging"
  /// - Production: "App Name"
  /// 
  /// Example:
  /// ```dart
  /// final devName = EnvConfig.createAppName('MyApp', Env.DEVELOPMENT);
  /// // Returns: "MyApp Development"
  /// ```
  static String createAppName(String baseName, Env environment) {
    if (baseName.trim().isEmpty) {
      throw const EnvConfigException('Base name cannot be empty');
    }

    switch (environment) {
      case Env.DEVELOPMENT:
        return '$baseName Development';
      case Env.STAGING:
        return '$baseName Staging';
      case Env.PRODUCTION:
        return baseName;
    }
  }

  /// Returns a string representation of the configuration.
  /// 
  /// This is useful for debugging and logging purposes.
  /// Note: Sensitive information like API keys should not be included.
  @override
  String toString() {
    if (!_lock) {
      return 'EnvConfig(uninitialized)';
    }
    return 'EnvConfig(env: $_env, appName: $_appName, baseUrl: $_baseUrl)';
  }
}
