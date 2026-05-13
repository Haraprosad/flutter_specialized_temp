import 'package:flutter/material.dart';
import 'package:flutter_specialized_temp/core/design_management_system/design_management_system.dart';

class SubTasksScreen extends StatelessWidget {
  const SubTasksScreen({required this.taskId, super.key});
  final String taskId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sub Tasks', style: context.headlineMedium)),
      body: ListView.builder(
        padding: EdgeInsets.all(AppSpacing.md),
        itemCount: 5,
        itemBuilder: (context, index) {
          return CheckboxListTile(
            value: index.isEven,
            onChanged: (value) {},
            title: Text('Sub Task ${index + 1}', style: context.titleMedium),
            subtitle: Text('Due: Tomorrow', style: context.bodyMedium),
          );
        },
      ),
    );
  }
}
