# 🎨 Flutter Theming System - Complete Guide

A comprehensive, beginner-friendly theming system that ensures design consistency across your Flutter application. This guide will walk you through every file and how to use them effectively.

## 📁 File Structure & Purpose

```
lib/core/theme/
├── base/
│   ├── app_theme.dart           # 🏗️ Main theme builder - Creates light/dark themes
│   └── app_theme_type.dart      # 🔄 Theme types enum (light/dark)
├── bloc/
│   ├── theme_bloc.dart         # 🧠 Theme state management with BLoC
│   ├── theme_event.dart        # 📤 Theme change events
│   └── theme_state.dart        # 📊 Theme state definitions
├── colors/
│   ├── app_theme_colors_config.dart # 🎨 All color definitions for both themes
│   ├── color_scheme_ext.dart   # 🔧 Extension to access ColorScheme easily
│   └── theme_colors.dart       # 📋 Color model/structure
├── constants/
│   ├── app_sizes.dart          # 📏 All size constants (radius, heights, etc.)
│   ├── app_spacing.dart        # 📐 All spacing constants (padding, margins, gaps)
│   └── theme_constants.dart    # ⚙️ General theme constants (animations, opacity)
├── styles/
│   └── button_styles.dart      # 🔘 Pre-built button styles
├── typography/
│   ├── text_theme.dart         # ✍️ All text styles configuration
│   └── text_theme_ext.dart     # 📝 Extension to access text styles easily
└── README.md                   # 📖 This comprehensive guide
```

## 🎯 What Each File Does (Detailed Explanation)

### 🏗️ **app_theme.dart** - The Theme Factory
**Purpose**: This is the heart of your theming system. It combines all individual theme components into complete Flutter themes.

**What it controls**:
- **AppBar appearance**: Background color, text color, elevation, centering
- **Drawer design**: Background color, shape, elevation
- **Button styles**: ElevatedButton, OutlinedButton, TextButton, IconButton
- **Card appearance**: Corner radius, elevation, background color
- **Input field design**: Border colors, focus states, padding, background
- **List tiles**: Shape, padding, content spacing
- **Tab bars**: Colors, indicators, dividers
- **Overall color scheme**: Primary, secondary, surface colors

**When to update**:
- Want custom drawer design → Update `drawerTheme` in `_createTheme()`
- Need different button styles → Update `elevatedButtonTheme` in `_createTheme()`
- Want custom app bar → Update `appBarTheme` in `_createTheme()`
- Need special card design → Update `cardTheme` in `_createTheme()`

### 🎨 **app_theme_colors_config.dart** - Your Color Palette
**Purpose**: Central place for ALL colors used in your app for both light and dark themes.

**What it contains**:
- **Brand colors**: Primary (main brand), Secondary (accent)
- **Background colors**: Main background, surface (cards/containers)
- **Text colors**: Primary text, secondary text (less important)
- **Status colors**: Success (green), Warning (yellow), Alert (red)

**When to update**:
- Changing brand colors
- Adding new status colors
- Adjusting dark mode colors
- Creating theme variants

### ✍️ **text_theme.dart** - Typography System
**Purpose**: Defines all text styles with consistent sizing, fonts, and spacing.

**Material Design Text Hierarchy**:
- **Display**: Largest text (hero titles, main headings)
- **Headline**: Section headings (page titles, major sections)
- **Title**: Subsection titles (card headers, list titles)
- **Body**: Main content text (paragraphs, descriptions)
- **Label**: Small text (captions, form labels, buttons)

**When to update**:
- Changing app fonts
- Adjusting text sizes
- Modifying line heights
- Adding custom text styles

### 📏 **app_sizes.dart** - Size Standards
**Purpose**: Provides consistent sizing throughout your app for visual harmony.

**What it includes**:
- **Border radius**: Corner roundness for cards, buttons, containers
- **Button heights**: Standard button sizes (small, medium, large)
- **Icon sizes**: Consistent icon dimensions
- **Component dimensions**: Standard widths, heights for UI elements

