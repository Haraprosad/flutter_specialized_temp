# Guide 4 — Design System

Complete reference for the unified Design Management System: tokens, themes, responsive/adaptive patterns, styles, and context extensions.

---

## Single Import

```dart
import 'package:flutter_specialized_temp/core/design_management_system/design_management_system.dart';
```

This barrel export gives you every token, style, theme, and extension in one line.

---

## Token System

### Colors

```dart
// Static access (anywhere):
AppColors.primary
AppColors.secondary
AppColors.error
AppColors.surface
AppColors.onSurface

// Context access (in widgets):
context.colors.primary
context.colors.secondary
context.colorScheme.surface
context.colorScheme.onSurface
```

The color system automatically switches between light and dark mode via `ThemeBloc`. Define custom colors in:

- `tokens/app_colors.dart` — raw color values
- `themes/app_color_scheme.dart` — maps to Material `ColorScheme`

### Typography

```dart
context.textTheme.displayLarge    // 57sp / bold
context.textTheme.displayMedium   // 45sp / bold
context.textTheme.displaySmall    // 36sp / bold
context.textTheme.headlineLarge   // 32sp / bold
context.textTheme.headlineMedium  // 28sp / semi-bold
context.textTheme.headlineSmall   // 24sp / semi-bold
context.textTheme.titleLarge      // 22sp / medium
context.textTheme.titleMedium     // 16sp / medium
context.textTheme.titleSmall      // 14sp / medium
context.textTheme.bodyLarge       // 16sp / regular
context.textTheme.bodyMedium      // 14sp / regular
context.textTheme.bodySmall       // 12sp / regular
context.textTheme.labelLarge      // 14sp / medium
context.textTheme.labelMedium     // 12sp / medium
context.textTheme.labelSmall      // 11sp / medium
```

Font files are in `assets/fonts/` (Inter + Poppins). To change fonts:
1. Add `.ttf` files to `assets/fonts/`
2. Update `pubspec.yaml` fonts section
3. Update `tokens/app_typography.dart`

### Spacing

```dart
// Raw values
AppSpacing.xs     // 4.0
AppSpacing.sm     // 8.0
AppSpacing.md     // 16.0
AppSpacing.lg     // 24.0
AppSpacing.xl     // 32.0
AppSpacing.xxl    // 48.0

// Named EdgeInsets helpers
AppSpacing.xsPadding      // EdgeInsets.all(4)
AppSpacing.smPadding      // EdgeInsets.all(8)
AppSpacing.mdPadding      // EdgeInsets.all(16)
AppSpacing.lgPadding      // EdgeInsets.all(24)
AppSpacing.xlPadding      // EdgeInsets.all(32)

AppSpacing.smHorizontal   // EdgeInsets.symmetric(horizontal: 8)
AppSpacing.mdHorizontal   // EdgeInsets.symmetric(horizontal: 16)
AppSpacing.smVertical     // EdgeInsets.symmetric(vertical: 8)
AppSpacing.mdVertical     // EdgeInsets.symmetric(vertical: 16)

// SizedBox helpers
AppSpacing.mdHeight       // SizedBox(height: 16)
AppSpacing.lgHeight       // SizedBox(height: 24)
AppSpacing.mdWidth        // SizedBox(width: 16)
AppSpacing.lgWidth        // SizedBox(width: 24)
```

### Dimensions

```dart
// Border radius
AppDimensions.radiusNone   // 0
AppDimensions.radiusSm     // 4
AppDimensions.radiusMd     // 8
AppDimensions.radiusLg     // 12
AppDimensions.radiusXl     // 16
AppDimensions.radiusFull   // 999 (pill shape)

// Button sizes
AppDimensions.buttonSmall    // 36
AppDimensions.buttonMedium   // 44
AppDimensions.buttonLarge    // 52

// Icon sizes
AppDimensions.iconSmall    // 16
AppDimensions.iconMedium   // 24
AppDimensions.iconLarge    // 32
AppDimensions.iconXLarge   // 48

// Input sizes
AppDimensions.inputHeight     // 56
AppDimensions.inputIconSize   // 24

// Card
AppDimensions.cardElevation   // 2
AppDimensions.cardRadius      // 12
```

### Motion

```dart
// Durations
AppMotion.durationFast      // 150ms
AppMotion.durationMedium    // 300ms
AppMotion.durationSlow      // 500ms

// Curves
AppMotion.curveStandard     // Curves.easeInOut
AppMotion.curveEntrance     // Curves.easeOut
AppMotion.curveExit         // Curves.easeIn
AppMotion.curveEmphasis     // Curves.easeInOutCubic

// Usage
AnimatedContainer(
  duration: AppMotion.durationMedium,
  curve: AppMotion.curveEntrance,
  ...
)
```

---

## Pre-Built Styles

### Button Styles

