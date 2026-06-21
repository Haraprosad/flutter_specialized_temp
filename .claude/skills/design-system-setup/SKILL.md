---
name: design-system-setup
description: >
  Rules for the Design Management System — defining and using brand tokens
  (colors, typography, spacing, dimensions, motion) and themes. Activates when
  customizing the app's brand or building any UI. Keywords: design system,
  design tokens, theme, colors, typography, fonts, spacing, AppSpacing,
  context.colors, context.textTheme, dark mode, responsive, screenutil.
---

# Design System Setup

The single source of truth for every UI value. **No raw literals in widgets** —
no hardcoded colors, font sizes, paddings, radii, or durations.

## Where tokens live

`lib/core/design_management_system/`

```
tokens/
├── app_colors.dart        # AppColorTokens (light + dark), AppColors.of(context)
├── app_typography.dart    # text styles → fed into TextTheme
├── app_spacing.dart       # AppSpacing scale (screenutil .w/.h aware)
├── app_dimensions.dart    # radii, icon sizes, component dimensions
└── app_motion.dart        # durations & curves
themes/
├── app_color_scheme.dart  # Material ColorScheme (light/dark)
├── app_theme.dart         # ThemeData assembly
└── app_theme_type.dart
extensions/context_extension.dart   # context.colors / context.textTheme / etc.
styles/                             # button_styles, card_styles, input_styles
```

Import everything through the barrel: `design_management_system.dart`.

## How to consume tokens in widgets

```dart
Container(
  padding: AppSpacing.mdPadding,              // never EdgeInsets.all(16)
  decoration: BoxDecoration(
    color: context.colors.surface,            // semantic tokens
    borderRadius: AppDimensions.radiusMd,
  ),
  child: Text('Title', style: context.titleMedium),  // never TextStyle(fontSize: 18)
);
```

- `context.colorScheme.*` → Material-standard colors (primary, surface…).
- `context.colors.*` → custom semantic tokens (success, warning, alert,
  background…), backed by `AppColors.of(context)`.
- `context.textTheme.*` / shorthands (`context.titleMedium`, `context.bodyLarge`…).
- `AppSpacing.xs/sm/md/lg/xl/xxl` (and `*V` vertical, `*Height/*Width` SizedBox
  helpers, `*Padding` presets). Values are `flutter_screenutil` aware (`.w/.h`).

## Customizing the brand (Phase 1 — do once, first)

Edit tokens, not widgets:
1. `tokens/app_colors.dart` — brand colors, light **and** dark variants.
2. `tokens/app_typography.dart` + `pubspec.yaml` `fonts:` section (and the
   `fonts/` assets).
3. `tokens/app_spacing.dart` / `app_dimensions.dart` if density differs.
4. `tokens/app_motion.dart` for motion personality.
5. `themes/app_color_scheme.dart` + `app_theme.dart` to wire tokens into theme.

Verify across device sizes with the preview entrypoint:

```bash
flutter run -t lib/main_preview.dart
```

## Importing tokens from Figma — reconcile, don't dump

When a designer provides exported Figma tokens (Tokens Studio / "Design Tokens"
plugin), the design system stays the **single source of truth** — never blindly
overwrite or append.

1. Map each incoming value to the **nearest existing token**; reuse it.
2. Add a new token only for a genuinely new *semantic* role (not a one-off
   pixel value), and add the light **and** dark variant.
3. Flag conflicts (an incoming value that's close-but-not-equal to an existing
   token) for a human decision instead of silently forking the scale.

This prevents token drift and duplication. When building a screen from a
screenshot, **snap values to tokens** — never hardcode a raw px/hex to match the
picture (that violates the no-raw-literals rule). A value you can't express in a
token is the signal to add one here, deliberately. See `docs/00_WORKFLOW.md`
→ "Design-to-code".

## Responsive & adaptive

Use `flutter_screenutil` units already baked into the spacing scale.
`context.isTablet` (≥600 dp), `context.screenWidth/Height`, `context.padding`
(safe-area), `context.isKeyboardVisible` are available from `context_extension`.

Full reference: `docs/04_DESIGN_SYSTEM.md`.
