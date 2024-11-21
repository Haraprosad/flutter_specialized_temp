import 'package:dio/dio.dart';
import 'package:flutter_specialized_temp/core/network/constants/response_code.dart';
import 'package:flutter_specialized_temp/core/network/enums/custom_error_type.dart';
import 'package:flutter_specialized_temp/core/network/constants/error_messages_key.dart';
import 'package:flutter_specialized_temp/core/network/error_handling/models/custom_exception.dart';
import 'package:flutter_specialized_temp/core/network/services/localization_service/localization_service.dart';
import 'package:flutter_specialized_temp/core/network/error_handling/models/api_call_failure_model.dart';
import 'package:injectable/injectable.dart';

/// Class that handles network errors and provides localized error messages.
@lazySingleton
class NetworkErrorHandler {
  final LocalizationService _localizationService;

  NetworkErrorHandler(this._localizationService);

  /// Main method to handle errors, including Dio exceptions.
  ApiCallFailureModel handleError(dynamic error, [StackTrace? stackTrace]) {
    if (error is DioException) {
      if (error.error == CustomErrorType.noInternet) {
        return ApiCallFailureModel(
          code: ResponseCode.NO_INTERNET,
          translatedMessage:
              _localizationService.translate(ErrorMessagesKey.noInternet),
          technicalMessage: 'No internet connection',
          stackTrace: stackTrace,
        );
      }
      return _handleDioError(error, stackTrace);
    } else {
      if (error is CustomException) {
        return _handleCustomException(error, stackTrace);
      }
      return ApiCallFailureModel(
        code: ResponseCode.DEFAULT,
        translatedMessage:
            _localizationService.translate(ErrorMessagesKey.unknown),
        technicalMessage:
            'Exception throwing has not been perfectly implemented',
        stackTrace: stackTrace,
      );
    }
  }

  /// Handles specific network error types.
  ApiCallFailureModel _handleDioError(DioException error,
      [StackTrace? stackTrace]) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return ApiCallFailureModel(
          code: ResponseCode.TIMEOUT,
          translatedMessage: _localizationService
              .translate(ErrorMessagesKey.connectionTimeout),
          technicalMessage: 'Connection timed out',
          stackTrace: stackTrace,
        );
      case DioExceptionType.sendTimeout:
        return ApiCallFailureModel(
          code: ResponseCode.TIMEOUT,
          translatedMessage:
              _localizationService.translate(ErrorMessagesKey.sendTimeout),
          technicalMessage: 'Send timed out',
          stackTrace: stackTrace,
        );
      case DioExceptionType.receiveTimeout:
        return ApiCallFailureModel(
          code: ResponseCode.TIMEOUT,
          translatedMessage:
              _localizationService.translate(ErrorMessagesKey.receiveTimeout),
          technicalMessage: 'Receive timed out',
          stackTrace: stackTrace,
        );
      case DioExceptionType.connectionError:
        return ApiCallFailureModel(
          code: ResponseCode.CONNECTION_ERROR,
          translatedMessage:
              _localizationService.translate(ErrorMessagesKey.connectionError),
          technicalMessage: 'Connection error occurred',
          stackTrace: stackTrace,
        );
      case DioExceptionType.badCertificate:
        return ApiCallFailureModel(
          code: ResponseCode.CONNECTION_ERROR,
          translatedMessage:
              _localizationService.translate(ErrorMessagesKey.badCertificate),
          technicalMessage: 'Bad Certificate error occurred',
          stackTrace: stackTrace,
        );
      case DioExceptionType.cancel:
        return ApiCallFailureModel(
          code: ResponseCode.CONNECTION_ERROR,
          translatedMessage:
              _localizationService.translate(ErrorMessagesKey.cancel),
          technicalMessage: 'Cancel error occurred',
          stackTrace: stackTrace,
        );
      case DioExceptionType.badResponse:
        return _handleBadResponse(error, stackTrace);
      default:
        return ApiCallFailureModel(
          code: ResponseCode.DEFAULT,
          translatedMessage:
              _localizationService.translate(ErrorMessagesKey.unknown),
          technicalMessage: 'Unknown error occurred',
          stackTrace: stackTrace,
        );
    }
  }

  /// Handles HTTP status code errors.
  ApiCallFailureModel _handleBadResponse(DioException error,
      [StackTrace? stackTrace]) {
    final statusCode = error.response?.statusCode ?? ResponseCode.DEFAULT;
    String messageKey;

    switch (statusCode) {
      case 400:
        messageKey = ErrorMessagesKey.badRequest;
        break;
      case 401:
        messageKey = ErrorMessagesKey.unauthorized;
        break;
      case 403:
        messageKey = ErrorMessagesKey.forbidden;
        break;
      case 404:
        messageKey = ErrorMessagesKey.notFound;
        break;
      case 500:
        messageKey = ErrorMessagesKey.serverError;
        break;
      default:
        messageKey = ErrorMessagesKey.unknown;
    }

    return ApiCallFailureModel(
      code: statusCode,
      translatedMessage: _localizationService.translate(messageKey),
      technicalMessage: error.message,
      stackTrace: stackTrace,
      errorData: error.response?.data,
    );
  }

  ApiCallFailureModel _handleCustomException(CustomException error,
      [StackTrace? stackTrace]) {
    final customErrorType = error.type;
    String messageKey;

    switch (customErrorType) {
      case CustomErrorType.preCallError:
        messageKey = ErrorMessagesKey.preCall;
        break;
      case CustomErrorType.parsingError:
        messageKey = ErrorMessagesKey.parsing;
        break;
      default:
        messageKey = ErrorMessagesKey.unknown;
    }

    return ApiCallFailureModel(
      code: ResponseCode.DEFAULT,
      translatedMessage: _localizationService.translate(messageKey),
      technicalMessage: error.type.toString(),
      stackTrace: stackTrace,
      errorData: {},
    );
  }
}
