import 'package:flutter/material.dart';

/// Canonical color model for custom semantic colors not covered by Material 3's ColorScheme.
/// Used for: success, background, textPrimary, textSecondary, warning, alert.
class AppColorTokens {
  const AppColorTokens({
    required this.primary,
    required this.secondary,
    required this.success,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.warning,
    required this.alert,
  });
  final Color primary;
  final Color secondary;
  final Color success;
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color warning;
  final Color alert;
}

/// Single source of truth for all application colors.
/// Light and dark variants are defined here — every other file imports from here.
///
/// RULE: Never use `Color(0x...)` anywhere outside this file.
/// Use `AppColors.light.*`, `AppColors.dark.*`, or `AppColors.of(context)`.
class AppColors {
  AppColors._();

  // ─── Status / semantic ───────────────────────────────────────────────────

  static const Color success = Color(0xFF10B981);
  static const Color successDark = Color(0xFF34D399);

  static const Color warning = Color(0xFFFFB020);
  static const Color alert = Color(0xFFFF4757);

  static const Color disabled = Color(0xFFBDBDBD);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color shadow = Color(0x1A000000); // 10% black

  // ─── Light palette ────────────────────────────────────────────────────────

  static const AppColorTokens light = AppColorTokens(
    primary: Color(0xFF2563EB),
    secondary: Color(0xFF7C3AED),
    success: Color(0xFF10B981),
    background: Color(0xFFFAFAFA),
    surface: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF1F2937),
    textSecondary: Color(0xFF6B7280),
    warning: Color(0xFFFFB020),
    alert: Color(0xFFFF4757),
  );

  // ─── Dark palette ─────────────────────────────────────────────────────────

  static const AppColorTokens dark = AppColorTokens(
    primary: Color(0xFF3B82F6),
    secondary: Color(0xFF8B5CF6),
    success: Color(0xFF34D399),
    background: Color(0xFF0F172A),
    surface: Color(0xFF1E293B),
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFFCBD5E1),
    warning: Color(0xFFFFB020),
    alert: Color(0xFFFF4757),
  );

  /// Returns the correct color set for the current [BuildContext] brightness.
  static AppColorTokens of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? light : dark;
  }
}
