abstract class AppException implements Exception {
  final String message;
  final dynamic error;
  final StackTrace? stackTrace;

  AppException(this.message, [this.error, this.stackTrace]);

  @override
  String toString() {
    return '$runtimeType: $message${error != null ? '\nError: $error' : ''}';
  }
}