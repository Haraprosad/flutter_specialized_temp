/// Holds network-related constants like timeout values and default headers.
class NetworkConstants {
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
  
  static const String contentType = 'application/json';
  static const String accept = 'application/json';
  static const String authorization = 'Bearer';
  static const String defaultLanguage = 'en';
  
  static const int defaultErrorCode = -1;
  static const String defaultErrorKey = 'error.unknown';
}
