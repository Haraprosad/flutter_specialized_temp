import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_specialized_temp/core/di/injection.dart';
import 'package:flutter_specialized_temp/core/localization/bloc/locale_bloc.dart';
import 'package:flutter_specialized_temp/core/localization/extension/loc.dart';
import 'package:flutter_specialized_temp/core/localization/localization_actions.dart';
import 'package:flutter_specialized_temp/core/logger/app_logger.dart';
import 'package:flutter_specialized_temp/core/observers/bloc_observer.dart';
import 'package:flutter_specialized_temp/core/router/app_router.dart';
import 'package:flutter_specialized_temp/core/theme/app_theme.dart';
import 'package:flutter_specialized_temp/core/theme/bloc/theme_bloc.dart';
import 'package:flutter_specialized_temp/core/theme/text_theme_ext.dart';
import 'package:flutter_specialized_temp/core/utils/extensions/sizedbox_extension.dart';
import 'package:flutter_specialized_temp/core/utils/extensions/widget_extension.dart';
import 'package:flutter_specialized_temp/core/widgets/flutter_error_screen.dart';
import 'package:flutter_specialized_temp/features/auth/presentation/bloc/bloc/auth_bloc.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await configureDependencies();

    // Bloc observer
    Bloc.observer = AppBlocObserver();

    runApp(const MyApp());
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (_, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<ThemeBloc>(
              create: (context) =>
                  sl<ThemeBloc>()..add(const InitializeTheme()),
            ),
            BlocProvider<LocaleBloc>(
              create: (context) => sl<LocaleBloc>(),
            ),
            BlocProvider<AuthBloc>(
              create: (context)=>sl<AuthBloc>(),
            ),
          ],
          child: const AppView(),
        );
      },
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return BlocBuilder<LocaleBloc, LocaleState>(
          builder: (context, localeState) {
            return MaterialApp.router(
              routerConfig: sl<AppRouter>().routerConfig,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              title: 'Flutter Demo',
              locale: localeState.locale,
              themeMode: themeState.themeMode,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
            );
          },
        );
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.flutter_template),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ThemeToggleButton(),
            const SizedBox().smallHGap,
            Text(
              context.loc.flutter_template,
              style: context.displayMedium,
            ).p16,
          ],
        ),
      ),
      floatingActionButton: LocaleToggleButton(),
    );
  }
}

class ThemeToggleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return ElevatedButton(
          onPressed: () => context.read<ThemeBloc>().add(const ToggleTheme()),
          child: Text(
            state.isDark ? 'Switch to Light Theme' : 'Switch to Dark Theme',
            style: context.labelLarge,
          ),
        );
      },
    );
  }
}

class LocaleToggleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () =>
          LocalizationActions.setLocale(context, const Locale('bn')),
      tooltip: 'Change Language',
      child: const Icon(Icons.language),
    );
  }
}
