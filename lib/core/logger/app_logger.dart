import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class AppLogger {
  factory AppLogger() => _instance;

  AppLogger._internal();
  static final Logger _logger = Logger(
    printer: PrettyPrinter(dateTimeFormat: DateTimeFormat.dateAndTime),
    level: kDebugMode ? Level.trace : Level.error,
  );

  static final AppLogger _instance = AppLogger._internal();

  static void d({
    required String message,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    if (kDebugMode) {
      _logger.d(message, error: error, stackTrace: stackTrace);
    }
  }

  static void i({
    required String message,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    if (kDebugMode) {
      _logger.i(message, error: error, stackTrace: stackTrace);
    }
  }

  static void w({
    required String message,
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    _logger.w(message, error: error, stackTrace: stackTrace);
    if (!kDebugMode) {
      _logToServices(
        message,
        error,
        stackTrace,
        _LogLevel.warning,
        metadata: metadata,
      );
    }
  }

  static void e({
    required String message,
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    _logger.e(message, error: error, stackTrace: stackTrace);
    if (!kDebugMode) {
      _logToServices(
        message,
        error,
        stackTrace,
        _LogLevel.error,
        metadata: metadata,
      );
    }
  }

  static void f({
    required String message,
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    _logger.f(message, error: error, stackTrace: stackTrace);
    if (!kDebugMode) {
      _logToServices(
        message,
        error,
        stackTrace,
        _LogLevel.fatal,
        metadata: metadata,
      );
    }
  }

  static Future<void> _logToServices(
    String message,
    dynamic error,
    StackTrace? stackTrace,
    _LogLevel level, {
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await Sentry.captureException(
        error ?? message,
        stackTrace: stackTrace,
        hint: Hint.withMap({'message': message}),
        withScope: (scope) {
          scope.level = _toSentryLevel(level);
          if (metadata != null) {
            for (final entry in metadata.entries) {
              scope.setTag(entry.key, entry.value.toString());
            }
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('AppLogger: failed to forward to Sentry: $e');
      }
    }
  }

  static SentryLevel _toSentryLevel(_LogLevel level) {
    switch (level) {
      case _LogLevel.warning:
        return SentryLevel.warning;
      case _LogLevel.error:
        return SentryLevel.error;
      case _LogLevel.fatal:
        return SentryLevel.fatal;
    }
  }
}

enum _LogLevel { warning, error, fatal }

// Public alias kept for any external code that references LogLevel.
enum LogLevel { debug, info, warning, error, fatal }
