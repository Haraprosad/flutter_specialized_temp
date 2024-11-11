import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

@module
abstract class RegisterModule {
  @lazySingleton
  Dio get dio => Dio();

  @lazySingleton
  InternetConnectionChecker get connectionChecker =>
      InternetConnectionChecker();

  @lazySingleton
  Connectivity get connectivity => Connectivity();

  //Storage Part
  @preResolve  // Important because SharedPreferences.getInstance() is async
  Future<SharedPreferences> get sharedPreferences => 
      SharedPreferences.getInstance();

  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage(
        aOptions: AndroidOptions(
          encryptedSharedPreferences: true,
          sharedPreferencesName: 'securePrefs',
          preferencesKeyPrefix: 'secure_',
        ),
        iOptions: IOSOptions(
          accessibility: KeychainAccessibility.first_unlock,
          synchronizable: false,
        ),
      );
}
