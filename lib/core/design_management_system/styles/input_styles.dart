import 'package:flutter/material.dart';
import 'package:flutter_specialized_temp/core/design_management_system/tokens/app_colors.dart';
import 'package:flutter_specialized_temp/core/design_management_system/tokens/app_dimensions.dart';
import 'package:flutter_specialized_temp/core/design_management_system/tokens/app_spacing.dart';

/// Pre-built input decoration presets. All measurements come from tokens.
class AppInputStyles {
  AppInputStyles._();

  static InputDecoration standard(AppColorTokens colors) {
    return InputDecoration(
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
        borderSide: BorderSide(color: colors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: BorderSide(color: colors.alert),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: BorderSide(color: colors.alert, width: 2),
      ),
      contentPadding: AppSpacing.smPadding,
      filled: true,
      fillColor: colors.surface,
    );
  }

  static InputDecoration rounded(AppColorTokens colors) {
    return standard(colors).copyWith(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusRounded),
        borderSide: BorderSide(color: colors.textSecondary),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusRounded),
        borderSide: BorderSide(color: colors.textSecondary.withAlpha(51)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusRounded),
        borderSide: BorderSide(color: colors.primary, width: 2),
      ),
    );
  }

  static InputDecoration search(AppColorTokens colors) {
    return rounded(colors).copyWith(
      hintText: 'Search...',
      prefixIcon: Icon(Icons.search, color: colors.textSecondary),
      contentPadding: AppSpacing.mdHorizontal,
    );
  }

  static InputDecoration chat(AppColorTokens colors) {
    return rounded(colors).copyWith(
      hintText: 'Type a message...',
      contentPadding: AppSpacing.mdHorizontal.add(AppSpacing.smVertical),
      suffixIcon: Icon(Icons.send, color: colors.primary),
    );
  }
}
