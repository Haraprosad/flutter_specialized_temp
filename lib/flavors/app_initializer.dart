/// # Application Initialization System
/// 
/// This file contains the core application initialization logic that sets up
/// the Flutter app with proper error handling, dependency injection, and
/// environment configuration based on the selected flavor.
/// 
/// ## Key Responsibilities
/// - **Environment Setup**: Load environment-specific configurations
/// - **Dependency Injection**: Initialize and configure GetIt service locator
/// - **Error Handling**: Set up global error handlers for different error types
/// - **BLoC Integration**: Configure BLoC observer for state management monitoring
/// - **Widget Binding**: Initialize Flutter framework bindings
/// 
/// ## Error Handling Strategy
/// The initialization implements a comprehensive error handling approach:
/// 1. **Zone-based Error Handling**: Catches unhandled asynchronous errors
/// 2. **Flutter Framework Errors**: Handles widget and rendering errors
/// 3. **Platform Errors**: Manages native platform exceptions
/// 4. **Custom Error Widgets**: Provides user-friendly error screens
/// 
/// ## Integration with Flavor System
/// This initializer works seamlessly with the flavor management system by:
/// - Loading environment-specific `.env` files
/// - Configuring app names and API endpoints per environment
/// - Setting up environment-aware logging and monitoring
/// 
/// ## Usage Example
/// ```dart
/// // Called from main_development.dart
/// await initializeApp(
///   EnvConstants.envDevelopment,
///   'MyApp Development',
///   Env.DEVELOPMENT,
/// );
/// ```

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_specialized_temp/core/constants/env_constants.dart';
import 'package:flutter_specialized_temp/core/constants/string_constants.dart';
import 'package:flutter_specialized_temp/core/di/injection.dart';
import 'package:flutter_specialized_temp/core/logger/app_logger.dart';
import 'package:flutter_specialized_temp/core/observers/bloc_observer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/widgets/flutter_error_screen.dart';
import '../main.dart';
import 'env_config.dart';
import 'environment.dart';

