import 'package:flutter/material.dart';

/// Animation and motion tokens.
///
/// RULE: Never use raw `Duration(milliseconds: N)` for UI animations.
/// Use `AppMotion.*` tokens so all durations stay in sync across the app.
class AppMotion {
  AppMotion._();

  // ─── Durations ────────────────────────────────────────────────────────────

  static const Duration short = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration long = Duration(milliseconds: 500);
  static const Duration celebration = Duration(milliseconds: 800);

  // ─── Curves ───────────────────────────────────────────────────────────────

  static const Curve standard = Curves.easeInOut;
  static const Curve entrance = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
  static const Curve spring = Curves.elasticOut;

  // ─── Opacity values ───────────────────────────────────────────────────────

  static const double opacityDisabled = 0.5;
  static const double opacityHover = 0.1;
  static const double opacityPressed = 0.2;
  static const double opacitySubtle = 0.85;
}
