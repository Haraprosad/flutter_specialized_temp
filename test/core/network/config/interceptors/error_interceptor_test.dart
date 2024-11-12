import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_specialized_temp/core/network/config/interceptors/error_interceptor.dart';
import 'package:flutter_specialized_temp/core/reporters/error_reporter.dart';

@GenerateMocks([
  ErrorReporter,
  DioException,
  ErrorInterceptorHandler,
  RequestOptions,
  Response,
])
import 'error_interceptor_test.mocks.dart';

void main() {
  late ErrorInterceptor sut;
  late MockErrorReporter mockErrorReporter;
  late MockDioException mockError;
  late MockErrorInterceptorHandler mockHandler;
  late MockRequestOptions mockRequestOptions;
  late MockResponse mockResponse;
  late StackTrace mockStackTrace;

  setUp(() {
    mockErrorReporter = MockErrorReporter();
    mockError = MockDioException();
    mockHandler = MockErrorInterceptorHandler();
    mockRequestOptions = MockRequestOptions();
    mockResponse = MockResponse();
    mockStackTrace = StackTrace.current;

    // Setup default mock responses
    when(mockError.requestOptions).thenReturn(mockRequestOptions);
    when(mockError.stackTrace).thenReturn(mockStackTrace);
    when(mockError.response).thenReturn(mockResponse);
    when(mockRequestOptions.uri).thenReturn(Uri.parse('https://test.com'));
    when(mockRequestOptions.method).thenReturn('GET');
    when(mockResponse.statusCode).thenReturn(404);
    when(mockError.error).thenReturn('Test error');

    sut = ErrorInterceptor(mockErrorReporter);
  });

  group('ErrorInterceptor', () {
    test('should be created with ErrorReporter', () {
      expect(sut, isNotNull);
      expect(sut, isA<ErrorInterceptor>());
    });

    group('onError', () {
      test('should report error with correct metadata', () {
        sut.onError(mockError, mockHandler);

        verify(mockErrorReporter.recordError(
          mockError,
          mockStackTrace,
          metadata: {
            'url': 'https://test.com',
            'method': 'GET',
            'responseCode': 404,
            'error': 'Test error',
          },
        )).called(1);
      });

      test('should handle null response gracefully', () {
        when(mockError.response).thenReturn(null);

        sut.onError(mockError, mockHandler);

        verify(mockErrorReporter.recordError(
          mockError,
          mockStackTrace,
          metadata: {
            'url': 'https://test.com',
            'method': 'GET',
            'responseCode': null,
            'error': 'Test error',
          },
        )).called(1);
      });

      test('should handle null error gracefully', () {
        when(mockError.error).thenReturn(null);

        sut.onError(mockError, mockHandler);

        verify(mockErrorReporter.recordError(
          mockError,
          mockStackTrace,
          metadata: {
            'url': 'https://test.com',
            'method': 'GET',
            'responseCode': 404,
            'error': 'null',
          },
        )).called(1);
      });

      test('should call handler.next with the error', () {
        sut.onError(mockError, mockHandler);

        verify(mockHandler.next(mockError)).called(1);
      });
    });
  });
}