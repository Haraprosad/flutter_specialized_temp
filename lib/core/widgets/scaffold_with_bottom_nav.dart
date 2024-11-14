import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_specialized_temp/core/bloc/navigation_bloc.dart';
import 'package:flutter_specialized_temp/core/bloc/navigation_event.dart';
import 'package:flutter_specialized_temp/core/bloc/navigation_state.dart';
import 'package:flutter_specialized_temp/core/router/route_names.dart';
import 'package:flutter_specialized_temp/core/router/route_paths.dart';
import 'package:go_router/go_router.dart';

import '../di/injection.dart';

class ScaffoldWithBottomNav extends StatelessWidget {
  final Widget child;
  
  const ScaffoldWithBottomNav({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext ctx) => sl<NavigationBloc>(),
      child: BlocBuilder<NavigationBloc, NavigationState>(
        builder: (context, state) {
          return Scaffold(
            body: child,
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _calculateSelectedIndex(context),
              onTap: (index) => _onItemTapped(index, context),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.task),
                  label: 'Tasks',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouter.of(context).routerDelegate.currentConfiguration.fullPath;
    if (location.startsWith(RoutePaths.tasks)) return 1;
    if (location.startsWith(RoutePaths.profile)) return 2;
    return 0;
  }
  
  void _onItemTapped(int index, BuildContext context) {
    context.read<NavigationBloc>().add(NavigationTabChanged(index));
    
    switch (index) {
      case 0:
        context.goNamed(RouteNames.home);
        break;
      case 1:
        context.goNamed(RouteNames.tasks);
        break;
      case 2:
        context.goNamed(RouteNames.profile);
        break;
    }
  }
}