**When to update**:
- Changing corner radius standards
- Adjusting button or icon sizes
- Adding new component dimensions
- Modifying responsive breakpoints

### 📐 **app_spacing.dart** - Spacing Standards
**Purpose**: Provides consistent spacing (padding, margins, gaps) throughout your app for visual rhythm.

**What it includes**:
- **Basic spacing values**: xs, sm, md, lg, xl (4px to 32px)
- **EdgeInsets shortcuts**: Pre-built padding configurations
- **SizedBox shortcuts**: Pre-built spacing widgets for layouts
- **Directional spacing**: Horizontal, vertical, and asymmetric spacing

**When to update**:
- Changing base spacing scale
- Adding new spacing patterns
- Modifying padding/margin standards
- Creating responsive spacing

### 🔘 **button_styles.dart** - Button Appearance
**Purpose**: Pre-configured button styles that automatically use your theme colors.

**Button types covered**:
- **ElevatedButton**: Filled buttons with elevation/shadow
- **OutlinedButton**: Buttons with borders, no fill
- **TextButton**: Minimal buttons with just text
- **IconButton**: Circular/rounded buttons with icons

### 🧠 **theme_bloc.dart** - Theme Management
**Purpose**: Handles theme switching and persistence using BLoC pattern.

**Features**:
- Toggle between light/dark themes
- Remember user's theme preference
- Initialize theme on app startup
- Reactive theme changes across the app

### ⚙️ **theme_constants.dart** - General Constants
**Purpose**: Contains animation durations, opacity values, and other general theme constants.

**What it includes**:
- **Animation durations**: Short, medium, long animation timings
- **Opacity values**: Standard opacity levels for disabled, hover, pressed states
- **General constants**: Reusable values across the theme system

### 🚀 **Extension Files** - Easy Access Helpers
**Purpose**: Provide shortcuts to access theme properties without verbose code.

**text_theme_ext.dart**: `context.bodyLarge` instead of `Theme.of(context).textTheme.bodyLarge`
**color_scheme_ext.dart**: `context.colorScheme` instead of `Theme.of(context).colorScheme`

## 🚀 Complete Setup Guide for Beginners

### Step 1: Understanding the Foundation 🏗️

This theming system works like a **design blueprint** for your entire app. Think of it as:
- **Colors**: Like choosing paint colors for your house
- **Typography**: Like choosing fonts for a book
- **Sizes**: Like having standard measurements for consistency
- **Styles**: Like having templates for buttons, cards, etc.

### Step 2: Theme Customization Process 🎨

#### 2.1 Customize Your Brand Colors
Open `app_theme_colors_config.dart` and replace with your brand colors:

```dart
AppThemeType.light: ThemeColors(
  primary: const Color(0xFF0066CC),      // 👈 Your main brand color
  secondary: const Color(0xFFD93025),    // 👈 Your accent color
  success: const Color(0xFF2E7D32),      // 👈 Green for success states
  background: const Color(0xFFFFFFFF),   // 👈 Main screen background
  surface: const Color(0xFFF5F5F5),      // 👈 Cards, containers background
  textPrimary: const Color(0xFF212121),  // 👈 Main text color
  textSecondary: const Color(0xFF757575), // 👈 Secondary text color
  warning: _warning,                      // 👈 Keep status colors same
  alert: _alert,
),
```

**Pro Tip**: Use an online color palette generator to ensure your colors work well together.

#### 2.2 Configure Typography
Check `text_theme.dart` and adjust if needed:

```dart
// Example: Making headlines more prominent
headlineLarge: TextStyle(
  fontSize: 36.sp,                           // 👈 Increase size
  height: 1.25,
  color: colors.textPrimary,
  fontFamily: AssetConstants.fontFamilyPoppins,
  fontWeight: FontWeight.w700,               // 👈 Make bolder
),
```

#### 2.3 Adjust Spacing & Sizes
In `app_sizes.dart`, modify if your design requires different dimensions:

