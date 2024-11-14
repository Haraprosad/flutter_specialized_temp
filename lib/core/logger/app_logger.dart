import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'package:sentry_flutter/sentry_flutter.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.dateAndTime,
    ),
    level: kDebugMode ? Level.trace : Level.error,
  );

  // Singleton instance
  static final AppLogger _instance = AppLogger._internal();
  
  factory AppLogger() {
    return _instance;
  }
  
  AppLogger._internal();

  // Debug level logging
  static void d({required String message, dynamic error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      _logger.d(message, error: error, stackTrace: stackTrace);
    }
  }

  // Info level logging
  static void i({required String message, dynamic error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      _logger.i(message, error: error, stackTrace: stackTrace);
    }
  }

  // Warning level logging
  static void w({required String message, dynamic error, StackTrace? stackTrace,Map<String, dynamic>? metadata}) {
    _logger.w(message, error: error, stackTrace: stackTrace);
    
    // In production, send warnings to monitoring services
    if (!kDebugMode) {
      _logToServices(message, error, stackTrace, LogLevel.warning,metadata: metadata);
    }
  }

  // Error level logging
  static void e({required String message, dynamic error, StackTrace? stackTrace,Map<String, dynamic>? metadata}) {
    _logger.e(message, error: error, stackTrace: stackTrace);
    
    // In production, send errors to monitoring services
    if (!kDebugMode) {
      _logToServices(message, error, stackTrace, LogLevel.error,metadata: metadata);
    }
  }

  // Fatal level logging
  static void f({required String message, dynamic error, StackTrace? stackTrace,Map<String, dynamic>? metadata}) {
    _logger.f(message, error: error, stackTrace: stackTrace);
    
    // In production, send fatal errors to monitoring services
    if (!kDebugMode) {
      _logToServices(message, error, stackTrace, LogLevel.fatal,metadata: metadata);
    }
  }

  // Helper method to log to multiple services
  static Future<void> _logToServices(
    String message,
    dynamic error,
    StackTrace? stackTrace,
    LogLevel level,
    {Map<String, dynamic>? metadata}
  ) async {
    try {

      //todo: Uncomment this block during Firebase Crashlytics integration
      // // Log to Firebase Crashlytics
      // await FirebaseCrashlytics.instance.recordError(
      //   error ?? message,
      //   stackTrace,
      //   reason: message,
      //   information: metadata?.entries.map((e) => '${e.key}: ${e.value}').toList() ?? [],
      //   fatal: level == LogLevel.fatal,
      // );

      //todo: Uncomment this block during Sentry integration
      // // Log to Sentry
      // await Sentry.captureException(
      //   error ?? message,
      //   stackTrace: stackTrace,
      //   hint: Hint.withMap({'message': message}),
      //   level: _getSentryLevel(level),
      // );
    } catch (e) {
      // Fail silently in production, log to console in debug
      if (kDebugMode) {
        print('Error logging to services: $e');
      }
    }
  }

  /// Helper method to convert log level to Sentry level
  //todo: Uncomment this method during sentry integration
  // static SentryLevel _getSentryLevel(LogLevel level) {
  //   switch (level) {
  //     case LogLevel.warning:
  //       return SentryLevel.warning;
  //     case LogLevel.error:
  //       return SentryLevel.error;
  //     case LogLevel.fatal:
  //       return SentryLevel.fatal;
  //     default:
  //       return SentryLevel.error;
  //   }
  // }
}

enum LogLevel {
  debug,
  info,
  warning,
  error,
  fatal,
}