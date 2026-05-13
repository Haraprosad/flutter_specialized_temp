import 'package:flutter/material.dart';
import 'package:flutter_specialized_temp/core/design_management_system/tokens/app_colors.dart';

/// Light and dark [ColorScheme] definitions — the only place theme color
/// mapping is defined.
///
/// Consumes [AppColors] tokens. No hex literals here.
class AppColorScheme {
  AppColorScheme._();

  static ColorScheme get light => ColorScheme.fromSeed(
        seedColor: AppColors.light.primary,
        brightness: Brightness.light,
        primary: AppColors.light.primary,
        secondary: AppColors.light.secondary,
        surface: AppColors.light.surface,
        onSurface: AppColors.light.textPrimary,
        error: AppColors.light.alert,
        surfaceTint: AppColors.light.primary.withAlpha(26),
      );

  static ColorScheme get dark => ColorScheme.fromSeed(
        seedColor: AppColors.dark.primary,
        brightness: Brightness.dark,
        primary: AppColors.dark.primary,
        secondary: AppColors.dark.secondary,
        surface: AppColors.dark.surface,
        onSurface: AppColors.dark.textPrimary,
        error: AppColors.dark.alert,
        surfaceTint: AppColors.dark.primary.withAlpha(26),
      );
}