```dart
// Example: More rounded corners
static double get radiusMd => 16.r;    // 👈 Increase from 12.r
static double get radiusLg => 20.r;    // 👈 Increase from 16.r

// Example: Larger buttons
static double get buttonLarge => 60.h;  // 👈 Increase from 56.h
```

#### 2.4 Customize Component Styles
In `app_theme.dart`, modify specific component themes:

```dart
// Example: Custom drawer with different shape
drawerTheme: DrawerThemeData(
  backgroundColor: colors.surface,
  elevation: 4,                              // 👈 Increase shadow
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.horizontal(
      right: Radius.circular(AppSizes.radiusXl), // 👈 More rounded
    ),
  ),
),

// Example: Custom app bar style
appBarTheme: AppBarTheme(
  elevation: 2,                              // 👈 Add shadow
  centerTitle: true,
  backgroundColor: colors.primary,           // 👈 Use primary color
  foregroundColor: colors.background,        // 👈 White text
  iconTheme: IconThemeData(color: colors.background),
),
```

### Step 3: Using Themes in Your UI Code 💻

#### 3.1 Essential Extensions - Your Best Friends 🪄

Use these shortcuts instead of long code:

```dart
// ❌ OLD WAY (Verbose):
Theme.of(context).colorScheme.primary
Theme.of(context).textTheme.bodyLarge
Theme.of(context).textTheme.headlineMedium

// ✅ NEW WAY (Clean):
context.colorScheme.primary    // Shorter
context.bodyLarge             // Much cleaner
context.headlineMedium        // Easy to read
```

#### 3.2 Complete Screen Template

Copy this template for any new screen:

```dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,  // 👈 Theme background
      
      appBar: AppBar(
        title: Text(
          'My Screen',
          style: context.headlineMedium,              // 👈 Theme text style
        ),
      ),
      
      // Custom drawer example
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: context.colorScheme.primary,   // 👈 Theme color
              ),
              child: Text(
                'Menu',
                style: context.headlineMedium?.copyWith(
                  color: context.colorScheme.onPrimary, // 👈 Contrasting color
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home', style: context.bodyLarge),
              onTap: () {},
            ),
          ],
        ),
      ),
      
      body: Padding(
        padding: AppSpacing.mdPadding,               // 👈 Consistent spacing
        child: Column(
          children: [
            _buildHeaderCard(context),
            AppSpacing.lgHeight,                     // 👈 Themed spacing
            _buildContentSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Card(
      // Card theme is automatically applied from app_theme.dart
      child: Padding(
        padding: AppSpacing.lgPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome Back!',
              style: context.titleLarge,              // 👈 Theme text style
            ),
            AppSpacing.smHeight,
            Text(
              'This is a description using themed colors and typography.',
              style: context.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant, // 👈 Theme color
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection(BuildContext context) {
    return Column(
      children: [
        // Themed buttons
        ElevatedButton(
          // Button style automatically applied from ButtonStyles
          onPressed: () {},
          child: Text('Primary Action'),
        ),
        AppSpacing.mdHeight,
        
        OutlinedButton(
          onPressed: () {},
          child: Text('Secondary Action'),
        ),
        AppSpacing.mdHeight,
        
        TextButton(
          onPressed: () {},
          child: Text('Tertiary Action'),
        ),
      ],
    );
  }
}
```

#### 3.3 Common UI Patterns with Theming

**📱 Creating Themed Cards:**
```dart
// Basic themed card
Card(
  // Elevation, corner radius, color automatically from theme
  child: Padding(
    padding: AppSpacing.mdPadding,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Card Title', style: context.titleMedium),
        AppSpacing.smHeight,
        Text('Card content', style: context.bodyMedium),
      ],
    ),
  ),
)

// Custom styled container (when you need more control)
Container(
  padding: AppSpacing.lgPadding,
  decoration: BoxDecoration(
    color: context.colorScheme.surfaceVariant,       // 👈 Theme color
    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
    border: Border.all(
      color: context.colorScheme.outline,            // 👈 Theme border color
      width: 1,
    ),
  ),
  child: Text('Custom Container', style: context.bodyLarge),
)
```

