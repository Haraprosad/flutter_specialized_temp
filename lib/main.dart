import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_specialized_temp/core/di/injection.dart';
import 'package:flutter_specialized_temp/core/localization/bloc/locale_bloc.dart';
import 'package:flutter_specialized_temp/core/localization/extension/loc.dart';
import 'package:flutter_specialized_temp/core/localization/localization_actions.dart';
import 'package:flutter_specialized_temp/core/network/services/localization_service/localization_service.dart';
import 'package:flutter_specialized_temp/core/router/app_router.dart';
import 'package:flutter_specialized_temp/core/theme/app_theme.dart';
import 'package:flutter_specialized_temp/core/theme/bloc/theme_bloc.dart';
import 'package:flutter_specialized_temp/core/theme/text_theme_ext.dart';
import 'package:flutter_specialized_temp/core/utils/extensions/sizedbox_extension.dart';
import 'package:flutter_specialized_temp/core/utils/extensions/widget_extension.dart';
import 'package:flutter_specialized_temp/features/dlt_auth/presentation/bloc/bloc/auth_bloc.dart';


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
              builder: (context, child) {
                //For Non Ui localizations service
                if (AppLocalizations.of(context) != null) {
                  sl<LocalizationService>().setLocalizations(AppLocalizations.of(context)!);
                }
                return EasyLoading.init()(context, child);
              },
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
