import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:flutter_specialized_temp/core/logger/app_logger.dart';

/// Monitors internet connectivity and provides instant connection status.
///
/// Instead of checking connectivity before every request (which is slow),
/// this runs in the background and keeps track of connection state. You get
/// instant access to whether you're online or not - no waiting!
///
/// Performance win: 0ms vs 200-500ms per request if we checked every time
@lazySingleton
class ConnectionManager {
  static final ConnectionManager _instance = ConnectionManager._internal();
  factory ConnectionManager() => _instance;
  ConnectionManager._internal();

  final InternetConnectionChecker _connectionChecker =
      InternetConnectionChecker.instance;
  final Connectivity _connectivity = Connectivity();

  // Broadcasts connection changes to anyone listening
  final _connectivityController = StreamController<bool>.broadcast();

  // Cached state - this is what makes lookups instant
  bool _isConnected = true;

  // Keep references so we can cancel these later
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  StreamSubscription<InternetConnectionStatus>? _connectionStatusSubscription;

  /// Subscribe to get notified whenever connection status changes
  Stream<bool> get connectivityStream => _connectivityController.stream;

  /// Get current status instantly - no async needed!
  bool get isConnected => _isConnected;

  /// Old way to check connection - kept for backwards compatibility.
  ///
  /// Note: This is slower since it checks every time. Better to use
  /// the `isConnected` getter which returns the cached state instantly.
  Future<bool> checkInternetConnection() async {
    var isDeviceConnected = false;
    final connectivityResult = await _connectivity.checkConnectivity();

    if (connectivityResult.isNotEmpty &&
        !connectivityResult.contains(ConnectivityResult.none)) {
      isDeviceConnected = await _connectionChecker.hasConnection;
      return isDeviceConnected;
    }

    return isDeviceConnected;
  }

  /// Starts background monitoring - call this once when app launches
  void startMonitoring() {
    AppLogger.i(message: '🌐 Starting connectivity monitoring...');

    // Watch for network type changes (WiFi -> Mobile, etc)
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      results,
    ) {
      AppLogger.d(message: '📡 Connectivity changed: $results');
      _checkAndUpdateConnectionStatus();
    });

    // Watch for actual internet reachability changes
    _connectionStatusSubscription = _connectionChecker.onStatusChange.listen((
      status,
    ) {
      final isConnected = status == InternetConnectionStatus.connected;
      _updateConnectionStatus(isConnected);
    });

    // Check what the status is right now
    _checkAndUpdateConnectionStatus();
  }

  /// Stop monitoring connectivity
  /// Call this when disposing or app is closing
  void stopMonitoring() {
    AppLogger.i(message: '🌐 Stopping connectivity monitoring...');
    _connectivitySubscription?.cancel();
    _connectionStatusSubscription?.cancel();
  }

  /// Check and update connection status
  Future<void> _checkAndUpdateConnectionStatus() async {
    final hasInternet = await checkInternetConnection();
    _updateConnectionStatus(hasInternet);
  }

  /// Update cached connection status and notify listeners
  void _updateConnectionStatus(bool isConnected) {
    if (_isConnected != isConnected) {
      _isConnected = isConnected;
      _connectivityController.add(_isConnected);

      if (isConnected) {
        AppLogger.i(message: '✅ Internet connection restored');
      } else {
        AppLogger.w(message: '❌ Internet connection lost');
      }
    }
  }

  /// Dispose resources
  void dispose() {
    stopMonitoring();
    _connectivityController.close();
  }
}
