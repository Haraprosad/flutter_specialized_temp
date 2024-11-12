/// Represents a network failure with detailed information.
class ApiCallFailureModel implements Exception {
  final int code; // Error code
  final String translatedMessage; // Message for end-user
  final Map<String, dynamic>? messageArgs; // Arguments for message formatting
  final String? technicalMessage; // Detailed message for debugging
  final StackTrace? stackTrace; // Stack trace for debugging
  final Map<String, dynamic>? errorData; // Optional error data

  const ApiCallFailureModel({
    required this.code,
    required this.translatedMessage,
    this.messageArgs,
    this.technicalMessage,
    this.stackTrace,
    this.errorData,
  });

  @override
  String toString() =>
      'ApiCallFailureModel(code: $code, translatedMessage: $translatedMessage, technicalMessage: $technicalMessage)';
}
