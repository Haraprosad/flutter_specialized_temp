import 'package:flutter/material.dart';
import 'package:flutter_specialized_temp/core/theme/constants/app_spacing.dart';
import 'package:flutter_specialized_temp/core/theme/constants/app_sizes.dart';

class ThemeConstants {
  ThemeConstants._();
  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 150);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Opacity values
  static const double disabledOpacity = 0.5;
  static const double hoverOpacity = 0.1;
  static const double pressedOpacity = 0.2;
}
