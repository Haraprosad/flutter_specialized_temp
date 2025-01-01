import 'package:flutter/material.dart';
import 'package:flutter_specialized_temp/core/di/injection.dart';
import 'package:flutter_specialized_temp/core/localization/extension/loc.dart';
import 'package:flutter_specialized_temp/core/localization/locale_constants.dart';
import 'package:flutter_specialized_temp/core/localization/localization_actions.dart';
import 'package:flutter_specialized_temp/core/router/route_names.dart';
import 'package:flutter_specialized_temp/core/storage/app_storage.dart';
import 'package:flutter_specialized_temp/core/theme/bloc/theme_bloc.dart';
import 'package:flutter_specialized_temp/core/theme/color_scheme_ext.dart';
import 'package:flutter_specialized_temp/core/theme/text_theme_ext.dart';
import 'package:flutter_specialized_temp/core/utils/app_spacing.dart';
import 'package:flutter_specialized_temp/dlt_common_actions/infinite_scrolling/presentation/bloc/post_bloc.dart';
import 'package:flutter_specialized_temp/dlt_common_actions/infinite_scrolling/presentation/pages/posts_page.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_specialized_temp/core/storage/preferences_manager.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final preferencesManager = sl<AppStorage>().preferences;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.loc.home, style: context.headlineMedium),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () => context.goNamed(RouteNames.notifications),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Dummy List'),
              Tab(text: 'Posts'),
            ],
          ),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                child: Text(
                  'Settings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              BlocBuilder<ThemeBloc, ThemeState>(
                builder: (context, state) {
                  return SwitchListTile(
                    title: Text('Toggle Theme'),
                    secondary: Icon(state.isDark ? Icons.dark_mode : Icons.light_mode),
                    value: state.isDark,
                    onChanged: (value) {
                      context.read<ThemeBloc>().add(ToggleTheme());
                      preferencesManager.setDarkMode(value);
                    },
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.language),
                title: Text('Change Language'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Select Language'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              title: Text('English'),
                              onTap: () {
                                LocalizationActions.setLocale(context, LocaleConstants.english);
                                preferencesManager.setLanguage(LocaleConstants.english.languageCode);
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              title: Text('Bengali'),
                              onTap: () {
                                LocalizationActions.setLocale(context, Locale('bn'));
                                preferencesManager.setLanguage('bn');
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView(
              children: const [
                ListTile(
                  title: Text('Dummy Item 1'),
                ),
                ListTile(
                  title: Text('Dummy Item 2'),
                ),
              ],
            ),
            BlocProvider(
              create: (context) => sl<PostsBloc>(),
              child: const PostsPage(),
            ),
          ],
        ),
      ),
    );
  }
}