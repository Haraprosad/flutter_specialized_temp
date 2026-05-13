# Skill: Design System

> Read this before any UI, widget, or theme work.

---

## Single Import Rule

Every UI file has exactly one design system import:

```dart
import 'package:flutter_specialized_temp/core/design_management_system/design_management_system.dart';
```

Never import individual token files directly in widgets.

---

## Forbidden vs Required — Quick Reference

| ❌ Never Write               | ✅ Always Write                              |
|------------------------------|----------------------------------------------|
| `EdgeInsets.all(16)`         | `AppSpacing.mdPadding`                       |
| `EdgeInsets.symmetric(h: 8)` | `AppSpacing.smHorizontal`                    |
| `SizedBox(height: 24)`       | `AppSpacing.lgHeight`                        |
| `Color(0xFF6366F1)`          | `context.colors.primary`                     |
| `Colors.red`                 | `context.colors.error` / `AppColors.error`   |
| `TextStyle(fontSize: 14)`    | `context.textTheme.bodyMedium`               |
| `FontWeight.w600`            | Built into typography tokens                 |
| `BorderRadius.circular(8)`   | `BorderRadius.circular(AppDimensions.radiusMd)` |
| `Duration(milliseconds: 300)`| `AppMotion.durationMedium`                   |
| `Curves.easeInOut`           | `AppMotion.curveStandard`                    |
| Hard-coded `'Login'` string  | `context.loc.login_button`                   |
| `MediaQuery.of(c).size.width`| `context.screenWidth`                        |
| `48.w` (raw screenutil)      | Use token — `.w` only when no token fits     |

---

## Token Files and Their Contents

| File                        | Contains                                   |
|-----------------------------|---------------------------------------------|
| `tokens/app_colors.dart`    | All color constants (static `const Color`)  |
| `tokens/app_typography.dart`| All text style getters                      |
| `tokens/app_spacing.dart`   | Raw doubles + EdgeInsets + SizedBox helpers |
| `tokens/app_dimensions.dart`| Border radii, button/icon/input sizes       |
| `tokens/app_motion.dart`    | Duration constants + curve constants        |

---

## Context Extension Quick Reference

```dart
// ─── Theme ────────────────────────────────────────────────
context.theme            // ThemeData
context.isDarkMode       // bool
context.colorScheme      // ColorScheme

// ─── Colors (via AppColors extension on BuildContext) ─────
context.colors.primary
context.colors.secondary
context.colors.error
context.colors.textPrimary   // resolves light/dark automatically

// ─── Typography ───────────────────────────────────────────
context.textTheme.displayLarge
context.textTheme.headlineMedium
context.textTheme.titleMedium
context.textTheme.bodyLarge
context.textTheme.bodyMedium
context.textTheme.labelSmall

// ─── Screen ───────────────────────────────────────────────
context.screenWidth
context.screenHeight
context.isTablet         // screenWidth >= 600
context.isPhone          // screenWidth < 600
context.statusBarHeight
context.bottomBarHeight

// ─── Localization ─────────────────────────────────────────
context.loc.<key>        // type-safe ARB string
```

---

## Adding a New ARB Key

1. Add to `lib/core/localization/l10n/app_en.arb`:
```json
"order_title": "Orders",
"@order_title": { "description": "Title for the orders screen" }
```

2. Add same key to `lib/core/localization/l10n/app_bn.arb`:
```json
"order_title": "অর্ডার সমূহ"
```

3. Run: `flutter gen-l10n`

4. Use: `context.loc.order_title`

5. Register in `FEATURE_REGISTRY.md` → Localization Keys section.

---

## Adaptive Layout Pattern

```dart
@override
Widget build(BuildContext context) {
  return context.isTablet
      ? _TabletLayout(items: items)
      : _MobileLayout(items: items);
}

// Tablet: master-detail or two-column grid
class _TabletLayout extends StatelessWidget {
  Widget build(BuildContext context) {
    return Row(children: [
      SizedBox(width: 320, child: _ItemList(items: items)),
      const VerticalDivider(width: 1),
      Expanded(child: _ItemDetail()),
    ]);
  }
}

// Mobile: single-column list
class _MobileLayout extends StatelessWidget { ... }
```

---

## Pre-Built Components (use these — don't reinvent)

| Component                | Usage                                          |
|--------------------------|------------------------------------------------|
| `NetworkAwarePage`       | Wrap every screen body — shows offline banner  |
| `ErrorWidgetWithAction`  | Error state with retry button                  |
| `CustomImageView`        | All network/asset images — handles cache       |
| `ScaffoldWithBottomNav`  | Shell route with bottom navigation             |
| `AppDrawer`              | Side nav with user info                        |

---

## Theme Extension Pattern (for custom component tokens)

If you need a component-specific token (e.g. a custom badge color):

```dart
// in tokens/app_colors.dart
static const Color badgeBackground = Color(0xFFEFF6FF);

// Use in widget:
Container(color: AppColors.badgeBackground)
// OR if it should respond to theme mode:
Container(color: context.isDarkMode ? AppColors.badgeDark : AppColors.badgeBackground)
```

Do NOT use `Theme.of(context).extensions` unless the component is truly reusable across projects.

---

## Responsive Images

```dart
CustomImageView(
  imageUrl: item.imageUrl,
  // ALWAYS set cache dimensions matching actual render size
  // prevents 2000px images being decoded for a 100px thumbnail
  cacheWidth: (context.screenWidth * 0.3).toInt(),
  cacheHeight: (context.screenWidth * 0.3).toInt(),
  fit: BoxFit.cover,
  placeHolder: 'assets/images/placeholder.png',
)
```

---

## Accessibility Checklist (per widget)

- [ ] `IconButton` has `tooltip:`
- [ ] Custom tap area is at least 48×48px
- [ ] Images have `semanticsLabel:`
- [ ] Color is not the only signal (pair with icon or text)
- [ ] Text respects `TextScaler` (no fixed-height containers that clip text)
- [ ] `FocusTraversalGroup` on multi-field forms
