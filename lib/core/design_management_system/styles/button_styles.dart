import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_specialized_temp/core/design_management_system/tokens/app_colors.dart';
import 'package:flutter_specialized_temp/core/design_management_system/tokens/app_dimensions.dart';
import 'package:flutter_specialized_temp/core/design_management_system/tokens/app_spacing.dart';

/// Pre-built button style presets. All measurements come from tokens.
class AppButtonStyles {
  AppButtonStyles._();

  static ButtonStyle elevated(AppColorTokens colors) {
    return ElevatedButton.styleFrom(
      backgroundColor: colors.primary,
      foregroundColor: colors.surface,
      elevation: AppDimensions.elevationButton,
      shadowColor: colors.primary.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      padding: AppSpacing.paddingButtonElevated,
      textStyle: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  static ButtonStyle outlined(AppColorTokens colors) {
    return OutlinedButton.styleFrom(
      padding: AppSpacing.paddingButtonOutlined,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      side: BorderSide(color: colors.primary),
      foregroundColor: colors.primary,
    );
  }

  static ButtonStyle text(AppColorTokens colors) {
    return TextButton.styleFrom(
      padding: AppSpacing.smPadding,
      foregroundColor: colors.primary,
    );
  }

  static ButtonStyle icon(AppColorTokens colors) {
    return IconButton.styleFrom(
      padding: EdgeInsets.all(8.w),
      backgroundColor: colors.surface,
      foregroundColor: colors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
    );
  }
}
