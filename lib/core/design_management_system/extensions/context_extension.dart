import 'package:flutter/material.dart';
import 'package:flutter_specialized_temp/core/design_management_system/tokens/app_colors.dart';

// ─── Theme & Color accessors ──────────────────────────────────────────────────

extension ThemeContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Custom semantic color tokens (success, warning, alert, background, etc.).
  /// Use `context.colorScheme` for Material-standard colors (primary, surface…).
  AppColorTokens get colors => AppColors.of(this);

  Brightness get brightness => theme.brightness;
  bool get isDarkMode => brightness == Brightness.dark;
}

// ─── Text style shorthands ────────────────────────────────────────────────────

extension TextThemeContextExtension on BuildContext {
  TextStyle? get displayLarge => Theme.of(this).textTheme.displayLarge;
  TextStyle? get displayMedium => Theme.of(this).textTheme.displayMedium;
  TextStyle? get displaySmall => Theme.of(this).textTheme.displaySmall;
  TextStyle? get headlineLarge => Theme.of(this).textTheme.headlineLarge;
  TextStyle? get headlineMedium => Theme.of(this).textTheme.headlineMedium;
  TextStyle? get headlineSmall => Theme.of(this).textTheme.headlineSmall;
  TextStyle? get titleLarge => Theme.of(this).textTheme.titleLarge;
  TextStyle? get titleMedium => Theme.of(this).textTheme.titleMedium;
  TextStyle? get titleSmall => Theme.of(this).textTheme.titleSmall;
  TextStyle? get bodyLarge => Theme.of(this).textTheme.bodyLarge;
  TextStyle? get bodyMedium => Theme.of(this).textTheme.bodyMedium;
  TextStyle? get bodySmall => Theme.of(this).textTheme.bodySmall;
  TextStyle? get labelLarge => Theme.of(this).textTheme.labelLarge;
  TextStyle? get labelMedium => Theme.of(this).textTheme.labelMedium;
  TextStyle? get labelSmall => Theme.of(this).textTheme.labelSmall;
}

// ─── Media query / layout ─────────────────────────────────────────────────────

extension LayoutContextExtension on BuildContext {
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  double get screenWidth => mediaQuery.size.width;
  double get screenHeight => mediaQuery.size.height;

  /// Safe-area insets — use to pad content away from notch / dynamic island.
  EdgeInsets get padding => mediaQuery.padding;

  /// `true` while the software keyboard is visible.
  bool get isKeyboardVisible => mediaQuery.viewInsets.bottom > 0;

  bool get isTablet => screenWidth >= 600;
}
