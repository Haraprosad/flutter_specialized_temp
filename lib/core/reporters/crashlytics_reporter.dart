import 'package:flutter/foundation.dart';
import 'package:flutter_specialized_temp/core/reporters/error_reporter.dart';
import 'package:injectable/injectable.dart';

/// Implementation of ErrorReporter that records errors using Crashlytics.
@LazySingleton(as: ErrorReporter)
class CrashlyticsReporter implements ErrorReporter {
  /// Records non-Flutter errors in production.
  @override
  Future<void> recordError(dynamic exception, StackTrace? stack, {Map<String, dynamic>? metadata}) async {
    if (!kDebugMode) {
      // Use Firebase Crashlytics for production
      // await _crashlytics.recordError(exception, stack, reason: exception.toString(), information: metadata?.entries.map((e) => '${e.key}: ${e.value}').toList() ?? []);
    }
  }

  /// Records Flutter framework errors.
  @override
  Future<void> recordFlutterError(FlutterErrorDetails details) async {
    if (!kDebugMode) {
      // Uncomment to use Firebase Crashlytics
      // await _crashlytics.recordFlutterError(details);
    }
  }
}
