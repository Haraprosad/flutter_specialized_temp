import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_specialized_temp/core/router/navigator_keys.dart';
import 'package:flutter_specialized_temp/core/router/route_names.dart';
import 'package:flutter_specialized_temp/core/router/route_paths.dart';
import 'package:flutter_specialized_temp/core/widgets/scaffold_with_bottom_nav.dart';

import 'package:flutter_specialized_temp/features/auth/presentation/pages/login_screen.dart';
import 'package:flutter_specialized_temp/features/auth/presentation/pages/register_screen.dart';
import 'package:flutter_specialized_temp/features/auth/presentation/pages/splash_screen.dart';
import 'package:flutter_specialized_temp/features/home/presentation/pages/home_screen.dart';
import 'package:flutter_specialized_temp/features/home/presentation/pages/notifications_screen.dart';
import 'package:flutter_specialized_temp/features/profile/presentation/pages/edit_profile_screen.dart';
import 'package:flutter_specialized_temp/features/profile/presentation/pages/profile_screen.dart';
import 'package:flutter_specialized_temp/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:flutter_specialized_temp/features/tasks/presentation/bloc/task_event.dart';
import 'package:flutter_specialized_temp/features/tasks/presentation/pages/sub_tasks_screen.dart';
import 'package:flutter_specialized_temp/features/tasks/presentation/pages/task_details_screen.dart';
import 'package:flutter_specialized_temp/features/tasks/presentation/pages/tasks_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

import '../di/injection.dart';

@singleton
class AppRoutes {
  List<RouteBase> get routes => [
        GoRoute(
          path: RoutePaths.splash,
          name: RouteNames.splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: RoutePaths.login,
          name: RouteNames.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: RoutePaths.register,
          name: RouteNames.register,
          builder: (context, state) => const RegisterScreen(),
        ),

        // Main Shell Route for Bottom Navigation
        ShellRoute(
          navigatorKey: NavigatorKeys.shellNavigator,
          builder: (context, state, child) {
            return ScaffoldWithBottomNav(child: child);
          },
          routes: [
            // Home Stack
            GoRoute(
              path: RoutePaths.home,
              name: RouteNames.home,
              builder: (context, state) => const HomeScreen(),
              routes: [
                GoRoute(
                  path: 'notifications',
                  name: RouteNames.notifications,
                  builder: (context, state) => const NotificationsScreen(),
                ),
              ],
            ),

            ShellRoute(
                builder: (context, state, child) {
                  return BlocProvider(
                    create: (_) => sl<TaskBloc>(),
                    child: child,
                  );
                },
                routes: [
                  // Tasks Stack with Nested Navigation
                  GoRoute(
                    path: RoutePaths.tasks,
                    name: RouteNames.tasks,
                    builder: (context, state) => const TasksScreen(),
                    routes: [
                      GoRoute(
                        path: RoutePaths.taskDetails,
                        name: RouteNames.taskDetails,
                        builder: (context, state) {
                          final taskId = state.pathParameters['taskId']!;
                          return TaskDetailsScreen(taskId: taskId);
                        },
                        routes: [
                          GoRoute(
                            path: RoutePaths.subTasks,
                            name: RouteNames.subTasks,
                            builder: (context, state) {
                              final taskId = state.pathParameters['taskId']!;
                              return SubTasksScreen(taskId: taskId);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ]),

            // Profile Stack with Tabs
            GoRoute(
              path: RoutePaths.profile,
              name: RouteNames.profile,
              builder: (context, state) => const ProfileScreen(),
              routes: [
                GoRoute(
                  path: RoutePaths.editProfile,
                  name: RouteNames.editProfile,
                  pageBuilder: (context, state) {
                    return CustomTransitionPage(
                      child: const EditProfileScreen(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ];
}
