/// Represents a network failure with detailed information.
class ApiCallFailureModel implements Exception {
  final int code; // HTTP status code
  final String translatedMessage; // Message for end-user (localized)
  final Map<String, dynamic>? messageArgs; // Arguments for message formatting
  final String? technicalMessage; // Detailed message for debugging
  final StackTrace? stackTrace; // Stack trace for debugging
  final Map<String, dynamic>? errorData; // Optional error data
  final String? errorCode; // Backend error code (e.g., "VALIDATION_ERROR")
  final String? field; // Field that caused the error (for validation errors)
  final String? backendMessage; // Original message from backend (fallback)

  const ApiCallFailureModel({
    required this.code,
    required this.translatedMessage,
    this.messageArgs,
    this.technicalMessage,
    this.stackTrace,
    this.errorData,
    this.errorCode,
    this.field,
    this.backendMessage,
  });

  @override
  String toString() =>
      'ApiCallFailureModel(code: $code, errorCode: $errorCode, field: $field, translatedMessage: $translatedMessage, backendMessage: $backendMessage, technicalMessage: $technicalMessage)';
}
