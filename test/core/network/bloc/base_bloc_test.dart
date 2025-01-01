import 'package:dio/dio.dart';
import 'package:flutter_specialized_temp/core/network/config/dio_client.dart';
import 'package:flutter_specialized_temp/core/network/config/interceptors/connectivity_interceptor.dart';
import 'package:flutter_specialized_temp/core/network/config/interceptors/error_interceptor.dart';
import 'package:flutter_specialized_temp/core/network/constants/network_constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_specialized_temp/core/network/services/connection_manager.dart';


import 'base_bloc_test.mocks.dart';

@GenerateMocks([ConnectionManager])
void main() {
  late DioClient dioClient;
  late MockConnectionManager mockConnectionManager;


  setUp(() {
    mockConnectionManager = MockConnectionManager();

    dioClient = DioClient(mockConnectionManager);
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

    test('should have connectivity interceptor', () {
      final dio = dioClient.client;

      expect(dio.interceptors.any((i) => i is ConnectivityInterceptor), true);
    });

    test('should have error interceptor', () {
      final dio = dioClient.client;

      expect(dio.interceptors.any((i) => i is ErrorInterceptor), true);
    });

    test('should handle connection error through interceptor', () async {
      // Arrange

      when(mockConnectionManager.checkInternetConnection())
          .thenAnswer((_) async => false);

      final dio = dioClient.client;

      // Act & Assert
      await expectLater(
        dio.get('/test'),
        throwsA(isA<DioException>().having(
          (e) => e.type,
          'error type',
          DioExceptionType.connectionError,
        )),
      );

      // Verify

      verify(mockConnectionManager.checkInternetConnection()).called(1);
    }, timeout: const Timeout(Duration(seconds: 60)));
  });
}
