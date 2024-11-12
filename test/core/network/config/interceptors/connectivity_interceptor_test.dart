import 'package:dio/dio.dart';
import 'package:flutter_specialized_temp/core/network/config/interceptors/connectivity_interceptor.dart';
import 'package:flutter_specialized_temp/core/network/enums/custom_error_type.dart';
import 'package:flutter_specialized_temp/core/network/services/connection_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'connectivity_interceptor_test.mocks.dart';

@GenerateMocks([ConnectionManager, RequestInterceptorHandler])
void main() {
  late ConnectivityInterceptor interceptor;
  late MockConnectionManager connectionManager;
  late MockRequestInterceptorHandler handler;
  late RequestOptions options;

  setUp(() {
    connectionManager = MockConnectionManager();
    handler = MockRequestInterceptorHandler();
    interceptor = ConnectivityInterceptor(connectionManager);
    options = RequestOptions(path: 'test/path');
  });

  group('ConnectivityInterceptor', () {
    test('should reject request when no internet connection', () async {
      // Arrange
      when(connectionManager.checkInternetConnection())
          .thenAnswer((_) async => false);

      // Act
      await interceptor.onRequest(options, handler);

      // Assert
      verify(handler.reject(any)).called(1);
      verifyNever(handler.next(any));
    });

    test('should proceed with request when internet connection exists', () async {
      // Arrange
      when(connectionManager.checkInternetConnection())
          .thenAnswer((_) async => true);

      // Act
      await interceptor.onRequest(options, handler);

      // Assert
      verify(handler.next(options)).called(1);
      verifyNever(handler.reject(any));
    });

    test('should pass correct error type when rejecting', () async {
      // Arrange
      when(connectionManager.checkInternetConnection())
          .thenAnswer((_) async => false);

      // Act
      await interceptor.onRequest(options, handler);

      // Assert
      verify(
        handler.reject(
          argThat(
            isA<DioException>()
                .having((e) => e.type, 'type', DioExceptionType.connectionError)
                .having((e) => e.error, 'error', CustomErrorType.noInternet),
          ),
        ),
      ).called(1);
    });
  });
}