# Route Management System Documentation

## Overview

This Flutter application uses **GoRouter** as the primary routing solution, providing declarative routing with support for deep linking, nested navigation, and state management integration. The system is designed to handle everything from simple navigation to complex multi-level routing scenarios like trading apps, social media platforms, and enterprise applications.

## Architecture

The route management system is organized into several key components:
```
core/router/
├── app_router.dart                 # Main router configuration & initialization
├── app_routes.dart                 # Route definitions, builders & structure
├── route_paths.dart                # Path constants & helper methods
├── route_names.dart                # Route name constants for type safety
├── route_guards.dart               # Authentication & validation guards
├── route_transitions.dart          # Custom page transitions & animations
├── navigator_keys.dart             # Navigator key definitions for nested routing
└── go_router_refresh_stream.dart   # Stream-based router refresh mechanism
```

## File Breakdown & Usage

### 1. `app_router.dart` - The Main Router Engine
**What it does:**
- Initializes the GoRouter configuration
- Sets up global redirect logic using route guards
- Manages router refresh streams for state changes
- Handles global error screens and observers

**Key Features:**
```dart
// Main router configuration
GoRouter(
  navigatorKey: NavigatorKeys.rootNavigator,  // Root navigator
  initialLocation: RoutePaths.splash,         // App entry point
  redirect: RouteGuards.authGuard,           // Global authentication
  refreshListenable: GoRouterRefreshStream,   // Auto-refresh on state changes
  errorBuilder: ErrorScreen,                  // Global error handling
)
```

### 2. `app_routes.dart` - Route Structure Definition
**What it does:**
- Defines the complete route tree structure
- Manages nested routes and shell routes
- Handles BLoC providers for specific route branches
- Implements custom page transitions

**Key Patterns:**
```dart
// Shell Routes for persistent UI (bottom nav, tabs)
ShellRoute(
  builder: (context, state, child) => ScaffoldWithBottomNav(child: child),
  routes: [...] // Child routes maintain shell UI
)

// Nested Shell Routes for scoped state management
ShellRoute(
  builder: (context, state, child) => BlocProvider(
    create: (_) => sl<TaskBloc>(),
    child: child,
  ),
  routes: [...] // Routes with shared BLoC instance
)
```

### 3. `route_paths.dart` - Path Management
**What it does:**
- Centralizes all route path constants
- Provides helper methods for parameterized routes
- Maintains consistency across the application

**Usage Examples:**
```dart
static const String taskDetails = 'details/:taskId';
static String taskDetailsPath(String taskId) => '/tasks/details/$taskId';
```

### 4. `route_names.dart` - Type-Safe Navigation
**What it does:**
- Provides named constants for type-safe navigation
- Prevents typos and runtime errors
- Enables IDE autocomplete and refactoring

**Usage:**
```dart
context.goNamed(RouteNames.taskDetails); // Type-safe
context.go('/tasks/details/123');        // Error-prone
```

### 5. `route_guards.dart` - Security & Validation
**What it does:**
- Implements authentication guards using local storage
- Validates route parameters
- Handles role-based access control
- Manages redirect logic

**Key Methods:**
```dart
// Authentication guard
static String? authGuard(BuildContext context, GoRouterState state)

// Parameter validation  
static bool validateTaskId(String? taskId)

// Role-based routing
static String? getRoleBasedInitialRoute()
```

### 6. `route_transitions.dart` - Animation Management
**What it does:**
- Provides reusable page transition animations
- Maintains consistent UX across the app
- Supports custom animation curves and durations

**Available Transitions:**
```dart
RouteTransitions.fadeTransition(widget)     // Fade in/out
RouteTransitions.slideTransition(widget)    // Slide from edges
RouteTransitions.scaleTransition(widget)    // Scale animation
```

### 7. `navigator_keys.dart` - Navigation Context
**What it does:**
- Defines GlobalKey<NavigatorState> for different navigation contexts
- Enables programmatic navigation from anywhere in the app
- Supports nested navigation scenarios

