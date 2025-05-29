/// # Development Flavor Entry Point
/// 
/// This file serves as the main entry point for the **Development** flavor of the
/// Flutter application. It configures and launches the app with development-specific
/// settings optimized for active development work.
/// 
/// ## Development Environment Features
/// 
/// ### Debug Capabilities
/// - **Hot Reload**: Full hot reload support for rapid development
/// - **Debug Logging**: Verbose logging enabled for all app operations
/// - **Development Tools**: Flutter Inspector and debugging tools available
/// - **Error Details**: Detailed error information and stack traces
/// 
/// ### API Configuration
/// - **Development Server**: Points to local or development API endpoints
/// - **Mock Data**: May include mock data for testing features
/// - **Debug Headers**: Additional headers for API debugging
/// - **Flexible Timeouts**: Longer timeouts for debugging network calls
/// 
/// ### Performance Monitoring
/// - **Debug Overlays**: Performance overlays and debug information
/// - **Memory Monitoring**: Enhanced memory usage tracking
/// - **Widget Inspector**: Full widget tree inspection capabilities
/// 
/// ## Environment Configuration
/// 
/// ### .env.development File
/// This flavor loads configuration from `.env.development` which typically contains:
/// ```env
/// BASE_URL=https://dev-api.yourapp.com
/// API_KEY=development_api_key
/// ENABLE_LOGGING=true
/// MOCK_DATA=true
/// ```
/// 
/// ### App Naming
/// - **App Name**: "Development App" (or your custom development app name)
/// - **Bundle ID**: Separate development bundle identifier
/// - **App Icon**: Development-specific app icon (if configured)
/// 
/// ## Build Configuration
/// 
/// ### Flutter Build Commands
/// To build and run the development flavor:
/// 
/// ```bash
/// # Run development flavor
/// flutter run -t lib/flavors/main_development.dart
/// 
/// # Build development APK
/// flutter build apk -t lib/flavors/main_development.dart
/// 
/// # Build development iOS
/// flutter build ios -t lib/flavors/main_development.dart
/// ```
/// 
/// ### IDE Configuration
/// In your IDE (VS Code/Android Studio), create a launch configuration:
/// ```json
/// {
///   "name": "Development",
///   "type": "dart", 
///   "request": "launch",
///   "program": "lib/flavors/main_development.dart"
/// }
/// ```
/// 
/// ## Development Workflow
/// 
/// ### 1. Environment Setup
/// - Ensure `.env.development` file exists with proper configuration
/// - Start local development server (if using local APIs)
/// - Configure development database connections
/// 
/// ### 2. Running the App
/// - Use this file as the entry point for development
/// - Enable hot reload for rapid iteration
/// - Monitor debug console for logs and errors
/// 
/// ### 3. Testing Features
/// - All debugging features are enabled
/// - Mock data can be used for testing
/// - Development-specific analytics and logging
/// 
/// ## Integration with CI/CD
/// 
/// ### Automated Testing
/// ```yaml
/// # GitHub Actions example
/// - name: Test Development Flavor
///   run: flutter test
///   env:
///     FLUTTER_TARGET: lib/flavors/main_development.dart
/// ```
/// 
/// ### Development Builds
/// Development builds can be automatically deployed to internal testing:
/// - Firebase App Distribution
/// - TestFlight (iOS)
/// - Internal app stores
/// 
/// ## Security Considerations
/// 
/// ### Development-Safe Features
/// - Development API keys (non-production)
/// - Local or staging database connections
/// - Enhanced logging (may include sensitive data for debugging)
/// - Bypassed authentication for testing (if implemented)
/// 
/// ### Production Differences
/// - Different SSL certificate pinning (if any)
/// - Development-specific feature flags
/// - Enhanced error reporting and debugging
/// 
/// ## Troubleshooting
/// 
/// ### Common Issues
/// 1. **Environment File Missing**: Ensure `.env.development` exists
/// 2. **API Connection**: Verify development server is running
/// 3. **Dependencies**: Run `flutter pub get` after flavor changes
/// 4. **Hot Reload Issues**: Restart the app if hot reload fails
/// 
/// ### Debug Tools
/// - Flutter Inspector for widget debugging
/// - Network inspector for API calls
/// - Performance overlay for optimization
/// - Memory profiler for leak detection

import 'package:flutter_specialized_temp/core/constants/env_constants.dart';
import 'package:flutter_specialized_temp/flavors/app_initializer.dart';
import 'package:flutter_specialized_temp/flavors/environment.dart';

/// Main entry point for the Development flavor of the application.
/// 
/// This function initializes and launches the Flutter app configured for
/// development environment with debug features, development API endpoints,
/// and enhanced logging capabilities.
/// 
/// ## Initialization Parameters
/// 
/// ### Environment File
/// - **File**: [Env.DEVELOPMENT.envFileName] (`.env.development`)
/// - **Purpose**: Contains development-specific configuration variables
/// - **Variables**: API endpoints, feature flags, debug settings
/// 
/// ### App Name
/// - **Name**: Uses [EnvConfig.createAppName] for consistent naming
/// - **Purpose**: Distinguishes development builds from other flavors
/// - **Display**: Shown in app launcher and system settings
/// 
/// ### Environment Type
/// - **Type**: [Env.DEVELOPMENT]
/// - **Purpose**: Enables development-specific features and behaviors
/// - **Features**: Debug logging, development tools, mock data
/// 
/// ## Development Features Enabled
/// 
/// When this flavor is launched, the following development features are enabled:
/// 
/// ### Debugging & Logging
/// - Verbose logging for all app operations
/// - Detailed error messages and stack traces
/// - Network request/response logging
/// - BLoC state change monitoring
/// 
/// ### Development Tools
/// - Flutter Inspector integration
/// - Hot reload and hot restart support
/// - Debug overlays and performance monitoring
/// - Widget tree inspection
/// 
/// ### API & Networking
/// - Development server endpoints
/// - Extended timeout values for debugging
/// - Additional debug headers
/// - Mock data integration (if configured)
/// 
/// ### Error Handling
/// - Detailed error screens with stack traces
/// - Development-friendly error messages
/// - Enhanced crash reporting
/// - Debug information preservation
/// 
/// ## Usage Examples
/// 
/// ### Command Line
/// ```bash
/// # Run development flavor
/// flutter run -t lib/flavors/main_development.dart
/// 
/// # Run with specific device
/// flutter run -t lib/flavors/main_development.dart -d <device_id>
/// 
/// # Run with hot reload enabled (default)
/// flutter run -t lib/flavors/main_development.dart --hot
/// ```
/// 
/// ### IDE Launch Configuration
/// Configure your IDE to use this file as the entry point for development builds.
/// 
/// ## Environment Variables Expected
/// 
/// The `.env.development` file should contain:
/// ```env
/// BASE_URL=https://dev-api.yourapp.com
/// API_KEY=development_api_key_here
/// ENABLE_LOGGING=true
/// DEBUG_MODE=true
/// MOCK_DATA=false
/// ```
/// 
/// ## Build Outputs
/// 
/// Development builds will have:
/// - Development-specific app name and identifier
/// - Debug symbols included
/// - Development certificates/signing
/// - Enhanced debugging capabilities
/// 
/// ## Performance Considerations
/// 
/// Development builds prioritize debugging over performance:
/// - Additional logging overhead
/// - Debug information preservation
/// - Hot reload infrastructure
/// - Development tool integration
/// 
/// For performance testing, consider using staging or production flavors.
void main() async {
  const environment = Env.DEVELOPMENT;
  await initializeApp(environment);
}