**🔘 Creating Different Button Types:**
```dart
// All button styles are pre-configured in ButtonStyles
Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    ElevatedButton(
      onPressed: () {},
      child: Text('Elevated'),
    ),
    OutlinedButton(
      onPressed: () {},
      child: Text('Outlined'),
    ),
    TextButton(
      onPressed: () {},
      child: Text('Text'),
    ),
    IconButton(
      onPressed: () {},
      icon: Icon(Icons.favorite),
    ),
  ],
)

// Custom button with theme colors
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: context.colorScheme.secondary,  // 👈 Use secondary color
    foregroundColor: context.colorScheme.onSecondary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
    ),
  ),
  onPressed: () {},
  child: Text('Custom Button'),
)
```

**📝 Creating Themed Forms:**
```dart
Column(
  children: [
    TextFormField(
      style: context.bodyLarge,
      decoration: InputDecoration(
        labelText: 'Email',
        labelStyle: context.bodyMedium?.copyWith(
          color: context.colorScheme.onSurfaceVariant,
        ),
        hintText: 'Enter your email',
        // Border styles automatically from theme
      ),
    ),
    AppSpacing.mdHeight,
    
    TextFormField(
      style: context.bodyLarge,
      obscureText: true,
      decoration: InputDecoration(
        labelText: 'Password',
        suffixIcon: Icon(
          Icons.visibility_off,
          color: context.colorScheme.onSurfaceVariant,
        ),
      ),
    ),
    AppSpacing.lgHeight,
    
    SizedBox(
      width: double.infinity,
      height: AppSizes.buttonLarge,
      child: ElevatedButton(
        onPressed: () {},
        child: Text('Sign In'),
      ),
    ),
  ],
)
```

**📏 Using Consistent Spacing:**
```dart
Column(
  children: [
    Text('First item'),
    AppSpacing.smHeight,        // 8px spacing
    Text('Second item'),
    AppSpacing.mdHeight,        // 16px spacing
    Text('Third item'),
    AppSpacing.lgHeight,        // 24px spacing
    Text('Fourth item'),
  ],
)

// For padding
Container(
  padding: AppSpacing.xlPadding,    // 32px all around
  child: Text('Padded content'),
)

// For margins
Container(
  margin: AppSpacing.lgVertical,    // 24px top and bottom
  child: Text('Content with margin'),
)
```

**🎨 Using Theme Colors Effectively:**
```dart
// Status colors for different states
Container(
  padding: AppSpacing.smPadding,
  decoration: BoxDecoration(
    color: context.colorScheme.errorContainer,      // 👈 Error state
    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
  ),
  child: Text(
    'Error message',
    style: context.bodyMedium?.copyWith(
      color: context.colorScheme.onErrorContainer,  // 👈 Contrasting text
    ),
  ),
)

// Success state
Container(
  padding: AppSpacing.smPadding,
  decoration: BoxDecoration(
    color: Colors.green.withOpacity(0.1),
    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
  ),
  child: Text(
    'Success message',
    style: context.bodyMedium?.copyWith(
      color: Colors.green.shade700,
    ),
  ),
)
```

### Step 4: Theme Switching (Light/Dark Mode) 🌓

#### 4.1 Setup Theme BLoC with MaterialApp.router

**For apps using GoRouter (MaterialApp.router):**

