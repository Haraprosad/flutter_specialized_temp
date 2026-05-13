import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_specialized_temp/core/constants/asset_constants.dart';
import 'package:flutter_specialized_temp/core/design_management_system/tokens/app_colors.dart';

/// Material 3 text theme built from design tokens.
/// All sizes use `.sp` — never set raw `fontSize` values elsewhere.
///
/// Poppins → display, headline, title styles
/// Inter   → body, label styles
class AppTypography {
  AppTypography._();

  static TextTheme buildTextTheme(AppColorTokens colors) => TextTheme(
    displayLarge: TextStyle(
      fontSize: 57.sp,
      height: 1.12,
      letterSpacing: -0.25,
      color: colors.textPrimary,
      fontFamily: AssetConstants.fontFamilyPoppins,
    ),
    displayMedium: TextStyle(
      fontSize: 45.sp,
      height: 1.16,
      color: colors.textPrimary,
      fontFamily: AssetConstants.fontFamilyPoppins,
    ),
    displaySmall: TextStyle(
      fontSize: 36.sp,
      height: 1.22,
      color: colors.textPrimary,
      fontFamily: AssetConstants.fontFamilyPoppins,
    ),
    headlineLarge: TextStyle(
      fontSize: 32.sp,
      height: 1.25,
      color: colors.textPrimary,
      fontFamily: AssetConstants.fontFamilyPoppins,
    ),
    headlineMedium: TextStyle(
      fontSize: 28.sp,
      height: 1.29,
      color: colors.textPrimary,
      fontFamily: AssetConstants.fontFamilyPoppins,
    ),
    headlineSmall: TextStyle(
      fontSize: 24.sp,
      height: 1.33,
      color: colors.textPrimary,
      fontFamily: AssetConstants.fontFamilyPoppins,
    ),
    titleLarge: TextStyle(
      fontSize: 22.sp,
      height: 1.27,
      color: colors.textPrimary,
      fontFamily: AssetConstants.fontFamilyPoppins,
    ),
    titleMedium: TextStyle(
      fontSize: 16.sp,
      height: 1.5,
      letterSpacing: 0.15,
      color: colors.textPrimary,
      fontFamily: AssetConstants.fontFamilyPoppins,
    ),
    titleSmall: TextStyle(
      fontSize: 14.sp,
      height: 1.43,
      letterSpacing: 0.1,
      color: colors.textSecondary,
      fontFamily: AssetConstants.fontFamilyPoppins,
    ),
    bodyLarge: TextStyle(
      fontSize: 16.sp,
      height: 1.5,
      letterSpacing: 0.15,
      color: colors.textPrimary,
      fontFamily: AssetConstants.fontFamilyInter,
    ),
    bodyMedium: TextStyle(
      fontSize: 14.sp,
      height: 1.43,
      letterSpacing: 0.25,
      color: colors.textPrimary,
      fontFamily: AssetConstants.fontFamilyInter,
    ),
    bodySmall: TextStyle(
      fontSize: 12.sp,
      height: 1.33,
      letterSpacing: 0.4,
      color: colors.textSecondary,
      fontFamily: AssetConstants.fontFamilyInter,
    ),
    labelLarge: TextStyle(
      fontSize: 14.sp,
      height: 1.43,
      letterSpacing: 0.1,
      color: colors.textSecondary,
      fontFamily: AssetConstants.fontFamilyInter,
    ),
    labelMedium: TextStyle(
      fontSize: 12.sp,
      height: 1.33,
      letterSpacing: 0.5,
      color: colors.textSecondary,
      fontFamily: AssetConstants.fontFamilyInter,
    ),
    labelSmall: TextStyle(
      fontSize: 11.sp,
      height: 1.45,
      letterSpacing: 0.5,
      color: colors.textSecondary,
      fontFamily: AssetConstants.fontFamilyInter,
    ),
  );
}