### 8. `go_router_refresh_stream.dart` - State Synchronization
**What it does:**
- Listens to BLoC state changes
- Triggers router refresh when authentication state changes
- Ensures route guards re-evaluate on state updates

## Common Routing Scenarios & Implementation

### 1. Simple Navigation (Basic App Flow)
```dart
// Navigate to a screen
context.goNamed(RouteNames.profile);

// Navigate with data
context.goNamed(
  RouteNames.taskDetails,
  pathParameters: {'taskId': '123'},
  extra: {'title': 'Task Title'}, // Pass complex data
);

// Go back
context.pop();
```

### 2. Bottom Navigation (Instagram/WhatsApp Style)
```dart
// Already implemented in ScaffoldWithBottomNav
ShellRoute(
  builder: (context, state, child) => ScaffoldWithBottomNav(child: child),
  routes: [
    GoRoute(path: '/home', builder: (context, state) => HomeScreen()),
    GoRoute(path: '/tasks', builder: (context, state) => TasksScreen()),
    GoRoute(path: '/profile', builder: (context, state) => ProfileScreen()),
  ],
)
```

### 3. Tab Navigation (YouTube/Netflix Style)
```dart
// In your routes definition
GoRoute(
  path: '/discover',
  builder: (context, state) => DefaultTabController(
    length: 4,
    child: Scaffold(
      appBar: TabBar(tabs: [
        Tab(text: 'Movies'),
        Tab(text: 'TV Shows'),
        Tab(text: 'Popular'),
        Tab(text: 'Trending'),
      ]),
      body: TabBarView(children: [
        MoviesTab(),
        TVShowsTab(), 
        PopularTab(),
        TrendingTab(),
      ]),
    ),
  ),
  routes: [
    GoRoute(
      path: 'movie/:movieId',
      builder: (context, state) => MovieDetailsScreen(
        movieId: state.pathParameters['movieId']!,
      ),
    ),
  ],
)
```

### 4. Search Flow (Twitter/Instagram Style)
```dart
// Add to app_routes.dart
GoRoute(
  path: '/search',
  name: RouteNames.search,
  builder: (context, state) => SearchScreen(),
  routes: [
    GoRoute(
      path: 'results',
      name: RouteNames.searchResults,
      builder: (context, state) => SearchResultsScreen(
        query: state.uri.queryParameters['q'] ?? '',
      ),
    ),
    GoRoute(
      path: 'user/:userId',
      name: RouteNames.userProfile,
      builder: (context, state) => UserProfileScreen(
        userId: state.pathParameters['userId']!,
      ),
    ),
  ],
)

// Usage in search screen
void _performSearch(String query) {
  context.goNamed(
    RouteNames.searchResults,
    queryParameters: {'q': query},
  );
}
```

### 5. Notifications System (Facebook Style)
```dart
// Add notification routes
GoRoute(
  path: '/notifications',
  name: RouteNames.notifications,
  builder: (context, state) => NotificationsScreen(),
  routes: [
    GoRoute(
      path: 'thread/:threadId',
      builder: (context, state) => NotificationThreadScreen(
        threadId: state.pathParameters['threadId']!,
      ),
    ),
  ],
)

// Deep link handling for push notifications
void handleNotificationTap(String notificationId, String type) {
  switch (type) {
    case 'message':
      context.goNamed(RouteNames.chat, pathParameters: {'chatId': notificationId});
      break;
    case 'like':
      context.goNamed(RouteNames.postDetails, pathParameters: {'postId': notificationId});
      break;
  }
}
```