In your `main.dart`:

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(411, 869),
      minTextAdapt: true,
      builder: (_, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<ThemeBloc>(
              create: (context) => getIt<ThemeBloc>()..add(const InitializeTheme()),
            ),
            // Add other BLoCs as needed
          ],
          child: const AppView(),
        );
      },
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return MaterialApp.router(
          routerConfig: getIt<AppRouter>().routerConfig,    // 👈 Your router config
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          title: 'Your App Name',
          themeMode: themeState.themeMode,                  // 👈 Current theme mode from BLoC
          theme: AppTheme.lightTheme(),                     // 👈 Your light theme
          darkTheme: AppTheme.darkTheme(),                  // 👈 Your dark theme
          builder: (context, child) {
            // Optional: Configure loading indicators with theme colors
            final theme = Theme.of(context);
            EasyLoading.instance
              ..backgroundColor = theme.colorScheme.surface
              ..indicatorColor = theme.colorScheme.primary
              ..textColor = theme.colorScheme.primary
              ..progressColor = theme.colorScheme.primary
              ..loadingStyle = EasyLoadingStyle.custom;
            
            return EasyLoading.init()(context, child);
          },
        );
      },
    );
  }
}
```

**For apps using regular MaterialApp:**

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ThemeBloc>()..add(const InitializeTheme()),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'My App',
            theme: AppTheme.lightTheme(),        // 👈 Your light theme
            darkTheme: AppTheme.darkTheme(),     // 👈 Your dark theme
            themeMode: state.themeMode,          // 👈 Current theme mode
            home: HomeScreen(),
          );
        },
      ),
    );
  }
}
```

#### 4.2 Add Theme Toggle in AppDrawer

**Complete AppDrawer Implementation:**

The `AppDrawer` widget provides a convenient way for users to switch themes from anywhere in your app:

```dart
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      // Drawer theme automatically applied from app_theme.dart
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Themed drawer header
          DrawerHeader(
            decoration: BoxDecoration(
              color: context.colorScheme.primaryContainer,  // 👈 Theme color
            ),
            child: Text(
              'Your App Name',
              style: context.headlineMedium?.copyWith(
                color: context.colorScheme.onPrimaryContainer, // 👈 Contrasting text
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Theme toggle switch with real-time updates
          BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              return SwitchListTile(
                title: Text('Dark Mode', style: context.titleMedium),
                subtitle: Text(
                  state.isDark ? 'Dark theme enabled' : 'Light theme enabled',
                  style: context.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                secondary: Icon(
                  state.isDark ? Icons.dark_mode : Icons.light_mode,
                  color: context.colorScheme.primary,
                ),
                value: state.isDark,
                onChanged: (value) {
                  // Toggle theme and persist preference
                  context.read<ThemeBloc>().add(const ToggleTheme());
                },
              );
            },
          ),
          
          // Other drawer menu items
          DrawerMenuItem(
            icon: Icons.settings,
            title: 'Settings',
            onTap: () => Navigator.pop(context),
          ),
          DrawerMenuItem(
            icon: Icons.help,
            title: 'Help & Support',
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

// Reusable drawer menu item widget
class DrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const DrawerMenuItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: context.colorScheme.onSurfaceVariant,
      ),
      title: Text(
        title,
        style: context.bodyLarge,
      ),
      onTap: onTap,
      // ListTile theme automatically applied from app_theme.dart
    );
  }
}
```

#### 4.3 Using AppDrawer in Your Screens

**Add drawer to any Scaffold:**

```dart
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home', style: context.headlineMedium),
        // AppBar automatically gets hamburger menu icon
      ),
      drawer: const AppDrawer(),  // 👈 Add your themed drawer
      body: YourContent(),
    );
  }
}
```

**Multiple Theme Toggle Options:**

You can provide theme switching in multiple ways throughout your app:

```dart
// 1. In AppBar actions
AppBar(
  title: Text('Settings'),
  actions: [
    BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return IconButton(
          icon: Icon(state.isDark ? Icons.light_mode : Icons.dark_mode),
          onPressed: () => context.read<ThemeBloc>().add(const ToggleTheme()),
          tooltip: state.isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
        );
      },
    ),
  ],
),

// 2. As a settings tile
SwitchListTile(
  title: Text('Dark Mode', style: context.titleMedium),
  value: context.watch<ThemeBloc>().state.isDark,
  onChanged: (value) => context.read<ThemeBloc>().add(const ToggleTheme()),
),

// 3. As a custom toggle button
ElevatedButton.icon(
  onPressed: () => context.read<ThemeBloc>().add(const ToggleTheme()),
  icon: Icon(context.watch<ThemeBloc>().state.isDark 
    ? Icons.light_mode 
    : Icons.dark_mode),
  label: Text(context.watch<ThemeBloc>().state.isDark 
    ? 'Light Mode' 
    : 'Dark Mode'),
),
```