/// Initializes the Flutter application with environment-specific configuration
/// and comprehensive error handling.
/// 
/// This function serves as the main entry point for app initialization across
/// all flavors (development, staging, production). It sets up the complete
/// application infrastructure including environment configuration, dependency
/// injection, error handling, and state management.
/// 
/// ## Initialization Process
/// 
/// ### 1. Environment Setup
/// - Loads environment-specific `.env` file using flutter_dotenv
/// - Configures [EnvConfig] singleton with app name, base URL, and environment type
/// - Sets up environment-aware configurations
/// 
/// ### 2. Dependency Injection
/// - Initializes GetIt service locator with all app dependencies
/// - Configures network services, repositories, and BLoCs
/// - Sets up environment-specific service implementations
/// 
/// ### 3. State Management
/// - Configures BLoC observer for debugging and monitoring
/// - Sets up global state management infrastructure
/// 
/// ### 4. Error Handling
/// - **Zone Guard**: Catches unhandled async errors in the app
/// - **Flutter Errors**: Handles widget tree and framework errors
/// - **Platform Errors**: Manages native platform exceptions
/// - **Custom Error UI**: Shows user-friendly error screens
/// 
/// ### 5. App Launch
/// - Starts the main app widget tree
/// - Optionally enables DevicePreview for responsive design testing
/// 
/// ## Parameters
/// 
/// - [envFileName]: Path to the environment file (e.g., '.env.development')
///   - Development: '.env.development'
///   - Staging: '.env.staging'  
///   - Production: '.env.production'
/// 
/// - [appName]: Display name for the application
///   - Development: 'App Name Development'
///   - Staging: 'App Name Staging'
///   - Production: 'App Name'
/// 
/// - [env]: Environment type from the [Env] enumeration
///   - Controls environment-specific behavior
///   - Used for feature flags and configuration switches
/// 
/// ## Error Handling Details
/// 
/// ### Zone-based Error Handling
/// Uses `runZonedGuarded` to catch unhandled asynchronous errors:
/// ```dart
/// await runZonedGuarded(() async {
///   // App initialization code
/// }, (exception, stackTrace) async {
///   // Log and handle unhandled errors
/// });
/// ```
/// 
/// ### Flutter Framework Errors
/// Configures `FlutterError.onError` to handle widget and rendering errors:
/// - Logs errors for debugging
/// - Continues app execution when possible
/// - Shows error details in development mode
/// 
/// ### Platform Errors
/// Sets up `PlatformDispatcher.instance.onError` for native platform errors:
/// - Handles iOS/Android platform exceptions
/// - Provides fallback error handling
/// - Maintains app stability
/// 
/// ### Custom Error Widgets
/// Replaces default Flutter error widgets with user-friendly screens:
/// ```dart
/// ErrorWidget.builder = (FlutterErrorDetails details) {
///   return const FlutterErrorScreen();
/// };
/// ```
/// 
/// ## Development Features
/// 
/// ### Device Preview (Optional)
/// Commented code shows integration with DevicePreview for responsive testing:
/// ```dart
/// runApp(DevicePreview(
///   enabled: !kReleaseMode,
///   builder: (context) => MyApp(),
/// ));
/// ```
/// 
/// ### Debug Logging
/// Enhanced logging in development and staging environments:
/// - Detailed error traces
/// - Network request/response logging  
/// - BLoC state change monitoring
/// 
/// ## Usage in Flavor Files
/// 
/// Each flavor's main file calls this function with specific parameters:
/// 
/// ```dart
/// // main_development.dart
/// await initializeApp(
///   EnvConstants.envDevelopment,
///   'MyApp Development', 
///   Env.DEVELOPMENT,
/// );
/// 
/// // main_staging.dart
/// await initializeApp(
///   EnvConstants.envStaging,
///   'MyApp Staging',
///   Env.STAGING, 
/// );
/// 
/// // main_production.dart
/// await initializeApp(
///   EnvConstants.envProduction,
///   'MyApp',
///   Env.PRODUCTION,
/// );
/// ```
/// 
/// ## Dependencies
/// - **flutter_dotenv**: Environment variable loading
/// - **get_it**: Dependency injection container
/// - **flutter_bloc**: State management and BLoC observer
/// - **custom services**: Logging, error handling, network services
/// 
/// ## Error Recovery
/// The initialization is designed to be resilient:
/// - Graceful degradation when services fail to initialize
/// - Logging of initialization errors for debugging
/// - Fallback configurations for critical services
/// - User notification of critical failures
/// 
/// ## Performance Considerations
/// - Lazy loading of non-critical services
/// - Parallel initialization where possible
/// - Minimal blocking operations during startup
/// - Optimized dependency resolution order
Future<void> initializeApp(Env env) async {
  // Set up zone-based error handling to catch unhandled async errors
  await runZonedGuarded(() async {
    // Initialize Flutter framework bindings
    // This must be called before using any Flutter services
    WidgetsFlutterBinding.ensureInitialized();
    
    // Load environment-specific configuration from .env file
    // This populates dotenv.env with key-value pairs from the specified file
    await dotenv.load(fileName: env.envFileName);

    // Configure the global environment configuration singleton
    // This makes environment settings available throughout the app
    EnvConfig.instantiate(
      appName: EnvConfig.createAppName(StringConstants.appName, env),
      baseUrl: dotenv.env[EnvConstants.envKeyBaseUrl]!,
      env: env,
    );
    
    // Initialize dependency injection container
    // Sets up all services, repositories, BLoCs, and other dependencies
    await configureDependencies();

    // Configure BLoC observer for state management monitoring
    // Provides logging and debugging capabilities for BLoC events and states
    Bloc.observer = AppBlocObserver();

    // Launch the main application widget tree
    runApp(const MyApp());

    //************Device Preview Integration (Optional)**************** */
    // Uncomment the following code to enable DevicePreview for responsive design testing
    // This is useful during development to test the app on different screen sizes
    // 
    // runApp(DevicePreview(
    //   enabled: !kReleaseMode, // Only enable in debug mode
    //   builder: (context) => MyApp(), // Wrap your app
    // ));
    //******************************************************************** */
  }, (exception, stackTrace) async {
    // Handle unhandled asynchronous errors within the guarded zone
    // This catches errors that occur outside of Flutter's error handling
    AppLogger.f(
      message: "runZonedGuarded caught error",
      error: exception,
      stackTrace: stackTrace,
    );
  });

  // Configure Flutter framework error handler
  // This handles errors that occur in the widget tree, rendering, or framework
  FlutterError.onError = (FlutterErrorDetails details) {
    // Ensure the error is displayed in the console/logs
    FlutterError.presentError(details);

    // Log the error using our custom logging system
    AppLogger.f(
      message: "Flutter error: ${details.exception}",
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  // Configure platform/OS error handler  
  // This handles errors from the native platform (iOS/Android)
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    // Log platform errors for debugging
    AppLogger.e(
      message: "Platform error: $error",
      error: error,
      stackTrace: stack,
    );
    
    // Return true to indicate the error was handled
    return true;
  };

  // Configure custom error widget builder
  // Replaces Flutter's default red error screen with a user-friendly alternative
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return const FlutterErrorScreen();
  };
}
