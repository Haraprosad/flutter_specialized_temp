import 'package:flutter/material.dart';
import 'package:flutter_specialized_temp/core/logger/app_logger.dart';

class AppRouterObserver extends NavigatorObserver{
    // Private constructor
  AppRouterObserver._();

  // Singleton instance
  static final AppRouterObserver _instance = AppRouterObserver._();

  // Public factory constructor that returns the singleton instance
  factory AppRouterObserver() => _instance;
 
  @override
  void didPush(Route route, Route? previousRoute) {
    AppLogger.d(message: 'didPush -- route: ${route.settings.name}, previousRoute: ${previousRoute?.settings.name}');
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    AppLogger.d(message: 'didPop -- route: ${route.settings.name}, previousRoute: ${previousRoute?.settings.name}');
    super.didPop(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    AppLogger.d(message: 'didReplace -- newRoute: ${newRoute?.settings.name}, oldRoute: ${oldRoute?.settings.name}');
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    AppLogger.d(message: 'didRemove -- route: ${route.settings.name}, previousRoute: ${previousRoute?.settings.name}');
    super.didRemove(route, previousRoute);
  }

}