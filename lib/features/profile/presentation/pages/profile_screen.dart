import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_specialized_temp/core/router/route_names.dart';
import 'package:flutter_specialized_temp/core/theme/color_scheme_ext.dart';
import 'package:flutter_specialized_temp/core/theme/text_theme_ext.dart';
import 'package:flutter_specialized_temp/core/utils/app_spacing.dart';
import 'package:flutter_specialized_temp/features/auth/presentation/bloc/bloc/auth_bloc.dart';
import 'package:flutter_specialized_temp/features/profile/presentation/widgets/profile_menu_item.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: context.headlineMedium),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.pushNamed(RouteNames.editProfile),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.mediumW),
        child: Column(
          children: [
            SizedBox(height: AppSpacing.largeH),
            CircleAvatar(
              radius: 50.r,
              backgroundColor: context.colorScheme.primary,
              child: Text('JD', style: context.headlineLarge?.copyWith(
                color: context.colorScheme.onPrimary,
              )),
            ),
            SizedBox(height: AppSpacing.mediumH),
            Text('John Doe', style: context.headlineSmall),
            Text('john.doe@example.com', style: context.bodyLarge),
            SizedBox(height: AppSpacing.largeH),
            ProfileMenuItem(
              icon: Icons.settings,
              title: 'Settings',
              onTap: () {},
            ),
            ProfileMenuItem(
              icon: Icons.help,
              title: 'Help & Support',
              onTap: () {},
            ),
            ProfileMenuItem(
              icon: Icons.logout,
              title: 'Logout',
              onTap: () {
                sl<AuthBloc>().add(const LogoutRequested());
              },
            ),
          ],
        ),
      ),
    );
  }
}