### 6. Complex Nested Navigation (Binance/Trading App Style)
```dart
// Multi-level navigation with persistent state
ShellRoute(
  builder: (context, state, child) => TradingAppShell(child: child),
  routes: [
    // Markets section with nested tabs
    ShellRoute(
      builder: (context, state, child) => MarketsShell(child: child),
      routes: [
        GoRoute(
          path: '/markets',
          builder: (context, state) => DefaultTabController(
            length: 3,
            child: MarketsTabView(),
          ),
          routes: [
            // Individual coin details
            GoRoute(
              path: 'coin/:symbol',
              builder: (context, state) => CoinDetailsScreen(
                symbol: state.pathParameters['symbol']!,
              ),
              routes: [
                // Trading interface
                GoRoute(
                  path: 'trade',
                  builder: (context, state) => TradingScreen(
                    symbol: state.pathParameters['symbol']!,
                  ),
                  routes: [
                    // Order history
                    GoRoute(
                      path: 'orders',
                      builder: (context, state) => OrderHistoryScreen(),
                    ),
                  ],
                ),
                // Chart analysis
                GoRoute(
                  path: 'chart',
                  builder: (context, state) => ChartAnalysisScreen(
                    symbol: state.pathParameters['symbol']!,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    
    // Portfolio section
    GoRoute(
      path: '/portfolio',
      builder: (context, state) => PortfolioScreen(),
      routes: [
        GoRoute(
          path: 'asset/:assetId',
          builder: (context, state) => AssetDetailsScreen(
            assetId: state.pathParameters['assetId']!,
          ),
        ),
      ],
    ),
  ],
)
```

### 7. Modal Routes & Overlays
```dart
// Full-screen modal
void showFullScreenModal(BuildContext context) {
  context.pushNamed(RouteNames.createPost);
}

// In routes definition
GoRoute(
  path: '/create-post',
  name: RouteNames.createPost,
  pageBuilder: (context, state) => CustomTransitionPage(
    child: CreatePostScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween(begin: Offset(0, 1), end: Offset.zero)
            .animate(animation),
        child: child,
      );
    },
  ),
)

// Bottom sheet style modal
GoRoute(
  path: '/filters',
  pageBuilder: (context, state) => CustomTransitionPage(
    child: FiltersScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween(begin: Offset(0, 1), end: Offset.zero)
            .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
        child: child,
      );
    },
  ),
)
```

### 8. Authentication Flow with Onboarding
```dart
// Add to route_guards.dart
static String? authGuard(BuildContext context, GoRouterState state) {
  final storage = sl<AppStorage>();
  final isAuthenticated = storage.preferences.getIsAuthenticated();
  final hasSeenOnboarding = storage.preferences.getHasSeenOnboarding();
  
  // First time user - show onboarding
  if (!hasSeenOnboarding && state.matchedLocation != RoutePaths.onboarding) {
    return RoutePaths.onboarding;
  }
  
  // Existing authentication logic...
}

// Add onboarding routes
GoRoute(
  path: '/onboarding',
  name: RouteNames.onboarding,
  builder: (context, state) => OnboardingScreen(),
  routes: [
    GoRoute(
      path: 'welcome',
      builder: (context, state) => WelcomeScreen(),
    ),
    GoRoute(
      path: 'features',
      builder: (context, state) => FeaturesScreen(),
    ),
    GoRoute(
      path: 'permissions',
      builder: (context, state) => PermissionsScreen(),
    ),
  ],
)
```

### 9. Role-Based Routing (Admin/User Dashboards)
```dart
// Enhanced role-based guard
static String? getRoleBasedInitialRoute() {
  final storage = sl<AppStorage>();
  final userRole = storage.preferences.getUserRole();
  
  switch (userRole) {
    case 'admin':
      return RoutePaths.adminDashboard;
    case 'moderator':
      return RoutePaths.moderatorDashboard;
    case 'premium':
      return RoutePaths.premiumHome;
    default:
      return RoutePaths.home;
  }
}

// Role-specific routes
GoRoute(
  path: '/admin',
  builder: (context, state) => AdminDashboard(),
  redirect: (context, state) {
    final role = sl<AppStorage>().preferences.getUserRole();
    return role == 'admin' ? null : RoutePaths.home;
  },
  routes: [
    GoRoute(path: 'users', builder: (context, state) => UserManagementScreen()),
    GoRoute(path: 'analytics', builder: (context, state) => AnalyticsScreen()),
    GoRoute(path: 'settings', builder: (context, state) => AdminSettingsScreen()),
  ],
)
```

