/// # Device Preview Entry Point
///
/// This file serves as a specialized entry point for responsive design testing
/// using the Device Preview package. It allows developers to test the app's
/// responsive behavior across multiple device sizes and orientations while
/// maintaining the ability to switch between different flavors.
///
/// ## Device Preview Features
///
/// ### Multi-Device Testing
/// - **Phone Sizes**: iPhone SE, iPhone 12 Pro, Pixel 4, etc.
/// - **Tablet Sizes**: iPad, iPad Pro, Android tablets
/// - **Desktop Sizes**: Various desktop screen resolutions
/// - **Custom Sizes**: Define custom screen dimensions
///
/// ### Orientation Testing
/// - **Portrait Mode**: Standard vertical orientation
/// - **Landscape Mode**: Horizontal orientation testing
/// - **Auto-Rotation**: Test orientation changes
///
/// ### Interactive Features
/// - **Live Preview**: Real-time responsive changes
/// - **Device Frame**: Realistic device bezels and notches
/// - **Touch Simulation**: Test touch interactions
/// - **Keyboard Simulation**: Virtual keyboard testing
///
/// ## Flavor Integration
///
/// This preview supports all three flavors with easy switching:
/// - **Development**: Full debugging with responsive testing
/// - **Staging**: Production-like testing with responsive validation
/// - **Production**: Final responsive verification
///
/// ## Environment Configuration
///
/// ### Current Setup
/// - **Default Flavor**: Development (for debugging convenience)
/// - **Design Size**: 411 x 869 (iPhone 11 Pro reference)
/// - **Responsive Units**: Full ScreenUtil integration
/// - **Live Updates**: Hot reload support maintained
///
/// ## Usage Instructions
///
/// ### Running Device Preview
/// ```bash
/// # Run with Device Preview
/// flutter run -t lib/flavors/main_preview.dart
///
/// # Run on specific device with preview
/// flutter run -t lib/flavors/main_preview.dart -d chrome
/// ```
///
/// ### Switching Flavors
/// Modify the `selectedFlavor` constant below to test different environments:
/// ```dart
/// const Env selectedFlavor = Env.DEVELOPMENT; // Change as needed
/// ```
///
/// ### Testing Workflow
/// 1. Launch with Device Preview
/// 2. Select target devices from preview panel
/// 3. Test responsive behavior across sizes
/// 4. Verify overflow handling and text scaling
/// 5. Test orientation changes
/// 6. Switch flavors to test environment-specific UI
///
/// ## Device Preview Controls
///
/// ### Device Selection
/// - Use the device list panel to switch between devices
/// - Test both iOS and Android device sizes
/// - Include tablet and desktop sizes in testing
///
/// ### Settings Panel
/// - **Locale**: Test different language layouts
/// - **Theme**: Switch between light/dark modes
/// - **Text Scale**: Test accessibility text scaling
/// - **Safe Area**: Toggle safe area simulation
///
/// ## Integration with Responsive Design Guide
///
/// This preview tool works seamlessly with the responsive design guidelines:
/// - Validates `.sp`, `.w`, `.h`, `.r` usage
/// - Tests overflow prevention strategies
/// - Verifies text scaling behavior
/// - Confirms layout adaptation
///
/// ## Performance Considerations
///
/// ### Development Mode Only
/// Device Preview is automatically disabled in release builds to prevent
/// performance impact in production applications.
///
/// ### Memory Usage
/// Preview mode uses additional memory for device simulation. Monitor
/// performance on lower-end development machines.
///
/// ## Troubleshooting
///
/// ### Common Issues
/// 1. **Preview Not Showing**: Ensure device_preview is in dev_dependencies
/// 2. **Hot Reload Issues**: Restart preview if hot reload stops working
/// 3. **Layout Issues**: Check responsive units usage (.sp, .w, .h, .r)
/// 4. **Performance**: Close preview when not testing responsiveness

import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_specialized_temp/core/di/injection.dart';
import 'package:flutter_specialized_temp/core/localization/bloc/locale_bloc.dart';
import 'package:flutter_specialized_temp/core/localization/extension/loc.dart';
import 'package:flutter_specialized_temp/core/network/services/localization_service/localization_service.dart';
import 'package:flutter_specialized_temp/core/router/app_router.dart';
import 'package:flutter_specialized_temp/core/theme/base/app_theme.dart';
import 'package:flutter_specialized_temp/core/theme/bloc/theme_bloc.dart';
import 'package:flutter_specialized_temp/features/dlt_auth/presentation/bloc/bloc/auth_bloc.dart';
import 'flavors/app_initializer.dart';
import 'flavors/environment.dart';

/// ## Flavor Selection for Testing
///
/// Change this constant to test different flavors with Device Preview:
/// - `Env.DEVELOPMENT`: For development environment testing
/// - `Env.STAGING`: For staging environment testing
/// - `Env.PRODUCTION`: For production environment testing
///
/// This allows you to verify responsive design across all environments
/// and ensure consistency between flavors.
const Env selectedFlavor = Env.DEVELOPMENT;