#### 4.4 Advanced Theme Integration Features

**Theme-Aware Loading Indicators:**

Configure loading indicators to match your theme:

```dart
// In MaterialApp.router builder
builder: (context, child) {
  final theme = Theme.of(context);
  
  // Configure EasyLoading with current theme colors
  EasyLoading.instance
    ..backgroundColor = theme.colorScheme.surface
    ..indicatorColor = theme.colorScheme.primary
    ..textColor = theme.colorScheme.onSurface
    ..progressColor = theme.colorScheme.primary
    ..maskColor = theme.colorScheme.onSurface.withOpacity(0.5)
    ..userInteractions = false
    ..loadingStyle = EasyLoadingStyle.custom;
  
  return EasyLoading.init()(context, child);
},
```

**Theme-Aware Status Bar:**

Automatically adjust status bar to match theme:

```dart
// In your main scaffold or app
Widget build(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  
  return AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
    ),
    child: Scaffold(
      // Your content
    ),
  );
}
```

### Step 5: Advanced Theming Techniques 🚀

#### 5.1 Creating Custom Component Themes

**Custom FAB (Floating Action Button):**
```dart
// In app_theme.dart, add to _createTheme():
floatingActionButtonTheme: FloatingActionButtonThemeData(
  backgroundColor: colors.secondary,
  foregroundColor: colors.background,
  elevation: 8,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppSizes.radiusXl),
  ),
),
```

**Custom Bottom Navigation:**
```dart
// In app_theme.dart, add to _createTheme():
bottomNavigationBarTheme: BottomNavigationBarThemeData(
  backgroundColor: colors.surface,
  selectedItemColor: colors.primary,
  unselectedItemColor: colors.textSecondary,
  elevation: 8,
  type: BottomNavigationBarType.fixed,
),
```

**Custom Dialog Theme:**
```dart
// In app_theme.dart, add to _createTheme():
dialogTheme: DialogTheme(
  backgroundColor: colors.surface,
  elevation: 24,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppSizes.radiusXl),
  ),
  titleTextStyle: createTextTheme(colors).headlineSmall,
  contentTextStyle: createTextTheme(colors).bodyMedium,
),
```

#### 5.2 Creating Theme-Aware Custom Widgets

```dart
class ThemedInfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  const ThemedInfoCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      // Automatically gets theme from CardTheme
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Padding(
          padding: AppSpacing.lgPadding,
          child: Row(
            children: [
              Container(
                padding: AppSpacing.smPadding,
                decoration: BoxDecoration(
                  color: context.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Icon(
                  icon,
                  color: context.colorScheme.onPrimaryContainer,
                  size: AppSizes.iconLg,
                ),
              ),
              AppSpacing.mdWidth,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.titleMedium,
                    ),
                    AppSpacing.xsHeight,
                    Text(
                      subtitle,
                      style: context.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: context.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Usage:
ThemedInfoCard(
  title: 'Profile Settings',
  subtitle: 'Manage your account details',
  icon: Icons.person,
  onTap: () {
    // Navigate to profile
  },
)
```

### Step 6: Best Practices & Guidelines 📚

#### ✅ DO These Things:

1. **Always use theme colors:**
   ```dart
   // ✅ Good - Adapts to theme changes
   color: context.colorScheme.primary
   
   // ❌ Bad - Fixed color, ignores theme
   color: Colors.blue
   ```

2. **Always use theme text styles:**
   ```dart
   // ✅ Good - Consistent typography
   style: context.bodyLarge
   
   // ❌ Bad - Custom style, inconsistent
   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)
   ```

3. **Always use spacing constants:**
   ```dart
   // ✅ Good - Consistent spacing
   padding: AppSpacing.mdPadding
   
   // ❌ Bad - Magic numbers
   padding: EdgeInsets.all(16)
   ```

