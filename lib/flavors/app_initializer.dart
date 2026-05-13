import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_specialized_temp/core/constants/env_constants.dart';
import 'package:flutter_specialized_temp/core/constants/string_constants.dart';
import 'package:flutter_specialized_temp/core/di/injection.dart';
import 'package:flutter_specialized_temp/core/logger/app_logger.dart';
import 'package:flutter_specialized_temp/core/observers/bloc_observer.dart';
import 'package:flutter_specialized_temp/core/services/memory_management_service.dart';
import 'package:flutter_specialized_temp/core/widgets/flutter_error_screen.dart';
import 'package:flutter_specialized_temp/flavors/env_config.dart';
import 'package:flutter_specialized_temp/flavors/environment.dart';
import 'package:flutter_specialized_temp/main.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Initializes the Flutter application with environment-specific configuration
/// and comprehensive error handling.
///
/// Sentry is initialized here using the `SENTRY_DSN` value from the active
/// `.env.*` file. If the DSN is empty (e.g. in development), Sentry runs in a
/// no-op mode — no events are sent.
///
/// Error handling hierarchy:
///   1. Zone guard       — unhandled async errors
///   2. FlutterError     — widget tree / framework errors
///   3. PlatformDispatcher — native platform errors
///   4. ErrorWidget      — user-friendly error screen in the widget tree
Future<void> initializeApp(Env env) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment-specific .env file before anything else.
  await dotenv.load(fileName: env.envFileName);

  final sentryDsn = dotenv.env[EnvConstants.envKeySentryDsn] ?? '';

  // Wrap the entire initialization in SentryFlutter so Sentry can capture
  // errors that occur before runApp, including DI failures.
  await SentryFlutter.init((options) {
    options
      ..dsn = sentryDsn
      ..environment = env.displayName.toLowerCase()
      // Only capture errors in staging/production; in development Sentry is a
      // no-op because the DSN is empty, but we still set tracesSampleRate for
      // completeness.
      ..tracesSampleRate = env.isProduction ? 0.2 : 0.0
      ..debug = env.isDevelopment
      ..sendDefaultPii = false;
  }, appRunner: () => _runApp(env));
}

Future<void> _runApp(Env env) async {
  await runZonedGuarded(
    () async {
      EnvConfig.instantiate(
        appName: EnvConfig.createAppName(StringConstants.appName, env),
        baseUrl: dotenv.env[EnvConstants.envKeyBaseUrl]!,
        env: env,
      );

      await configureDependencies();

      sl<MemoryManagementService>().initialize();
      AppLogger.i(message: '🧠 Memory management service activated');

      Bloc.observer = AppBlocObserver();

      _configureErrorHandlers();

      runApp(const MyApp());
    },
    (exception, stackTrace) async {
      AppLogger.f(
        message: 'runZonedGuarded caught error',
        error: exception,
        stackTrace: stackTrace,
      );
    },
  );
}

void _configureErrorHandlers() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    AppLogger.f(
      message: 'Flutter error: ${details.exception}',
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    AppLogger.e(
      message: 'Platform error: $error',
      error: error,
      stackTrace: stack,
    );
    return true;
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return const FlutterErrorScreen();
  };
}
