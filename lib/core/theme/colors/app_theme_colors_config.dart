import 'package:flutter/material.dart';
import 'package:flutter_specialized_temp/core/theme/base/app_theme_type.dart';
import 'package:flutter_specialized_temp/core/theme/colors/theme_colors.dart';

class AppThemeColorsConfig {
  // Status Colors (same for both themes)
  static const Color _warning = Color(0xFFFFC107);
  static const Color _alert = Color(0xFFFF9800);

  // Theme color schemes
  static final Map<AppThemeType, ThemeColors> themeColors = {
    AppThemeType.light: ThemeColors(
      primary: const Color(0xFF0066CC),
      secondary: const Color(0xFFD93025),
      success: const Color(0xFF2E7D32),
      background: const Color(0xFFFFFFFF),
      surface: const Color(0xFFF5F5F5),
      textPrimary: const Color(0xFF212121),
      textSecondary: const Color(0xFF757575),
      warning: _warning,
      alert: _alert,
      chatOutgoingBubble: const Color(0xFFE3F2FD), // Light blue
      chatAiBubble: const Color(0xFFF3E5F5), // Light purple
      chatHumanBubble: const Color(0xFFFFFFFF), // White
      chatTimestamp: const Color(0xFF9E9E9E), // Medium grey
    ),
    AppThemeType.dark: ThemeColors(
      primary: const Color(0xFF338DFF),
      secondary: const Color(0xFFFF4545),
      success: const Color(0xFF4CAF50),
      background: const Color(0xFF121212),
      surface: const Color(0xFF1E1E1E),
      textPrimary: const Color(0xFFE1E1E1),
      textSecondary: const Color(0xFFB0B0B0),
      warning: _warning,
      alert: _alert,
      chatOutgoingBubble: const Color(0xFF1E3A5F), // Dark blue
      chatAiBubble: const Color(0xFF2C1B3A), // Dark purple
      chatHumanBubble: const Color(0xFF2D2D2D), // Dark grey
      chatTimestamp: const Color(0xFF757575), // Light grey
    ),
  };
}
