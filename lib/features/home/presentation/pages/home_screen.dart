import 'package:flutter/material.dart';
import 'package:flutter_specialized_temp/core/router/route_names.dart';
import 'package:flutter_specialized_temp/core/theme/color_scheme_ext.dart';
import 'package:flutter_specialized_temp/core/theme/text_theme_ext.dart';
import 'package:flutter_specialized_temp/core/utils/app_spacing.dart';
import 'package:go_router/go_router.dart';

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
      body: ListView.builder(
        padding: EdgeInsets.all(AppSpacing.mediumW),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.only(bottom: AppSpacing.smallH),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: context.colorScheme.primary,
                child: Text('${index + 1}'),
              ),
              title: Text('Dashboard Item ${index + 1}', style: context.titleMedium),
              subtitle: Text('Description for item ${index + 1}', style: context.bodyMedium),
            ),
          );
        },
      ),
    );
  }
}