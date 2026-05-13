import 'package:flutter/material.dart';

import 'package:flutter_specialized_temp/core/design_management_system/design_management_system.dart';


class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications', style: context.headlineMedium),
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(AppSpacing.xl),
        itemCount: 5,
        separatorBuilder: (_, __) => Divider(height: AppSpacing.sm),
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