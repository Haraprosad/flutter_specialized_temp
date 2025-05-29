import 'package:flutter/material.dart';
import 'package:flutter_specialized_temp/core/theme/base/app_theme_type.dart';
import 'package:flutter_specialized_temp/core/theme/colors/theme_colors.dart';

class AppThemeColorsConfig {
  // Status Colors (refined for better UX)
  static const Color _warning = Color(0xFFFFB020);
  static const Color _alert = Color(0xFFFF4757);

  // Theme color schemes
  static final Map<AppThemeType, ThemeColors> themeColors = {
    AppThemeType.light: ThemeColors(
      primary: const Color(0xFF2563EB), // Professional blue
      secondary: const Color(0xFF7C3AED), // Premium purple
      success: const Color(0xFF10B981), // Modern green
      background: const Color(0xFFFAFAFA), // Soft white
      surface: const Color(0xFFFFFFFF), // Pure white
      textPrimary: const Color(0xFF1F2937), // Rich dark gray
      textSecondary: const Color(0xFF6B7280), // Medium gray
      warning: _warning,
      alert: _alert,
    ),
    AppThemeType.dark: ThemeColors(
      primary: const Color(0xFF3B82F6), // Vibrant blue
      secondary: const Color(0xFF8B5CF6), // Bright purple
      success: const Color(0xFF34D399), // Bright green
      background: const Color(0xFF0F172A), // Deep navy
      surface: const Color(0xFF1E293B), // Slate gray
      textPrimary: const Color(0xFFF8FAFC), // Pure white
      textSecondary: const Color(0xFFCBD5E1), // Light gray
      warning: _warning,
      alert: _alert,
    ),
  };
}
