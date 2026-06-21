# Guide 7 — Routing

Complete guide to the routing management system in `lib/core/router/`. Every route in this app is managed through GoRouter, and every navigation-related change **must** go through the files in this directory.

---

## Architecture Overview

The routing system is split across 8 files, each with a single responsibility:

```
lib/core/router/
├── app_router.dart              # GoRouter instance (singleton via DI)
├── app_routes.dart              # All GoRoute / ShellRoute definitions
├── route_names.dart             # Route name constants (for named navigation)
├── route_paths.dart             # Route path constants (URL segments)
├── route_guards.dart            # Auth guards and validation helpers
├── route_transitions.dart       # Custom page transition animations
├── navigator_keys.dart          # GlobalKey<NavigatorState> for nested navigators
└── go_router_refresh_stream.dart # Converts BLoC streams to Listenable for GoRouter
```

### How They Connect

```
                       ┌──────────────────────┐
                       │     AppRouter         │  ← Singleton, injected via GetIt
                       │  (GoRouter instance)  │
                       └──────────┬───────────┘
                                  │ uses
                    ┌─────────────┼─────────────┐
                    ▼             ▼              ▼
              AppRoutes      RouteGuards    GoRouterRefreshStream
              (route tree)   (redirects)    (auth state → refresh)
                    │
        ┌───────────┼───────────┐
        ▼           ▼           ▼
   RoutePaths   RouteNames   RouteTransitions
   (URLs)       (names)      (animations)
```

---

## Step-by-Step: Adding a New Route

Follow these steps **in order** every time you add a new screen/route.

### Step 1 — Add Route Name

Open `lib/core/router/route_names.dart` and add a `static const String` for your route:

```dart
// lib/core/router/route_names.dart
@immutable
class RouteNames {
  const RouteNames._();

  // ... existing names ...

  // Orders Feature
  static const String orders = 'orders';
  static const String orderDetail = 'orderDetail';
  static const String createOrder = 'createOrder';
}
```

**Rules:**
- Use **camelCase** for multi-word names (e.g., `orderDetail`, not `order_detail`)
- Name should describe the **screen**, not the action (e.g., `orderDetail` not `viewOrder`)
- Group by feature with a comment header

### Step 2 — Add Route Path

Open `lib/core/router/route_paths.dart` and add the URL path:

```dart
// lib/core/router/route_paths.dart
@immutable
class RoutePaths {
  const RoutePaths._();

  // ... existing paths ...

  // Orders Feature
  static const String orders = '/orders';           // Top-level: starts with /
  static const String orderDetail = 'detail/:id';   // Nested: relative, no leading /
  static const String createOrder = 'create';        // Nested: relative, no leading /
}
```

**Rules:**
- **Top-level routes** start with `/` (e.g., `/orders`)
- **Nested routes** are relative, no leading `/` (e.g., `detail/:id`)
- Use **kebab-case** for multi-segment paths (e.g., `sub-tasks`)
- Path parameters use `:paramName` syntax (e.g., `:id`, `:taskId`)
- Keep paths short and RESTful

### Step 3 — Add Route Definition

Open `lib/core/router/app_routes.dart` and add the `GoRoute` (or `ShellRoute`):

#### Simple Route (no nesting)

```dart
// Inside AppRoutes class
GoRoute get _ordersRoute => GoRoute(
  path: RoutePaths.orders,
  name: RouteNames.orders,
  builder: (context, state) => const OrdersScreen(),
);
```

#### Route with Nested Children

```dart
GoRoute get _ordersRoute => GoRoute(
  path: RoutePaths.orders,
  name: RouteNames.orders,
  builder: (context, state) => const OrdersScreen(),
  routes: [
    GoRoute(
      path: RoutePaths.orderDetail,
      name: RouteNames.orderDetail,
      builder: (context, state) {
        final orderId = state.pathParameters['id']!;
        return OrderDetailScreen(orderId: orderId);
      },
    ),
    GoRoute(
      path: RoutePaths.createOrder,
      name: RouteNames.createOrder,
      pageBuilder: (context, state) => RouteTransitions.slideTransition(
        const CreateOrderScreen(),
      ),
    ),
  ],
);
```

#### Route with BLoC Scoped via ShellRoute

When a group of screens shares a BLoC (e.g., list → detail → edit all share the same BLoC):

```dart
ShellRoute get _ordersShellRoute => ShellRoute(
  builder: (context, state, child) {
    return BlocProvider(
      create: (_) => sl<OrdersBloc>(),
      child: child,
    );
  },
  routes: [
    GoRoute(
      path: RoutePaths.orders,
      name: RouteNames.orders,
      builder: (context, state) => const OrdersScreen(),
      routes: [
        // nested routes here...
      ],
    ),
  ],
);
```

