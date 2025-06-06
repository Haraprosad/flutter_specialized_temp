import 'package:flutter/material.dart';
import 'package:flutter_specialized_temp/core/di/injection.dart';
import 'package:flutter_specialized_temp/core/logger/app_logger.dart';
import 'package:flutter_specialized_temp/core/router/route_paths.dart';
import 'package:flutter_specialized_temp/core/storage/app_storage.dart';
import 'package:go_router/go_router.dart';

class RouteGuards {
  static String? authGuard(
    BuildContext context,
    GoRouterState state,
  ) {
    final isAuthenticated = sl<AppStorage>().preferences.getIsAuthenticated();
    final currentLocation = state.matchedLocation;

    final isSplash = currentLocation == RoutePaths.splash;
    final isLoginRoute = currentLocation == RoutePaths.login;
    final isRegisterRoute = currentLocation == RoutePaths.register;

    final publicRoutes = {
      RoutePaths.splash,
      RoutePaths.login,
      RoutePaths.register,
    };

    final isPublicRoute = publicRoutes.contains(currentLocation);

    AppLogger.d(
      message: "Route Guard - Location: $currentLocation, "
          "Authenticated: $isAuthenticated, "
          "IsSplash: $isSplash, "
          "IsLoginRoute: $isLoginRoute, "
          "IsRegisterRoute: $isRegisterRoute",
    );

    // Handle authentication - redirect to login if not authenticated and accessing protected route
    if (!isAuthenticated && !isSplash) {
      if (isLoginRoute || isRegisterRoute) return null;
      return RoutePaths.login;
    }

    // Redirect authenticated users away from auth screens to home
    if (isAuthenticated && (isLoginRoute || isRegisterRoute || isSplash)) {
      return RoutePaths.home;
    }

    return null;
  }

  static bool validateTaskId(String? taskId) {
    if (taskId == null || taskId.isEmpty) {
      AppLogger.w(message: "Invalid task ID: $taskId");
      return false;
    }

    // Add more validation logic as needed
    // You can add regex validation, length checks, etc.
    return true;
  }

  // Additional helper method for role-based routing if needed
  static String? getRoleBasedInitialRoute() {
    final storage = sl<AppStorage>();
    final isAuthenticated = storage.preferences.getIsAuthenticated();

    if (!isAuthenticated) {
      return RoutePaths.login;
    }

    // You can add role-based routing here if needed
    // For example:
    // final userRole = storage.preferences.getUserRole();
    // switch (userRole) {
    //   case 'admin':
    //     return RoutePaths.admin;
    //   case 'driver':
    //     return RoutePaths.driverHome;
    //   default:
    //     return RoutePaths.home;
    // }

    return RoutePaths.home;
  }
}
