import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'
    show AppLocalizations;
import 'package:flutter_specialized_temp/core/localization/bloc/locale_bloc.dart';
import 'package:flutter_specialized_temp/core/localization/extension/loc.dart';
import 'package:flutter_specialized_temp/core/localization/localization_actions.dart';
import 'package:flutter_specialized_temp/core/theme/bloc/theme_bloc.dart';
import 'package:flutter_specialized_temp/core/theme/text_theme_ext.dart';
import 'package:flutter_specialized_temp/core/utils/extensions/sizedbox_extension.dart';
import 'package:flutter_specialized_temp/core/utils/extensions/widget_extension.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(
            375, 812), //todo: use the design size of your figma design
        minTextAdapt: true,
        builder: (_, child) {
          return MultiBlocProvider(
          providers: [
            BlocProvider<ThemeBloc>(
              create: (context) => ThemeBloc(),
            ),
            BlocProvider<LocaleBloc>(
              create: (context) => LocaleBloc(),
            ),
          ],
          child: BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, themeState) {
              return BlocBuilder<LocaleBloc, LocaleState>(
                builder: (context, localeState) {
                    return MaterialApp(
                      supportedLocales: AppLocalizations.supportedLocales,
                      localizationsDelegates:
                          AppLocalizations.localizationsDelegates,
                      title: 'Flutter Demo',
                      locale: localeState.locale,
                      theme: themeState.themeData,
                      home: const MyHomePage(title: 'Flutter Demo Home Page'),
                    );
                  },
                );
              },
            ),
          );
        });
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
                onPressed: () {
                 
                  context.read<ThemeBloc>().add(ToggleLightTheme());
                },
            child: Text("Light Theme",style: context.labelLarge,)),
            const SizedBox().smallHGap,
            ElevatedButton(
                onPressed: () {
                
                  context.read<ThemeBloc>().add(ToggleDarkTheme());
                },
                child: Text("Dark Theme",style: context.labelMedium,)),
            Text(
              context.loc.flutter_template,
              style: context.displayMedium,
            ).p16,
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          LocalizationActions.setLocale(context, const Locale('bn'));
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
