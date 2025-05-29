/// # Flutter App Flavor Management System
/// 
/// This file defines the core environment types for the Flutter application's
/// flavor management system. The flavor system allows developers to maintain
/// different configurations for development, staging, and production environments.
/// 
/// ## Purpose
/// - Define environment types for different app flavors
/// - Enable configuration switching between build environments
/// - Support multi-environment deployment strategies
/// 
/// ## Usage Example
/// ```dart
/// // Check current environment
/// if (EnvConfig.instance.env == Env.DEVELOPMENT) {
///   // Development-specific code
/// }
/// ```
/// 
/// ## Related Files
/// - `env_config.dart` - Configuration management for environments
/// - `app_initializer.dart` - App initialization with environment setup
/// - `main_development.dart` - Development environment entry point
/// - `main_staging.dart` - Staging environment entry point
/// - `main_production.dart` - Production environment entry point

/// Enumeration defining the available application environments.
/// 
/// This enum is used throughout the flavor management system to identify
/// the current build environment and apply appropriate configurations.
/// 
/// ## Environment Types:
/// - **DEVELOPMENT**: Used during active development with debug features enabled
/// - **STAGING**: Pre-production environment for testing and QA
/// - **PRODUCTION**: Live production environment for end users
/// 
/// ## Implementation Notes:
/// - Each environment has its own `.env` file for configuration
/// - Different API endpoints can be used per environment
/// - Debug features are typically disabled in PRODUCTION
/// 
/// Example usage:
/// ```dart
/// switch (EnvConfig.instance.env) {
///   case Env.DEVELOPMENT:
///     // Enable debug logging
///     break;
///   case Env.STAGING:
///     // Enable limited analytics
///     break;
///   case Env.PRODUCTION:
///     // Full production features
///     break;
/// }
/// ```
enum Env { 
  /// Development environment for active development.
  /// 
  /// Features:
  /// - Debug logging enabled
  /// - Development API endpoints
  /// - Mock data may be used
  /// - Hot reload and debugging tools available
  DEVELOPMENT, 
  
  /// Staging environment for pre-production testing.
  /// 
  /// Features:
  /// - Production-like configuration
  /// - QA and testing focused
  /// - May use staging API endpoints
  /// - Limited debug information
  STAGING, 
  
  /// Production environment for end users.
  /// 
  /// Features:
  /// - Optimized performance
  /// - Production API endpoints
  /// - Error reporting enabled
  /// - Debug features disabled
  PRODUCTION;

  /// Returns the environment file name for this environment.
  /// 
  /// This follows the DRY principle by centralizing file name logic
  /// and eliminating the need for separate constants.
  String get envFileName {
    switch (this) {
      case Env.DEVELOPMENT:
        return '.env.development';
      case Env.STAGING:
        return '.env.staging';
      case Env.PRODUCTION:
        return '.env.production';
    }
  }

  /// Returns the display name for this environment.
  /// 
  /// Used for app naming and debugging purposes.
  String get displayName {
    switch (this) {
      case Env.DEVELOPMENT:
        return 'Development';
      case Env.STAGING:
        return 'Staging';
      case Env.PRODUCTION:
        return 'Production';
    }
  }

  /// Indicates whether debug features should be enabled.
  /// 
  /// This provides a convenient way to check debug status
  /// without repetitive switch statements throughout the codebase.
  bool get isDebugMode {
    switch (this) {
      case Env.DEVELOPMENT:
        return true;
      case Env.STAGING:
        return false;
      case Env.PRODUCTION:
        return false;
    }
  }

  /// Indicates whether this is a production environment.
  /// 
  /// Useful for enabling/disabling production-specific features
  /// like analytics, crash reporting, etc.
  bool get isProduction => this == Env.PRODUCTION;

  /// Indicates whether this is a development environment.
  /// 
  /// Useful for enabling development-specific features
  /// like mock data, debug overlays, etc.
  bool get isDevelopment => this == Env.DEVELOPMENT;

  /// Indicates whether this is a staging environment.
  /// 
  /// Useful for enabling staging-specific features
  /// like QA tools, testing configurations, etc.
  bool get isStaging => this == Env.STAGING;
}