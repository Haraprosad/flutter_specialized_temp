import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_specialized_temp/core/di/injection.dart';
import 'package:flutter_specialized_temp/core/localization/locale_constants.dart';
import 'package:flutter_specialized_temp/core/localization/localization_actions.dart';
import 'package:flutter_specialized_temp/core/storage/app_storage.dart';
import 'package:flutter_specialized_temp/core/theme/bloc/theme_bloc.dart';
import 'package:flutter_specialized_temp/core/theme/colors/color_scheme_ext.dart';
import 'package:flutter_specialized_temp/core/theme/typography/text_theme_ext.dart';
import 'package:flutter_specialized_temp/core/widgets/app_drawer/drawer_menu_item.dart';
import 'package:flutter_specialized_temp/features/dlt_auth/presentation/bloc/bloc/auth_bloc.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final preferencesManager = sl<AppStorage>().preferences;
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
            ),
            child: Text(
              'CodeVidhi',
              style: context.headlineMedium?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              return SwitchListTile(
                title: Text('Toggle Theme', style: context.titleMedium),
                secondary: Icon(
                    state.isDark ? Icons.dark_mode : Icons.light_mode,
                    color: context.colorScheme.primary),
                value: state.isDark,
                onChanged: (value) {
                  context.read<ThemeBloc>().add(ToggleTheme());
                  preferencesManager.setDarkMode(value);
                },
              );
            },
          ),
          DrawerMenuItem(
            icon: Icons.language,
            title: 'Change Language',
            onTap: () => _showLanguageDialog(context),
          ),
          DrawerMenuItem(
            icon: Icons.settings,
            title: 'Settings',
            onTap: () {},
          ),
          DrawerMenuItem(
            icon: Icons.help,
            title: 'Help & Support',
            onTap: () {},
          ),
          DrawerMenuItem(
            icon: Icons.logout,
            title: 'Logout',
            onTap: () async {
              // Clear local storage before logout
              await sl<AppStorage>().clearAllData();
              sl<AuthBloc>().add(const LogoutRequested());
            },
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final preferencesManager = sl<AppStorage>().preferences;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Row(
            children: [
              Icon(
                Icons.language,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(width: 12.w),
              Text(
                'Select Language',
                style: context.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            constraints: BoxConstraints(maxHeight: 280.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 8.h),
                _buildLanguageOption(
                  context: context,
                  title: 'English',
                  subtitle: 'English (US)',
                  icon: '🇺🇸',
                  isSelected: preferencesManager.getLanguage() == 'en',
                  onTap: () {
                    LocalizationActions.setLocale(
                        context, LocaleConstants.english);
                    preferencesManager
                        .setLanguage(LocaleConstants.english.languageCode);
                    Navigator.pop(context);
                  },
                ),
                SizedBox(height: 8.h),
                _buildLanguageOption(
                  context: context,
                  title: 'বাংলা',
                  subtitle: 'Bengali',
                  icon: '🇧🇩',
                  isSelected: preferencesManager.getLanguage() == 'bn',
                  onTap: () {
                    LocalizationActions.setLocale(context, const Locale('bn'));
                    preferencesManager.setLanguage('bn');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: context.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color:
                  isSelected ? colorScheme.primary : colorScheme.outlineVariant,
            ),
            color:
                isSelected ? colorScheme.primaryContainer : colorScheme.surface,
          ),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 24)),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: context.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
