import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Single source of truth for all dimensional constants (sizes, radii, elevations).
///
/// RULE: Never use `BorderRadius.circular(N)` with a raw number anywhere outside
/// this file. Import and use `AppDimensions.radius*` tokens.
///
/// All values use responsive units (.w / .h / .r / .sp) unless they are
/// elevation values (which are device-independent floats).
class AppDimensions {
  AppDimensions._();

  // ─── Icon sizes ───────────────────────────────────────────────────────────

  static double get iconXs => 12.sp;
  static double get iconSm => 16.sp;
  static double get iconMd => 20.sp;
  static double get iconLg => 24.sp;
  static double get iconXl => 32.sp;
  static double get iconXxl => 48.sp;

  // ─── Button heights ───────────────────────────────────────────────────────

  static double get buttonSmall => 32.h;
  static double get buttonMedium => 40.h;
  static double get buttonLarge => 48.h;

  // ─── Minimum touch target (Material accessibility guideline) ─────────────

  static double get touchTargetMin => 48.h;

  // ─── Input field heights ──────────────────────────────────────────────────

  static double get inputSmall => 36.h;
  static double get inputMedium => 44.h;
  static double get inputLarge => 52.h;

  // ─── Border radius ────────────────────────────────────────────────────────

  static double get radiusXs => 4.r;
  static double get radiusSm => 6.r;
  static double get radiusMd => 8.r;
  static double get radiusLg => 12.r;
  static double get radiusXl => 16.r;
  static double get radiusXxl => 20.r;

  /// Rounded style (inputs, search bars, chat bubbles).
  static double get radiusRounded => 24.r;

  /// Pill style (chips, tags, badges).
  static double get radiusPill => 999.r;

  // ─── Container preset widths ──────────────────────────────────────────────

  static double get containerXs => 40.w;
  static double get containerSm => 60.w;
  static double get containerMd => 80.w;
  static double get containerLg => 100.w;
  static double get containerXl => 120.w;

  // ─── Elevation ────────────────────────────────────────────────────────────

  static const double elevationCard = 2;
  static const double elevationModal = 8;
  static const double elevationAppBar = 1;
  static const double elevationButton = 8;
}
