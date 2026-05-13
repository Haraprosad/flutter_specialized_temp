import 'package:flutter/material.dart';
import 'package:flutter_specialized_temp/core/design_management_system/styles/button_styles.dart';
import 'package:flutter_specialized_temp/core/design_management_system/themes/app_color_scheme.dart';
import 'package:flutter_specialized_temp/core/design_management_system/tokens/app_colors.dart';
import 'package:flutter_specialized_temp/core/design_management_system/tokens/app_dimensions.dart';
import 'package:flutter_specialized_temp/core/design_management_system/tokens/app_spacing.dart';
import 'package:flutter_specialized_temp/core/design_management_system/tokens/app_typography.dart';

/// Assembles [ThemeData] from design tokens and style presets.
/// No hardcoded values — every measurement comes from a token.
class AppTheme {
  AppTheme._();

  static ThemeData lightTheme() => _buildTheme(
        colorScheme: AppColorScheme.light,
        colors: AppColors.light,
      );

  static ThemeData darkTheme() => _buildTheme(
        colorScheme: AppColorScheme.dark,
        colors: AppColors.dark,
      );

  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required AppColorTokens colors,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      textTheme: AppTypography.buildTextTheme(colors),
      scaffoldBackgroundColor: colors.background,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: colors.surface,
        foregroundColor: colors.textPrimary,
        iconTheme: IconThemeData(color: colors.textPrimary),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: colors.surface,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(
            right: Radius.circular(AppDimensions.radiusMd),
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        contentPadding: AppSpacing.mdHorizontal.add(AppSpacing.smVertical),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: colors.primary,
        unselectedLabelColor: colors.textSecondary,
        indicatorColor: colors.primary,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: AppDimensions.elevationCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        color: colors.surface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: AppButtonStyles.elevated(colors),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: AppButtonStyles.outlined(colors),
      ),
      textButtonTheme: TextButtonThemeData(
        style: AppButtonStyles.text(colors),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: BorderSide(color: colors.textSecondary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: BorderSide(color: colors.textSecondary.withAlpha(51)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: BorderSide(color: colors.primary),
        ),
        contentPadding: AppSpacing.smPadding,
        filled: true,
        fillColor: colors.surface,
      ),
    );
  }
}
