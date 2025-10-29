import 'package:dio/dio.dart';
import 'package:flutter_specialized_temp/core/network/constants/response_code.dart';
import 'package:flutter_specialized_temp/core/network/enums/custom_error_type.dart';
import 'package:flutter_specialized_temp/core/network/constants/error_messages_key.dart';
import 'package:flutter_specialized_temp/core/network/error_handling/models/custom_exception.dart';
import 'package:flutter_specialized_temp/core/network/services/localization_service/localization_service.dart';
import 'package:flutter_specialized_temp/core/network/error_handling/models/api_call_failure_model.dart';
import 'package:injectable/injectable.dart';

/// Translates raw network errors into user-friendly messages.
///
/// Takes any error from an API call and converts it to something
/// we can show to users in their language. Handles Dio errors,
/// HTTP status codes, and custom backend error formats.
@lazySingleton
class NetworkErrorHandler {
  final LocalizationService _localizationService;

  NetworkErrorHandler(this._localizationService);

  /// Main entry point for error handling - figures out what went wrong
  ApiCallFailureModel handleError(dynamic error, [StackTrace? stackTrace]) {
    if (error is DioException) {
      // Special case for offline errors
      if (error.error == CustomErrorType.noInternet) {
        return ApiCallFailureModel(
          code: ResponseCode.NO_INTERNET,
          translatedMessage: _localizationService.translate(
            ErrorMessagesKey.noInternet,
          ),
          technicalMessage: 'No internet connection',
          stackTrace: stackTrace,
        );
      }
      return _handleDioError(error, stackTrace);
    } else {
      if (error is CustomException) {
        return _handleCustomException(error, stackTrace);
      }
      // Fallback for unexpected error types
      return ApiCallFailureModel(
        code: ResponseCode.DEFAULT,
        translatedMessage: _localizationService.translate(
          ErrorMessagesKey.unknown,
        ),
        technicalMessage:
            'Exception throwing has not been perfectly implemented',
        stackTrace: stackTrace,
      );
    }
  }

