import 'package:flutter/material.dart';
import 'package:flutter_specialized_temp/core/di/injection.dart';
import 'package:flutter_specialized_temp/core/router/route_names.dart';
import 'package:flutter_specialized_temp/core/theme/color_scheme_ext.dart';
import 'package:flutter_specialized_temp/core/theme/text_theme_ext.dart';
import 'package:flutter_specialized_temp/core/utils/app_spacing.dart';
import 'package:flutter_specialized_temp/dlt_common_actions/infinite_scrolling/presentation/bloc/post_bloc.dart';
import 'package:flutter_specialized_temp/dlt_common_actions/infinite_scrolling/presentation/pages/posts_page.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home', style: context.headlineMedium),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => context.goNamed(RouteNames.notifications),
          ),
        ],
      ),
      body: BlocProvider(
        create: (context) => sl<PostsBloc>(),
        child: const PostsPage(),
      ),
    );
  }
}