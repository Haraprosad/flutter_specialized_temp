import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Centralized sizing system for consistent UI dimensions
class AppSizes {
  AppSizes._();

  // Icon sizes
  static double get iconXs => 12.sp;
  static double get iconSm => 16.sp;
  static double get iconMd => 20.sp;
  static double get iconLg => 24.sp;
  static double get iconXl => 32.sp;
  static double get iconXxl => 48.sp;

  // Button heights
  static double get buttonSmall => 32.h;
  static double get buttonMedium => 40.h;
  static double get buttonLarge => 48.h;

  // Input field heights
  static double get inputSmall => 36.h;
  static double get inputMedium => 44.h;
  static double get inputLarge => 52.h;

  // Border radius
  static double get radiusXs => 4.r;
  static double get radiusSm => 6.r;
  static double get radiusMd => 8.r;
  static double get radiusLg => 12.r;
  static double get radiusXl => 16.r;
  static double get radiusXxl => 24.r;
  static double get radiusFull => 999.r;

  // Container sizes
  static double get containerXs => 40.w;
  static double get containerSm => 60.w;
  static double get containerMd => 80.w;
  static double get containerLg => 100.w;
  static double get containerXl => 120.w;

  // Common card dimensions
  static double get cardElevation => 2.0;
  static double get modalElevation => 8.0;
  static double get appBarElevation => 1.0;
}