/// Main entry point for Device Preview responsive design testing.
///
/// This function initializes the Flutter app with Device Preview enabled,
/// allowing comprehensive testing of responsive design across multiple
/// device sizes and orientations while maintaining full flavor support.
///
/// ## Device Preview Integration
///
/// ### Preview Configuration
/// - **Enabled**: Only in debug mode (!kReleaseMode)
/// - **Devices**: All built-in Device Preview devices available
/// - **Features**: Orientation, locale, theme, text scale testing
/// - **Performance**: Optimized for development use
///
/// ### Responsive Testing Features
/// - Real-time responsive unit testing (.sp, .w, .h, .r)
/// - Overflow detection across device sizes
/// - Text scaling verification
/// - Layout adaptation validation
/// - Safe area testing
///
/// ## Flavor Testing Capability
///
/// By changing the [selectedFlavor] constant, you can test:
/// - Different API endpoints per environment
/// - Environment-specific UI configurations
/// - Flavor-based feature flags
/// - Environment-aware theming
///
/// ## Usage for Responsive Design Validation
///
/// ### Testing Process
/// 1. Launch: `flutter run -t lib/flavors/main_preview.dart`
/// 2. Select devices from the preview panel
/// 3. Navigate through all app screens
/// 4. Verify responsive behavior on each device
/// 5. Test orientation changes
/// 6. Check text scaling and overflow handling
///
/// ### Device Categories to Test
/// - **Small Phones**: iPhone SE, smaller Android devices
/// - **Standard Phones**: iPhone 12 Pro, Pixel 4
/// - **Large Phones**: iPhone 12 Pro Max, large Android devices
/// - **Tablets**: iPad, Android tablets
/// - **Desktop**: Various desktop resolutions
///
/// ## Integration with ScreenUtil
///
/// Device Preview works seamlessly with ScreenUtil configuration:
/// - Design size: 411 x 869 (maintained across all devices)
/// - Responsive units scale appropriately
/// - Text adaptation enabled for accessibility
/// - Layout consistency verified across sizes
void main() async {
  await initializeApp(selectedFlavor);

  runApp(
    DevicePreview(
      enabled: !kReleaseMode, // Only enabled in debug mode
      builder: (context) => const MyPreviewApp(),
    ),
  );
}

/// Preview-enabled app widget with full responsive design support.
///
/// This widget wraps the main app with Device Preview capabilities while
/// maintaining all the original app functionality including:
/// - Multi-flavor support
/// - Theme management
/// - Localization
/// - State management
/// - Responsive design system
class MyPreviewApp extends StatelessWidget {
  const MyPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(411, 869), // Consistent with main app
      minTextAdapt: true, // Enable text scaling for accessibility
      builder: (_, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<ThemeBloc>(
              create: (context) =>
                  sl<ThemeBloc>()..add(const InitializeTheme()),
            ),
            BlocProvider<LocaleBloc>(
              create: (context) => sl<LocaleBloc>(),
            ),
            BlocProvider<AuthBloc>(
              create: (context) => sl<AuthBloc>(),
            ),
          ],
          child: const PreviewAppView(),
        );
      },
    );
  }
}

/// App view with Device Preview integration.
///
/// This widget configures the MaterialApp with Device Preview support
/// while maintaining all responsive design capabilities and theme/locale management.
class PreviewAppView extends StatelessWidget {
  const PreviewAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return BlocBuilder<LocaleBloc, LocaleState>(
          builder: (context, localeState) {
            return MaterialApp.router(
              // Device Preview Integration
              useInheritedMediaQuery: true, // Required for Device Preview
              locale:
                  DevicePreview.locale(context), // Use Device Preview locale

              // Standard App Configuration
              routerConfig: sl<AppRouter>().routerConfig,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              title: 'Flutter Responsive Preview - ${selectedFlavor.name}',
              themeMode: themeState.themeMode,
              theme: AppTheme.lightTheme(),
              darkTheme: AppTheme.darkTheme(),

              // Combined builder for Device Preview and EasyLoading
              builder: (context, child) {
                // Get theme colors for EasyLoading
                final theme = Theme.of(context);
                final primaryColor = theme.colorScheme.primary;
                final backgroundColor = theme.colorScheme.surface;
                final textColor = theme.colorScheme.primary;

                // Configure EasyLoading with theme colors
                EasyLoading.instance
                  ..backgroundColor = backgroundColor
                  ..indicatorColor = primaryColor
                  ..textColor = textColor
                  ..progressColor = primaryColor
                  ..userInteractions = false
                  ..loadingStyle = EasyLoadingStyle.custom;

                // Setup localization service
                if (AppLocalizations.of(context) != null) {
                  sl<LocalizationService>()
                      .setLocalizations(AppLocalizations.of(context)!);
                }

                // First apply EasyLoading wrapper
                final easyLoadingChild = EasyLoading.init()(context, child);

                // Then apply Device Preview wrapper
                return DevicePreview.appBuilder(context, easyLoadingChild);
              },
            );
          },
        );
      },
    );
  }
}
