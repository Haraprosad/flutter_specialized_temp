import 'package:flutter/material.dart';
import 'package:flutter_specialized_temp/core/theme/colors/theme_colors.dart';
import 'package:flutter_specialized_temp/core/theme/constants/app_sizes.dart';

/// Extension to access custom theme colors directly from BuildContext
extension ThemeColorsExtension on BuildContext {
  ThemeColors get colors {
    final brightness = Theme.of(this).brightness;
    return brightness == Brightness.light
        ? const ThemeColors(
            primary: Color(0xFF0066CC),
            secondary: Color(0xFFD93025),
            success: Color(0xFF2E7D32),
            background: Color(0xFFFFFFFF),
            surface: Color(0xFFF5F5F5),
            textPrimary: Color(0xFF212121),
            textSecondary: Color(0xFF757575),
            warning: Color(0xFFFFC107),
            alert: Color(0xFFFF9800),
          )
        : const ThemeColors(
            primary: Color(0xFF338DFF),
            secondary: Color(0xFFFF4545),
            success: Color(0xFF4CAF50),
            background: Color(0xFF121212),
            surface: Color(0xFF1E1E1E),
            textPrimary: Color(0xFFE1E1E1),
            textSecondary: Color(0xFFB0B0B0),
            warning: Color(0xFFFFC107),
            alert: Color(0xFFFF9800),
          );
  }
}

/// Extension to access spacing system from BuildContext
extension SpacingExtension on BuildContext {
  // Remove the getter that tries to instantiate AppSpacing
  // AppSpacing get spacing => AppSpacing();
}

/// Extension to access sizing system from BuildContext
extension SizingExtension on BuildContext {
  // Remove the getter that tries to instantiate AppSizes
  // AppSizes get sizes => AppSizes();
}

/// Extension for common theme-based widgets
extension ThemeWidgetsExtension on BuildContext {
  // Dividers
  Widget get thinDivider => Divider(
        height: 1,
        thickness: 0.5,
        color: colors.textSecondary.withOpacity(0.2),
      );

  Widget get thickDivider => Divider(
        height: 2,
        thickness: 1,
        color: colors.textSecondary.withOpacity(0.3),
      );

  // Loading indicators
  Widget get circularLoader => CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
      );

  // Common containers
  Widget cardContainer({required Widget child}) => Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          boxShadow: [
            BoxShadow(
              color: colors.textSecondary.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: child,
      );
}