4. **Use semantic color names:**
   ```dart
   // ✅ Good - Semantic meaning
   color: context.colorScheme.error
   color: context.colorScheme.onSurface
   
   // ❌ Bad - Non-semantic
   color: context.colorScheme.red
   ```

5. **Test in both themes:**
   ```dart
   // Always verify your UI works in both light and dark mode
   ```

6. **Provide multiple theme toggle options:**
   ```dart
   // ✅ Good - Multiple ways to change theme
   // - AppDrawer switch
   // - Settings page toggle
   // - AppBar icon button
   
   // ❌ Bad - Only one hidden theme toggle
   ```

7. **Use BlocBuilder for theme-dependent widgets:**
   ```dart
   // ✅ Good - Rebuilds when theme changes
   BlocBuilder<ThemeBloc, ThemeState>(
     builder: (context, state) {
       return YourWidget(isDark: state.isDark);
     },
   )
   ```

#### ❌ DON'T Do These Things:

1. **Don't hardcode colors:**
   ```dart
   // ❌ Bad
   color: Color(0xFF123456)
   color: Colors.red
   ```

2. **Don't hardcode text styles:**
   ```dart
   // ❌ Bad
   TextStyle(
     fontSize: 18,
     fontWeight: FontWeight.bold,
     color: Colors.black,
   )
   ```

3. **Don't use fixed spacing:**
   ```dart
   // ❌ Bad
   SizedBox(height: 20)
   EdgeInsets.symmetric(horizontal: 24, vertical: 12)
   ```

4. **Don't ignore theme extensions:**
   ```dart
   // ❌ Bad - Too verbose
   Theme.of(context).textTheme.bodyLarge
   
   // ✅ Good - Use extensions
   context.bodyLarge
   ```

### Step 7: Testing & Debugging 🧪

#### 7.1 Theme Testing Checklist

**Visual Testing:**
- [ ] Switch between light and dark themes using AppDrawer
- [ ] Check text readability on all backgrounds
- [ ] Verify button styles work in both themes
- [ ] Test input field appearances
- [ ] Check card and container styling
- [ ] Verify navigation components (AppBar, Drawer, BottomNav)
- [ ] Test loading indicators match theme
- [ ] Verify status bar adapts to theme

**Functional Testing:**
- [ ] Theme switching persists across app restarts
- [ ] All colors update when theme changes
- [ ] Custom components respect theme changes
- [ ] No hardcoded colors remain
- [ ] AppDrawer theme toggle works correctly
- [ ] Multiple theme toggle methods work consistently

**Integration Testing:**
- [ ] MaterialApp.router correctly applies themes
- [ ] BLoC state updates propagate to all widgets
- [ ] Theme persistence works with storage
- [ ] GoRouter navigation maintains theme state

#### 7.2 Common Issues & Solutions

**Problem**: AppDrawer doesn't reflect theme changes
**Solution**:
```dart
// Make sure AppDrawer is wrapped in BlocBuilder
BlocBuilder<ThemeBloc, ThemeState>(
  builder: (context, state) {
    return AppDrawer(); // Will rebuild on theme change
  },
)
```

**Problem**: Theme doesn't persist after app restart
**Solution**:
```dart
// Ensure theme initialization in main.dart
BlocProvider<ThemeBloc>(
  create: (context) => getIt<ThemeBloc>()..add(const InitializeTheme()),
)

// And proper storage in ThemeBloc
Future<void> _onToggleTheme(ToggleTheme event, Emitter<ThemeState> emit) async {
  final newIsDark = !state.isDark;
  await _storage.preferences.setDarkMode(newIsDark); // 👈 Don't forget this
  emit(ThemeState(themeMode: newIsDark ? ThemeMode.dark : ThemeMode.light, isDark: newIsDark));
}
```

**Problem**: MaterialApp.router doesn't apply themes
**Solution**:
```dart
// Make sure BlocBuilder wraps MaterialApp.router
BlocBuilder<ThemeBloc, ThemeState>(
  builder: (context, themeState) {
    return MaterialApp.router(
      themeMode: themeState.themeMode,  // 👈 Essential
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      // ...other properties
    );
  },
)
```
