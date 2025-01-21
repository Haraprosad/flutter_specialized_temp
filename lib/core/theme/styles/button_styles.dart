import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_specialized_temp/core/theme/colors/theme_colors.dart';
import '../constants/theme_constants.dart';

class ButtonStyles {
  static ButtonStyle elevatedButtonStyle(ThemeColors colors) {
    return ElevatedButton.styleFrom(
      elevation: 4,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
      textStyle: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.defaultBorderRadius),
      ),
      backgroundColor: colors.primary,
      foregroundColor: colors.background,
    );
  }

  static ButtonStyle outlinedButtonStyle(ThemeColors colors) {
    return OutlinedButton.styleFrom(
      padding: EdgeInsets.all(10.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.defaultBorderRadius),
      ),
      side: BorderSide(color: colors.primary),
      foregroundColor: colors.primary,
    );
  }

  static ButtonStyle textButtonStyle(ThemeColors colors) {
    return TextButton.styleFrom(
      padding: ThemeConstants.textButtonPadding,
      foregroundColor: colors.primary,
    );
  }

  static ButtonStyle iconButtonStyle(ThemeColors colors) {
    return IconButton.styleFrom(
      padding: EdgeInsets.all(8.w),
      backgroundColor: colors.surface,
      foregroundColor: colors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.defaultBorderRadius),
      ),
    );
  }
}
