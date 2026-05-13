import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Single source of truth for all spacing in the application.
///
/// RULE: Never use magic numbers for spacing. Use these tokens.
/// - Horizontal spacing → `.w` variants
/// - Vertical spacing → `.h` variants (suffix V)
/// - SizedBox helpers → `AppSpacing.*Height` / `AppSpacing.*Width`
/// - Gap widgets → `AppSpacing.gap*`
/// - Padding presets → `AppSpacing.*Padding` / `AppSpacing.*Horizontal` / `AppSpacing.*Vertical`
class AppSpacing {
  AppSpacing._();

  // ─── Scale: horizontal (dp) ───────────────────────────────────────────────

  static double get xs => 4.w;
  static double get sm => 8.w;
  static double get md => 16.w;
  static double get lg => 24.w;
  static double get xl => 32.w;
  static double get xxl => 48.w;

  // ─── Scale: vertical (dp) ─────────────────────────────────────────────────

  static double get xsV => 4.h;
  static double get smV => 8.h;
  static double get mdV => 16.h;
  static double get lgV => 24.h;
  static double get xlV => 32.h;
  static double get xxlV => 48.h;

  // ─── SizedBox helpers ─────────────────────────────────────────────────────

  static Widget get xsHeight => SizedBox(height: xsV);
  static Widget get smHeight => SizedBox(height: smV);
  static Widget get mdHeight => SizedBox(height: mdV);
  static Widget get lgHeight => SizedBox(height: lgV);
  static Widget get xlHeight => SizedBox(height: xlV);
  static Widget get xxlHeight => SizedBox(height: xxlV);

  static Widget get xsWidth => SizedBox(width: xs);
  static Widget get smWidth => SizedBox(width: sm);
  static Widget get mdWidth => SizedBox(width: md);
  static Widget get lgWidth => SizedBox(width: lg);
  static Widget get xlWidth => SizedBox(width: xl);
  static Widget get xxlWidth => SizedBox(width: xxl);

  // ─── Gap presets (named for readability in Column/Row) ────────────────────

  static Widget get gapXs => SizedBox(height: xsV, width: xs);
  static Widget get gapSm => SizedBox(height: smV, width: sm);
  static Widget get gapMd => SizedBox(height: mdV, width: md);
  static Widget get gapLg => SizedBox(height: lgV, width: lg);
  static Widget get gapXl => SizedBox(height: xlV, width: xl);

  // ─── EdgeInsets presets ───────────────────────────────────────────────────

  static EdgeInsets get xsPadding => EdgeInsets.all(xs);
  static EdgeInsets get smPadding => EdgeInsets.all(sm);
  static EdgeInsets get mdPadding => EdgeInsets.all(md);
  static EdgeInsets get lgPadding => EdgeInsets.all(lg);
  static EdgeInsets get xlPadding => EdgeInsets.all(xl);

  // Horizontal
  static EdgeInsets get xsHorizontal => EdgeInsets.symmetric(horizontal: xs);
  static EdgeInsets get smHorizontal => EdgeInsets.symmetric(horizontal: sm);
  static EdgeInsets get mdHorizontal => EdgeInsets.symmetric(horizontal: md);
  static EdgeInsets get lgHorizontal => EdgeInsets.symmetric(horizontal: lg);
  static EdgeInsets get xlHorizontal => EdgeInsets.symmetric(horizontal: xl);

  // Vertical
  static EdgeInsets get xsVertical => EdgeInsets.symmetric(vertical: xsV);
  static EdgeInsets get smVertical => EdgeInsets.symmetric(vertical: smV);
  static EdgeInsets get mdVertical => EdgeInsets.symmetric(vertical: mdV);
  static EdgeInsets get lgVertical => EdgeInsets.symmetric(vertical: lgV);
  static EdgeInsets get xlVertical => EdgeInsets.symmetric(vertical: xlV);

  // ─── Semantic presets ─────────────────────────────────────────────────────

  /// Standard horizontal screen padding (16dp).
  static EdgeInsets get paddingScreen => EdgeInsets.symmetric(horizontal: md);

  /// Card content padding (12dp all sides).
  static EdgeInsets get paddingCard =>
      EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h);

  /// Button padding — elevated buttons.
  static EdgeInsets get paddingButtonElevated =>
      EdgeInsets.symmetric(horizontal: lg, vertical: 12.h);

  /// Button padding — outlined / text buttons.
  static EdgeInsets get paddingButtonOutlined => smPadding;
}
