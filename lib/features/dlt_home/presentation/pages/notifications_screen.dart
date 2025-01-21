import 'package:flutter/material.dart';
import 'package:flutter_specialized_temp/core/theme/colors/color_scheme_ext.dart';
import 'package:flutter_specialized_temp/core/theme/typography/text_theme_ext.dart';
import 'package:flutter_specialized_temp/core/utils/app_spacing.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications', style: context.headlineMedium),
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(AppSpacing.mediumW),
        itemCount: 5,
        separatorBuilder: (_, __) => Divider(height: AppSpacing.smallH),
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(Icons.notifications,
                color: context.colorScheme.primary),
            title: Text('Notification ${index + 1}', style: context.titleMedium),
            subtitle: Text('This is a notification message',
                style: context.bodyMedium),
            trailing: Text('2h ago', style: context.bodySmall),
          );
        },
      ),
    );
  }
}