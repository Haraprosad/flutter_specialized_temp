import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_specialized_temp/core/logger/app_logger.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    AppLogger.d(
      message: "GoRouterRefreshStream created, initializing listener",
    );
    _subscription = stream.asBroadcastStream().listen((dynamic _) {
      AppLogger.d(message: "Stream event received, calling notifyListeners()");
      notifyListeners();
    });
  }
  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
