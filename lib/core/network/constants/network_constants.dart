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
  static const String faqEndpoint = '/faqs'; // Add this line

  // Retry configuration with exponential backoff
  static const int maxRetries = 3;
  static const Duration initialRetryDelay = Duration(seconds: 1);
  static const double retryBackoffMultiplier = 2.0; // 1s, 2s, 4s
}
