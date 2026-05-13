abstract class AppException implements Exception {
  AppException(this.message, [this.error, this.stackTrace]);

  final String message;
  final dynamic error;
  final StackTrace? stackTrace;

  @override
  String toString() =>
      '$runtimeType: $message${error != null ? '\nError: $error' : ''}';
}

class NetworkException extends AppException {
  NetworkException(super.message, [super.error, super.stackTrace]);
}

class UnauthorizedException extends AppException {
  UnauthorizedException(super.message, [super.error, super.stackTrace]);
}

class NotFoundException extends AppException {
  NotFoundException(super.message, [super.error, super.stackTrace]);
}

class ServerException extends AppException {
  ServerException(super.message, [super.error, super.stackTrace]);
}

class CacheException extends AppException {
  CacheException(super.message, [super.error, super.stackTrace]);
}

/// Thrown when user input fails validation. [fieldErrors] maps field names to
/// their error messages (e.g. `{'email': ['Invalid format']}`).
class ValidationException extends AppException {
  ValidationException(
    String message, {
    this.fieldErrors,
    dynamic error,
    StackTrace? stackTrace,
  }) : super(message, error, stackTrace);

  final Map<String, List<String>>? fieldErrors;
}

/// Thrown when the server returns 429 Too Many Requests.
/// [retryAfterSeconds] is parsed from the Retry-After header when available.
class RateLimitException extends AppException {
  RateLimitException(
    String message, {
    this.retryAfterSeconds,
    dynamic error,
    StackTrace? stackTrace,
  }) : super(message, error, stackTrace);

  final int? retryAfterSeconds;
}

/// Thrown when the server returns 503 Service Unavailable or the backend
/// reports a planned outage.
class ServiceUnavailableException extends AppException {
  ServiceUnavailableException(super.message, [super.error, super.stackTrace]);
}