import 'dart:async';

import 'package:flutter/material.dart';

import '../logger/app_logger.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;
  
  GoRouterRefreshStream(Stream<dynamic> stream) {
    AppLogger.d(message: "GoRouterRefreshStream created, initializing listener");
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) {
        AppLogger.d(message: "Stream event received, calling notifyListeners()");
        notifyListeners();
        },
    );
  }
  
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}