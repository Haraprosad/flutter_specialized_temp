import 'package:flutter/material.dart';
import 'package:flutter_specialized_temp/core/logger/app_logger.dart';

class AppRouterObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    AppLogger.d(
      message:
          'didPush -- route: ${route.settings.name}, previousRoute: ${previousRoute?.settings.name}',
    );
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    AppLogger.d(
      message:
          'didPop -- route: ${route.settings.name}, previousRoute: ${previousRoute?.settings.name}',
    );
    super.didPop(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    AppLogger.d(
      message:
          'didReplace -- newRoute: ${newRoute?.settings.name}, oldRoute: ${oldRoute?.settings.name}',
    );
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    AppLogger.d(
      message:
          'didRemove -- route: ${route.settings.name}, previousRoute: ${previousRoute?.settings.name}',
    );
    super.didRemove(route, previousRoute);
  }
}
