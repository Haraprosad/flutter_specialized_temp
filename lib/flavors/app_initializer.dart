import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_specialized_temp/core/constants/env_constants.dart';
import 'package:flutter_specialized_temp/core/di/injection.dart';
import 'package:flutter_specialized_temp/core/logger/app_logger.dart';
import 'package:flutter_specialized_temp/core/observers/bloc_observer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/widgets/flutter_error_screen.dart';
import '../main.dart';
import 'env_config.dart';
import 'environment.dart';

Future<void> initializeApp(String envFileName, String appName, Env env) async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: envFileName);

    EnvConfig.instantiate(
      appName: appName,
      baseUrl: dotenv.env[EnvConstants.envKeyBaseUrl]!,
      env: env,
    );
    await configureDependencies();

    // Bloc observer
    Bloc.observer = AppBlocObserver();

    runApp(const MyApp());

//************Device Preview -1 start**************** */
    // runApp(DevicePreview(
    //   enabled: !kReleaseMode,
    //   builder: (context) => MyApp(), // Wrap your app
    // ));
//************Device Preview -1 end****************** */
  }, (exception, stackTrace) async {
    AppLogger.f(
      message: "runZonedGuarded caught error",
      error: exception,
      stackTrace: stackTrace,
    );
  });

  // Handle Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);

    AppLogger.f(
      message: "Flutter error: ${details.exception}",
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  // Handle platform/OS errors
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    AppLogger.e(
      message: "Platform error: $error",
      error: error,
      stackTrace: stack,
    );
    return true;
  };

  // Flutter error screen show when error caught by Flutter framework
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return const FlutterErrorScreen();
  };
}