### Step 4 — Register the Route in the Route Tree

Still in `app_routes.dart`, add your new route to the appropriate parent:

```dart
// For a new tab in bottom navigation (inside the main shell):
ShellRoute get _mainShellRoute => ShellRoute(
  navigatorKey: NavigatorKeys.shellNavigator,
  builder: (context, state, child) {
    return ScaffoldWithBottomNav(child: child);
  },
  routes: [
    _homeRoute,
    _tasksShellRoute,
    _ordersRoute,        // ← Add here for bottom-nav tab
    _profileRoute,
    _settingsRoute,
  ],
);

// For a standalone route (outside bottom nav):
List<RouteBase> get routes => [
  splashRoute,
  ..._authRoutes,
  _standaloneRoute,    // ← Add here for full-screen routes outside the shell
  _mainShellRoute,
];
```

### Step 5 — Add Transition (Optional)

If the route needs a custom transition, use `pageBuilder` instead of `builder` and pick from `RouteTransitions`:

```dart
GoRoute(
  path: RoutePaths.createOrder,
  name: RouteNames.createOrder,
  pageBuilder: (context, state) => RouteTransitions.slideTransition(
    const CreateOrderScreen(),
    begin: const Offset(0, 1),   // Slide from bottom
  ),
),
```

Available transitions in `route_transitions.dart`:

| Transition | Usage | Default |
|---|---|---|
| `RouteTransitions.fadeTransition(child)` | Cross-fade | 300ms |
| `RouteTransitions.slideTransition(child, begin:)` | Slide from direction | 300ms, from right `Offset(1, 0)` |
| `RouteTransitions.scaleTransition(child)` | Scale up | 300ms |

All accept an optional `duration` parameter.

### Step 6 — Add Route Guard (If Needed)

If your route needs additional protection beyond auth (e.g., role-based access, parameter validation), add it to `lib/core/router/route_guards.dart`:

```dart
class RouteGuards {
  // ... existing guards ...

  /// Validates that an order ID is a valid format
  static bool validateOrderId(String? orderId) {
    if (orderId == null || orderId.isEmpty) {
      AppLogger.w(message: "Invalid order ID: $orderId");
      return false;
    }
    return true;
  }
}
```

Then use it in the route builder:

```dart
builder: (context, state) {
  final orderId = state.pathParameters['id']!;
  if (!RouteGuards.validateOrderId(orderId)) {
    return const Scaffold(
      body: Center(child: Text('Invalid Order ID')),
    );
  }
  return OrderDetailScreen(orderId: orderId);
},
```

---

## Navigation Patterns

### How to Navigate

Always use GoRouter's named navigation with `RouteNames` constants. Never hardcode route strings.

```dart
// ✅ CORRECT — Named navigation with RouteNames
context.goNamed(RouteNames.orders);

// ✅ CORRECT — Named navigation with parameters
context.goNamed(
  RouteNames.orderDetail,
  pathParameters: {'id': order.id},
);

// ✅ CORRECT — Named navigation with query parameters
context.goNamed(
  RouteNames.orders,
  queryParameters: {'status': 'pending', 'page': '1'},
);

// ✅ CORRECT — Push (adds to stack instead of replacing)
context.pushNamed(RouteNames.createOrder);

// ✅ CORRECT — Go back
context.pop();

// ❌ WRONG — Hardcoded path strings
context.go('/orders/detail/123');

// ❌ WRONG — Navigator.push (bypasses GoRouter)
Navigator.push(context, MaterialPageRoute(...));

// ❌ WRONG — Navigator.pushNamed (bypasses GoRouter)
Navigator.pushNamed(context, '/orders');
```

### `go` vs `push` vs `pop`

| Method | Behavior | Use When |
|---|---|---|
| `context.goNamed(...)` | Replaces navigation stack | Navigating to a primary destination (tab switch, going home) |
| `context.pushNamed(...)` | Pushes onto stack | Opening a detail/create/edit screen (user expects back button) |
| `context.pop()` | Pops the top route | Going back from a pushed screen |
| `context.pop(result)` | Pops with return value | Returning data from a dialog/form screen |

### Passing Data Between Routes

**Path parameters** — for resource identifiers (part of the URL):
```dart
// Define:  'detail/:id'
// Navigate:
context.goNamed(RouteNames.orderDetail, pathParameters: {'id': '123'});
// Read:
final id = state.pathParameters['id']!;
```

**Query parameters** — for filters, optional data (not part of the URL hierarchy):
```dart
// Navigate:
context.goNamed(RouteNames.orders, queryParameters: {'status': 'pending'});
// Read:
final status = state.uri.queryParameters['status'];
```

