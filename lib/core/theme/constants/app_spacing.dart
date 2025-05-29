import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Centralized spacing system for consistent UI spacing throughout the app
class AppSpacing {
  AppSpacing._();

  // Horizontal spacing
  static double get xs => 4.w;
  static double get sm => 8.w;
  static double get md => 16.w;
  static double get lg => 24.w;
  static double get xl => 32.w;
  static double get xxl => 48.w;

  // Vertical spacing
  static double get xsV => 4.h;
  static double get smV => 8.h;
  static double get mdV => 16.h;
  static double get lgV => 24.h;
  static double get xlV => 32.h;
  static double get xxlV => 48.h;

  // Common EdgeInsets
  static EdgeInsets get xsPadding => EdgeInsets.all(xs);
  static EdgeInsets get smPadding => EdgeInsets.all(sm);
  static EdgeInsets get mdPadding => EdgeInsets.all(md);
  static EdgeInsets get lgPadding => EdgeInsets.all(lg);
  static EdgeInsets get xlPadding => EdgeInsets.all(xl);

  // Horizontal padding
  static EdgeInsets get xsHorizontal => EdgeInsets.symmetric(horizontal: xs);
  static EdgeInsets get smHorizontal => EdgeInsets.symmetric(horizontal: sm);
  static EdgeInsets get mdHorizontal => EdgeInsets.symmetric(horizontal: md);
  static EdgeInsets get lgHorizontal => EdgeInsets.symmetric(horizontal: lg);
  static EdgeInsets get xlHorizontal => EdgeInsets.symmetric(horizontal: xl);

  // Vertical padding
  static EdgeInsets get xsVertical => EdgeInsets.symmetric(vertical: xsV);
  static EdgeInsets get smVertical => EdgeInsets.symmetric(vertical: smV);
  static EdgeInsets get mdVertical => EdgeInsets.symmetric(vertical: mdV);
  static EdgeInsets get lgVertical => EdgeInsets.symmetric(vertical: lgV);
  static EdgeInsets get xlVertical => EdgeInsets.symmetric(vertical: xlV);

  // SizedBox for spacing
  static Widget get xsHeight => SizedBox(height: xsV);
  static Widget get smHeight => SizedBox(height: smV);
  static Widget get mdHeight => SizedBox(height: mdV);
  static Widget get lgHeight => SizedBox(height: lgV);
  static Widget get xlHeight => SizedBox(height: xlV);

  static Widget get xsWidth => SizedBox(width: xs);
  static Widget get smWidth => SizedBox(width: sm);
  static Widget get mdWidth => SizedBox(width: md);
  static Widget get lgWidth => SizedBox(width: lg);
  static Widget get xlWidth => SizedBox(width: xl);
}
