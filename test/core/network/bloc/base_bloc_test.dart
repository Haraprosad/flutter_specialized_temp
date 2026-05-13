import 'package:dio/dio.dart';
import 'package:flutter_specialized_temp/core/network/config/dio_client.dart';
import 'package:flutter_specialized_temp/core/network/config/interceptors/error_interceptor.dart';
import 'package:flutter_specialized_temp/core/network/constants/network_constants.dart';
import 'package:flutter_specialized_temp/core/storage/app_storage.dart';
import 'package:flutter_specialized_temp/core/storage/secure_storage_manager.dart';
import 'package:flutter_specialized_temp/core/network/services/connection_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

import 'base_bloc_test.mocks.dart';

@GenerateMocks([ConnectionManager, SecureStorageManager, AppStorage])
void main() {
  late DioClient dioClient;
  late MockConnectionManager mockConnectionManager;
  late MockSecureStorageManager mockSecureStorage;
  late MockAppStorage mockAppStorage;

  setUp(() {
    mockConnectionManager = MockConnectionManager();
    mockSecureStorage = MockSecureStorageManager();
    mockAppStorage = MockAppStorage();

    dioClient = DioClient(mockConnectionManager, mockSecureStorage, mockAppStorage);
  });

  group('DioClient Tests', () {
    test('should create Dio instance with correct base configuration', () {
      final dio = dioClient.client;

      expect(dio, isNotNull);
      expect(dio, isA<Dio>());
      expect(dio.options.baseUrl, const String.fromEnvironment('API_BASE_URL'));
    });

    test('should set correct timeout values', () {
      final dio = dioClient.client;

      expect(dio.options.connectTimeout?.inSeconds,
          NetworkConstants.connectionTimeout.inSeconds);
      expect(dio.options.receiveTimeout?.inSeconds,
          NetworkConstants.receiveTimeout.inSeconds);
      expect(dio.options.sendTimeout?.inSeconds,
          NetworkConstants.sendTimeout.inSeconds);
    });

    test('should set correct default headers', () {
      final dio = dioClient.client;

      expect(dio.options.headers['Content-Type'], NetworkConstants.contentType);
      expect(dio.options.headers['Accept'], NetworkConstants.accept);
    });

    test('should have error interceptor', () {
      final dio = dioClient.client;

      expect(dio.interceptors.any((i) => i is ErrorInterceptor), true);
    });
  });
}