**Extra** — for complex objects (not serializable in URL, lost on deep link):
```dart
// Navigate:
context.goNamed(RouteNames.orderDetail, extra: orderEntity);
// Read:
final order = state.extra as OrderEntity?;
```

> **Prefer path/query parameters over `extra`.** Extra data is lost if the user refreshes (web) or deep-links into the route.

---

## Shell Routes and Bottom Navigation

The app uses a `ShellRoute` for bottom navigation. The `ScaffoldWithBottomNav` widget provides the persistent bottom bar, and each tab is a child route.

```
ShellRoute (ScaffoldWithBottomNav)
├── /home       → HomeScreen
├── /tasks      → TasksScreen (wrapped in another ShellRoute for shared BLoC)
├── /profile    → ProfileScreen
└── /settings   → SettingsScreen
```

### Adding a New Bottom-Nav Tab

1. Add path and name constants (Steps 1–2)
2. Add the route definition (Step 3)
3. Add it to `_mainShellRoute.routes` list in `app_routes.dart` (Step 4)
4. Update `ScaffoldWithBottomNav` in `lib/core/widgets/scaffold_with_bottom_nav.dart` to include the new tab icon and label
5. Update `NavigationBloc` if tab indices are managed there

### Routes Outside the Shell

Auth screens (login, register, splash) and any full-screen modals should be placed **outside** the shell route — directly in the `routes` list, not inside `_mainShellRoute`:

```dart
List<RouteBase> get routes => [
  splashRoute,
  ..._authRoutes,
  _onboardingRoute,    // ← Outside shell: no bottom nav
  _mainShellRoute,     // ← Inside shell: has bottom nav
];
```

---

## Auth Guard Flow

The global auth guard in `route_guards.dart` runs on every navigation:

```
User navigates
  │
  ▼
Is authenticated?
  │
  ├── NO  → Is current route /splash, /login, or /register?
  │         ├── YES → Allow (stay on auth screen)
  │         └── NO  → Redirect to /login
  │
  └── YES → Is current route /splash, /login, or /register?
            ├── YES → Redirect to /home (don't show auth screens to logged-in users)
            └── NO  → Allow (proceed normally)
```

The guard reacts automatically to `AuthBloc` state changes via `GoRouterRefreshStream`.

---

## Navigator Keys

`NavigatorKeys` provides two global navigator keys:

| Key | Purpose |
|---|---|
| `NavigatorKeys.rootNavigator` | Root GoRouter navigator — used for full-screen routes that cover the bottom nav |
| `NavigatorKeys.shellNavigator` | Shell route navigator — used for routes within the bottom nav |

When you need a route to appear **above** the bottom nav (e.g., a full-screen modal), specify `parentNavigatorKey`:

```dart
GoRoute(
  parentNavigatorKey: NavigatorKeys.rootNavigator,
  path: RoutePaths.fullScreenModal,
  name: RouteNames.fullScreenModal,
  builder: (context, state) => const FullScreenModalScreen(),
),
```

---

## Complete Checklist for a New Route

- [ ] Route name added to `route_names.dart` (camelCase, grouped by feature)
- [ ] Route path added to `route_paths.dart` (top-level with `/`, nested without)
- [ ] `GoRoute` definition added to `app_routes.dart` with `builder` or `pageBuilder`
- [ ] Route registered in the correct parent (shell vs. top-level in `routes` getter)
- [ ] Path parameters validated in the builder (use `RouteGuards` helpers)
- [ ] Custom transition added via `RouteTransitions` if needed
- [ ] Navigation uses `context.goNamed` / `context.pushNamed` with `RouteNames` constants
- [ ] No hardcoded path strings anywhere in the codebase
- [ ] No `Navigator.push` / `Navigator.pushNamed` calls (use GoRouter exclusively)
- [ ] If new bottom-nav tab: `ScaffoldWithBottomNav` updated with new tab

---

## Common Mistakes to Avoid

| Mistake | Why It's Wrong | Fix |
|---|---|---|
| Hardcoding `'/orders/detail/123'` | Fragile, refactoring-unsafe | Use `context.goNamed(RouteNames.orderDetail, pathParameters: {'id': '123'})` |
| Using `Navigator.push()` | Bypasses GoRouter guards and state | Use `context.pushNamed()` |
| Adding path with `/` for nested routes | GoRouter treats it as absolute | Use relative paths for nested routes (e.g., `detail/:id` not `/detail/:id`) |
| Putting auth screens inside `ShellRoute` | They'd show the bottom nav bar | Keep auth routes outside the shell |
| Forgetting to add route name **and** path | Navigation by name fails silently | Always add both in sync |
| Using `extra` for critical data | Lost on web refresh / deep link | Prefer path or query parameters |
| Creating a new `GoRouter` instance | Breaks DI and guard system | Use the singleton `AppRouter` from GetIt |
