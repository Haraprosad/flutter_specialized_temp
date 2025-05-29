import 'package:flutter/material.dart';
import 'package:flutter_specialized_temp/core/theme/colors/theme_colors.dart';
import 'package:flutter_specialized_temp/core/theme/constants/app_sizes.dart';
import 'package:flutter_specialized_temp/core/theme/constants/theme_constants.dart';
import 'package:flutter_specialized_temp/core/theme/constants/app_spacing.dart';

class InputDecorationStyles {
  InputDecorationStyles._();

  static InputDecoration standard(ThemeColors colors) {
    return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        borderSide: BorderSide(color: colors.textSecondary),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        borderSide: BorderSide(color: colors.textSecondary.withAlpha(51)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        borderSide: BorderSide(color: colors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        borderSide: BorderSide(color: colors.alert),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        borderSide: BorderSide(color: colors.alert, width: 2),
      ),
      contentPadding: AppSpacing.smPadding,
      filled: true,
      fillColor: colors.surface,
    );
  }

  static InputDecoration rounded(ThemeColors colors) {
    return standard(colors).copyWith(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide(color: colors.textSecondary),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide(color: colors.textSecondary.withAlpha(51)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide(color: colors.primary, width: 2),
      ),
    );
  }

  static InputDecoration search(ThemeColors colors) {
    return rounded(colors).copyWith(
      hintText: 'Search...',
      prefixIcon: Icon(Icons.search, color: colors.textSecondary),
      contentPadding: AppSpacing.mdHorizontal,
    );
  }

  static InputDecoration chat(ThemeColors colors) {
    return rounded(colors).copyWith(
      hintText: 'Type a message...',
      contentPadding: AppSpacing.mdHorizontal.add(AppSpacing.smVertical),
      suffixIcon: Icon(Icons.send, color: colors.primary),
    );
  }
}
