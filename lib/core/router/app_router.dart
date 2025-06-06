import 'package:flutter/material.dart';
import 'package:flutter_specialized_temp/core/observers/router_observer.dart';
import 'package:flutter_specialized_temp/core/router/app_routes.dart';
import 'package:flutter_specialized_temp/core/router/go_router_refresh_stream.dart';
import 'package:flutter_specialized_temp/core/router/navigator_keys.dart';
import 'package:flutter_specialized_temp/core/router/route_paths.dart';
import 'package:flutter_specialized_temp/core/router/route_guards.dart';
import 'package:flutter_specialized_temp/core/widgets/error_screen.dart';
import 'package:flutter_specialized_temp/features/dlt_auth/presentation/bloc/bloc/auth_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

import '../logger/app_logger.dart';

@singleton
class AppRouter {
  final AuthBloc _authBloc;
  final AppRoutes _appRoutes;

  AppRouter(this._authBloc, this._appRoutes);

  late final GoRouter routerConfig = GoRouter(
    navigatorKey: NavigatorKeys.rootNavigator,
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: true,
    routes: _appRoutes.routes,
    redirect: (context, state) => RouteGuards.authGuard(context, state),
    refreshListenable: GoRouterRefreshStream(_authBloc.stream),
    errorBuilder: (context, state) => ErrorScreen(
      errorMessage: state.error.toString(),
    ),
    observers: [
      AppRouterObserver(),
    ],
  );
}
