import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

@lazySingleton
class ConnectionManager {
  static final ConnectionManager _instance = ConnectionManager._internal();
  factory ConnectionManager() => _instance;
  ConnectionManager._internal();

  final InternetConnectionChecker _connectionChecker =
      InternetConnectionChecker.instance;

  Future<bool> checkInternetConnection() async {
    var isDeviceConnected = false;
    final connectivityResult = await (Connectivity().checkConnectivity());
    
    if (connectivityResult != ConnectivityResult.none) {
        isDeviceConnected = await _connectionChecker.hasConnection;
        
        return isDeviceConnected;
      }
   
    return isDeviceConnected;
  }
}
