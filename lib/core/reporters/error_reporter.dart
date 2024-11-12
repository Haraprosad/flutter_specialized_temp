import 'package:flutter/material.dart';

/// Interface for error reporting across different services.
abstract class ErrorReporter {
  /// Records an error, potentially with extra metadata.
  Future<void> recordError(dynamic exception, StackTrace? stack, {Map<String, dynamic>? metadata});

  /// Records a Flutter framework error.
  Future<void> recordFlutterError(FlutterErrorDetails details);
}