  /// Breaks down Dio errors by type - timeouts, connection issues, etc.
  ApiCallFailureModel _handleDioError(
    DioException error, [
    StackTrace? stackTrace,
  ]) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return ApiCallFailureModel(
          code: ResponseCode.TIMEOUT,
          translatedMessage: _localizationService.translate(
            ErrorMessagesKey.connectionTimeout,
          ),
          technicalMessage: 'Connection timed out',
          stackTrace: stackTrace,
        );
      case DioExceptionType.sendTimeout:
        return ApiCallFailureModel(
          code: ResponseCode.TIMEOUT,
          translatedMessage: _localizationService.translate(
            ErrorMessagesKey.sendTimeout,
          ),
          technicalMessage: 'Send timed out',
          stackTrace: stackTrace,
        );
      case DioExceptionType.receiveTimeout:
        return ApiCallFailureModel(
          code: ResponseCode.TIMEOUT,
          translatedMessage: _localizationService.translate(
            ErrorMessagesKey.receiveTimeout,
          ),
          technicalMessage: 'Receive timed out',
          stackTrace: stackTrace,
        );
      case DioExceptionType.connectionError:
        return ApiCallFailureModel(
          code: ResponseCode.CONNECTION_ERROR,
          translatedMessage: _localizationService.translate(
            ErrorMessagesKey.connectionError,
          ),
          technicalMessage: 'Connection error occurred',
          stackTrace: stackTrace,
        );
      case DioExceptionType.badCertificate:
        return ApiCallFailureModel(
          code: ResponseCode.CONNECTION_ERROR,
          translatedMessage: _localizationService.translate(
            ErrorMessagesKey.badCertificate,
          ),
          technicalMessage: 'Bad Certificate error occurred',
          stackTrace: stackTrace,
        );
      case DioExceptionType.cancel:
        return ApiCallFailureModel(
          code: ResponseCode.CONNECTION_ERROR,
          translatedMessage: _localizationService.translate(
            ErrorMessagesKey.cancel,
          ),
          technicalMessage: 'Cancel error occurred',
          stackTrace: stackTrace,
        );
      case DioExceptionType.badResponse:
        return _handleBadResponse(error, stackTrace);
      default:
        return ApiCallFailureModel(
          code: ResponseCode.DEFAULT,
          translatedMessage: _localizationService.translate(
            ErrorMessagesKey.unknown,
          ),
          technicalMessage: 'Unknown error occurred',
          stackTrace: stackTrace,
        );
    }
  }

  /// Handles server responses with error status codes (4xx, 5xx).
  ///
  /// The backend sends errors in this format:
  /// {
  ///   "success": false,
  ///   "error": {
  ///     "code": "VALIDATION_ERROR",
  ///     "message": "Transaction amount must be greater than zero",
  ///     "field": "amount"
  ///   }
  /// }
  /// We parse that and try to show a localized message if we have one,
  /// otherwise we just show what the backend sent us.
  ApiCallFailureModel _handleBadResponse(
    DioException error, [
    StackTrace? stackTrace,
  ]) {
    final statusCode = error.response?.statusCode ?? ResponseCode.DEFAULT;

    // Convert response data to a map we can work with
    Map<String, dynamic>? errorData;
    final responseData = error.response?.data;
    if (responseData != null) {
      if (responseData is Map<String, dynamic>) {
        errorData = responseData;
      } else if (responseData is String) {
        errorData = {'message': responseData};
      } else {
        errorData = {'data': responseData.toString()};
      }
    }

    // Pull out the error details from the backend response
    String? backendErrorCode;
    String? backendMessage;
    String? errorField;

    if (errorData != null && errorData['error'] != null) {
      final errorObject = errorData['error'] as Map<String, dynamic>;
      backendErrorCode = errorObject['code'] as String?;
      backendMessage = errorObject['message'] as String?;
      errorField = errorObject['field'] as String?;
    }

    // Figure out the best message to show the user
    String messageKey;
    String translatedMessage;

    if (backendErrorCode != null) {
      // See if we have a translation for this error code
      messageKey = _getMessageKeyFromErrorCode(backendErrorCode);
      translatedMessage = _localizationService.translate(messageKey);

      // If we don't have a translation, use what the backend sent
      if (translatedMessage == messageKey && backendMessage != null) {
        translatedMessage = backendMessage;
      }

      // Add the field name if it's a validation error on a specific field
      if (errorField != null && errorField.isNotEmpty) {
        translatedMessage = '$translatedMessage (Field: $errorField)';
      }
    } else {
      // No error code from backend, fall back to HTTP status codes
      messageKey = _getMessageKeyFromStatusCode(statusCode);
      translatedMessage = _localizationService.translate(messageKey);

      // Still prefer backend message if we have it
      if (backendMessage != null) {
        translatedMessage = backendMessage;
      }
    }

    return ApiCallFailureModel(
      code: statusCode,
      translatedMessage: translatedMessage,
      technicalMessage: error.message,
      stackTrace: stackTrace,
      errorData: errorData,
      errorCode: backendErrorCode,
      field: errorField,
      backendMessage: backendMessage,
    );
  }

  /// Looks up the right translation key for a backend error code
  String _getMessageKeyFromErrorCode(String errorCode) {
    switch (errorCode.toUpperCase()) {
      case 'VALIDATION_ERROR':
        return ErrorMessagesKey.validationError;
      case 'AMOUNT_INVALID':
      case 'INVALID_AMOUNT':
        return ErrorMessagesKey.amountInvalid;
      case 'DUPLICATE_ENTRY':
      case 'ALREADY_EXISTS':
        return ErrorMessagesKey.duplicateEntry;
      case 'RESOURCE_NOT_FOUND':
      case 'NOT_FOUND':
        return ErrorMessagesKey.resourceNotFound;
      case 'INSUFFICIENT_BALANCE':
        return ErrorMessagesKey.insufficientBalance;
      case 'INVALID_DATE_RANGE':
        return ErrorMessagesKey.invalidDateRange;
      case 'CATEGORY_NOT_FOUND':
        return ErrorMessagesKey.categoryNotFound;
      case 'TRANSACTION_NOT_FOUND':
        return ErrorMessagesKey.transactionNotFound;
      default:
        // Don't recognize this code, return it as-is
        return errorCode.toLowerCase();
    }
  }

  /// Maps HTTP status codes to generic error messages
  String _getMessageKeyFromStatusCode(int statusCode) {
    switch (statusCode) {
      case 400:
        return ErrorMessagesKey.badRequest;
      case 401:
        return ErrorMessagesKey.unauthorized;
      case 403:
        return ErrorMessagesKey.forbidden;
      case 404:
        return ErrorMessagesKey.notFound;
      case 500:
        return ErrorMessagesKey.serverError;
      default:
        return ErrorMessagesKey.unknown;
    }
  }

  /// Handles our custom app exceptions (parsing errors, pre-call checks, etc.)
  ApiCallFailureModel _handleCustomException(
    CustomException error, [
    StackTrace? stackTrace,
  ]) {
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
