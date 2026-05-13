import 'package:flutter/material.dart';
import 'package:flutter_specialized_temp/core/design_management_system/tokens/app_colors.dart';
import 'package:flutter_specialized_temp/core/design_management_system/tokens/app_dimensions.dart';

/// Pre-built card decoration presets.
class AppCardStyles {
  AppCardStyles._();

  static BoxDecoration elevated(AppColorTokens colors) {
    return BoxDecoration(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      boxShadow: [
        BoxShadow(
          color: colors.textSecondary.withAlpha(26),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  static BoxDecoration outlined(AppColorTokens colors) {
    return BoxDecoration(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      border: Border.all(
        color: colors.textSecondary.withAlpha(51),
      ),
    );
  }

  static BoxDecoration flat(AppColorTokens colors) {
    return BoxDecoration(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
    );
  }
}
