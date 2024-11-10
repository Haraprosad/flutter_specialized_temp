import 'app_exceptions.dart';

class StorageException extends AppException {
  StorageException(
    super.message, [
    super.error,
    super.stackTrace,
  ]);
}

class StorageNotInitializedException extends StorageException {
  StorageNotInitializedException([String? message])
      : super(message ?? 'Storage not initialized. Call init() first.');
}

class SecureStorageException extends StorageException {
  SecureStorageException(
    String message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) : super('Secure Storage Error: $message', error, stackTrace);
}

class PreferencesException extends StorageException {
  PreferencesException(
    String message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) : super('Preferences Error: $message', error, stackTrace);
}