```dart
// In theme — access via Theme.of(context):
ElevatedButton(
  style: context.theme.elevatedButtonTheme.style, // default
  onPressed: () {},
  child: Text('Primary'),
)

// Or explicit:
ElevatedButton(
  style: ButtonStyles.primary,   // filled primary
  ...
)
ElevatedButton(
  style: ButtonStyles.secondary, // filled secondary
  ...
)
OutlinedButton(
  style: ButtonStyles.outlined,  // bordered
  ...
)
TextButton(
  style: ButtonStyles.text,      // text only
  ...
)
```

### Card Styles

```dart
Card(
  // Default card style from theme — elevation, shape, padding
  child: ...,
)
```

### Input Styles

```dart
TextField(
  decoration: InputStyles.outlined(
    labelText: 'Email',
    hintText: 'Enter your email',
  ),
)

TextField(
  decoration: InputStyles.outlinedWithError(
    labelText: 'Email',
    errorText: 'Invalid email',
  ),
)
```

---

## Context Extensions Reference

```dart
// Theme
context.theme          // ThemeData
context.isDarkMode     // bool
context.colorScheme    // ColorScheme
context.textTheme      // TextTheme

// Colors (via extension)
context.colors         // AppColors

// Screen dimensions (via flutter_screenutil)
context.screenWidth    // logical width
context.screenHeight   // logical height
context.pixelRatio     // device pixel ratio
context.statusBarHeight
context.bottomBarHeight

// Device type
context.isTablet       // screenWidth >= 600
context.isPhone        // screenWidth < 600

// Localization
context.loc.<key>      // type-safe localized string

// Navigation
context.go('/path')
context.goNamed('routeName', pathParameters: {'id': '123'})
context.push('/path')
context.pop()
```

---

## Responsive Design

### flutter_screenutil

The app initializes `ScreenUtilInit` in `main.dart` with a design size of 375×812 (iPhone standard). All sizes are automatically scaled:

```dart
// Use .w, .h, .sp, .r for responsive units:
Container(
  width: 200.w,           // scales with screen width
  height: 100.h,          // scales with screen height
  padding: EdgeInsets.all(16.w),
  child: Text(
    'Hello',
    style: TextStyle(fontSize: 16.sp), // scales with screen size
  ),
)
```

However, **prefer using design system tokens** over raw `.w`/`.h`/`.sp` units. The tokens already handle scaling.

### Device Preview Mode

Run the app with `lib/main_preview.dart` to see how it looks on different devices:

```bash
flutter run -t lib/main_preview.dart
```

This wraps the app with `DevicePreview`, letting you toggle between phone, tablet, and desktop sizes in real time.

### Adaptive Layouts

For pages that need different layouts on phone vs tablet:

```dart
class AdaptiveOrdersPage extends StatelessWidget {
  final List<OrderEntity> orders;

  const AdaptiveOrdersPage({required this.orders, super.key});

  @override
  Widget build(BuildContext context) {
    if (context.isTablet) {
      return _TabletLayout(orders: orders);
    }
    return _MobileLayout(orders: orders);
  }
}

class _TabletLayout extends StatelessWidget {
  // Two-column grid or master-detail
  // Use GridView with crossAxisCount: 2
  // Or Row with NavigationRail + detail panel
}

class _MobileLayout extends StatelessWidget {
  // Single-column list
  // Use ListView
}
```

### Safe Area and Notches

The template handles notches and safe areas at the scaffold level. For custom widgets:

```dart
SafeArea(
  child: ...,
)

// Or for specific edges:
SafeArea(
  left: false,
  right: false,
  child: ...,
)
```

---

## Theme Switching

The app supports light, dark, and system themes via `ThemeBloc`:

```dart
// Toggle from anywhere:
context.read<ThemeBloc>().add(ThemeChanged(ThemeMode.dark));
context.read<ThemeBloc>().add(ThemeChanged(ThemeMode.system));

// The preference is persisted automatically via PreferencesManager.
```

To add custom theme variants:
1. Define colors in `themes/app_color_scheme.dart`
2. Add variant logic in `themes/app_theme.dart`
3. Extend `ThemeBloc` with the new theme type

---

## Adding Custom Design Tokens

To extend the design system:

1. Add raw values to the appropriate token file (e.g., `tokens/app_colors.dart`)
2. Map them in the theme file (`themes/app_theme.dart`)
3. If adding a new token category, create the file in `tokens/` and export it from `design_management_system.dart`

---

## Shared Widgets

### NetworkAwarePage

Wraps any page with offline detection:

```dart
NetworkAwarePage(
  child: OrdersView(),
)
```

### ErrorWidgetWithAction

Inline error with retry:

```dart
ErrorWidgetWithAction(
  message: 'Failed to load orders',
  onRetry: () => context.read<OrdersBloc>().add(FetchOrders()),
)
```

### CustomImageView

Cached image with placeholder:

```dart
CustomImageView(
  imageUrl: 'https://...',
  placeHolder: 'assets/images/placeholder.png',
  errorWidget: Icon(Icons.broken_image),
)
```

### AppDrawer

Side navigation with user info and menu items.

### ScaffoldWithBottomNav

Shell route scaffold — used by GoRouter for tab-based navigation.