### 10. Deep Linking & URL Handling
```dart
// Handle custom URL schemes
class DeepLinkHandler {
  static void handleDeepLink(String link) {
    final uri = Uri.parse(link);
    final context = NavigatorKeys.rootNavigator.currentContext;
    
    if (context == null) return;
    
    switch (uri.pathSegments.first) {
      case 'user':
        context.goNamed(
          RouteNames.userProfile,
          pathParameters: {'userId': uri.pathSegments[1]},
        );
        break;
      case 'post':
        context.goNamed(
          RouteNames.postDetails,
          pathParameters: {'postId': uri.pathSegments[1]},
        );
        break;
      case 'share':
        _handleShareLink(context, uri);
        break;
    }
  }
}

// URL generation for sharing
String generateShareUrl(String postId) {
  return 'https://myapp.com/post/$postId';
}
```

## Implementation Guide for New Developers

### Step 1: Basic Setup
1. Ensure all route files are properly imported in your main app
2. Set up dependency injection for AppRouter
3. Configure MaterialApp.router with your router configuration

### Step 2: Adding Simple Routes
```dart
// 1. Add path constant
static const String newFeature = '/new-feature';

// 2. Add name constant  
static const String newFeature = 'newFeature';

// 3. Add route definition
GoRoute(
  path: RoutePaths.newFeature,
  name: RouteNames.newFeature,
  builder: (context, state) => NewFeatureScreen(),
)

// 4. Navigate to it
context.goNamed(RouteNames.newFeature);
```

### Step 3: Adding Nested Routes
```dart
// Parent route with children
GoRoute(
  path: '/parent',
  builder: (context, state) => ParentScreen(),
  routes: [
    GoRoute(
      path: 'child/:id',  // Will be /parent/child/:id
      builder: (context, state) => ChildScreen(
        id: state.pathParameters['id']!,
      ),
    ),
  ],
)
```

### Step 4: Adding Shell Routes (Persistent UI)
```dart
ShellRoute(
  builder: (context, state, child) => MyShellWrapper(child: child),
  routes: [
    // Your routes here will maintain the shell
  ],
)
```

### Step 5: Adding Route Guards
```dart
// In route definition
redirect: (context, state) {
  if (needsAuth && !isLoggedIn) {
    return RoutePaths.login;
  }
  return null;
}
```

## Best Practices

1. **Always use named routes** for type safety
2. **Validate parameters** in route guards
3. **Use helper methods** for complex path generation
4. **Implement proper error handling** for invalid routes
5. **Use Shell routes** to avoid unnecessary rebuilds
6. **Cache expensive route data** using BLoC providers
7. **Test deep linking** thoroughly across platforms
8. **Document route parameters** and expected data types

## Performance Considerations

- **Lazy loading**: Routes are built only when accessed
- **State preservation**: Shell routes prevent unnecessary widget rebuilds
- **Memory management**: Dispose of resources in route-specific BLoCs
- **Bundle splitting**: Consider code splitting for large route branches

## Testing Routes

```dart
// Route testing example
void main() {
  testWidgets('should navigate to task details', (tester) async {
    final router = GoRouter(routes: appRoutes);
    
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    
    router.goNamed(RouteNames.taskDetails, pathParameters: {'taskId': '123'});
    await tester.pumpAndSettle();
    
    expect(find.text('Task Details'), findsOneWidget);
  });
}
```

This routing system provides the foundation for any complexity level - from simple apps to complex multi-level applications like trading platforms, social media apps, or enterprise solutions.