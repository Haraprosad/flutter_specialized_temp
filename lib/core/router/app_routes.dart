import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_specialized_temp/core/router/navigator_keys.dart';
import 'package:flutter_specialized_temp/core/router/route_names.dart';
import 'package:flutter_specialized_temp/core/router/route_paths.dart';
import 'package:flutter_specialized_temp/core/router/route_guards.dart';
import 'package:flutter_specialized_temp/core/router/route_transitions.dart';
import 'package:flutter_specialized_temp/core/widgets/scaffold_with_bottom_nav.dart';

import 'package:flutter_specialized_temp/features/dlt_auth/presentation/pages/login_screen.dart';
import 'package:flutter_specialized_temp/features/dlt_auth/presentation/pages/register_screen.dart';
import 'package:flutter_specialized_temp/features/dlt_auth/presentation/pages/splash_screen.dart';
import 'package:flutter_specialized_temp/features/dlt_home/presentation/pages/home_screen.dart';
import 'package:flutter_specialized_temp/features/dlt_profile/presentation/pages/edit_profile_screen.dart';
import 'package:flutter_specialized_temp/features/dlt_profile/presentation/pages/profile_screen.dart';
import 'package:flutter_specialized_temp/features/dlt_tasks/presentation/bloc/task_bloc.dart';
import 'package:flutter_specialized_temp/features/dlt_tasks/presentation/pages/sub_tasks_screen.dart';
import 'package:flutter_specialized_temp/features/dlt_tasks/presentation/pages/task_details_screen.dart';
import 'package:flutter_specialized_temp/features/dlt_tasks/presentation/pages/tasks_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

import '../di/injection.dart';

@singleton
class AppRoutes {
  List<RouteBase> get routes => [
        // Splash Route
        splashRoute,

        // Auth Routes (Outside Shell)
        ..._authRoutes,

        // Main App Routes (Inside Shell with Bottom Navigation)
        _mainShellRoute,
      ];
  RouteBase get splashRoute => GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      );

  List<RouteBase> get _authRoutes => [
        GoRoute(
          path: RoutePaths.login,
          name: RouteNames.login,
          pageBuilder: (context, state) => RouteTransitions.slideTransition(
            const LoginScreen(),
            begin: const Offset(-1.0, 0.0),
          ),
        ),
        GoRoute(
          path: RoutePaths.register,
          name: RouteNames.register,
          pageBuilder: (context, state) => RouteTransitions.slideTransition(
            const RegisterScreen(),
          ),
        ),
      ];

  ShellRoute get _mainShellRoute => ShellRoute(
        navigatorKey: NavigatorKeys.shellNavigator,
        builder: (context, state, child) {
          return ScaffoldWithBottomNav(child: child);
        },
        routes: [
          _homeRoute,
          _tasksShellRoute,
          _profileRoute,
          _settingsRoute,
        ],
      );

  GoRoute get _homeRoute => GoRoute(
        path: RoutePaths.home,
        name: RouteNames.home,
        builder: (context, state) => const HomeScreen(),
      );

  ShellRoute get _tasksShellRoute => ShellRoute(
        builder: (context, state, child) {
          return BlocProvider(
            create: (_) => sl<TaskBloc>(),
            child: child,
          );
        },
        routes: [
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

                  if (!RouteGuards.validateTaskId(taskId)) {
                    return const Scaffold(
                      body: Center(child: Text('Invalid Task ID')),
                    );
                  }

                  return TaskDetailsScreen(taskId: taskId);
                },
                routes: [
                  GoRoute(
                    path: RoutePaths.subTasks,
                    name: RouteNames.subTasks,
                    pageBuilder: (context, state) {
                      final taskId = state.pathParameters['taskId']!;

                      if (!RouteGuards.validateTaskId(taskId)) {
                        return RouteTransitions.fadeTransition(
                          const Scaffold(
                            body: Center(child: Text('Invalid Task ID')),
                          ),
                        );
                      }

                      return RouteTransitions.slideTransition(
                        SubTasksScreen(taskId: taskId),
                      );
                    },
                  ),
                ],
              ),
              GoRoute(
                path: RoutePaths.editTask,
                name: RouteNames.editTask,
                pageBuilder: (context, state) {
                  final taskId = state.pathParameters['taskId']!;

                  // Placeholder for EditTaskScreen - implement when available
                  return RouteTransitions.slideTransition(
                    Scaffold(
                      appBar: AppBar(title: Text('Edit Task $taskId')),
                      body: const Center(child: Text('Edit Task Screen')),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      );

  GoRoute get _profileRoute => GoRoute(
        path: RoutePaths.profile,
        name: RouteNames.profile,
        builder: (context, state) => const ProfileScreen(),
        routes: [
          GoRoute(
            path: RoutePaths.editProfile,
            name: RouteNames.editProfile,
            pageBuilder: (context, state) {
              return RouteTransitions.fadeTransition(
                const EditProfileScreen(),
              );
            },
          ),
          GoRoute(
            path: RoutePaths.preferences,
            name: RouteNames.preferences,
            pageBuilder: (context, state) {
              // Placeholder for PreferencesScreen - implement when available
              return RouteTransitions.slideTransition(
                Scaffold(
                  appBar: AppBar(title: const Text('Preferences')),
                  body: const Center(child: Text('Preferences Screen')),
                ),
              );
            },
          ),
        ],
      );

  GoRoute get _settingsRoute => GoRoute(
        path: RoutePaths.settings,
        name: RouteNames.settings,
        pageBuilder: (context, state) {
          // Placeholder for SettingsScreen - implement when available
          return RouteTransitions.slideTransition(
            Scaffold(
              appBar: AppBar(title: const Text('Settings')),
              body: const Center(child: Text('Settings Screen')),
            ),
          );
        },
      );
}
