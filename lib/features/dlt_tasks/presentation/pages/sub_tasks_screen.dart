import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_specialized_temp/core/theme/text_theme_ext.dart';
import 'package:flutter_specialized_temp/core/utils/app_spacing.dart';

class SubTasksScreen extends StatelessWidget {
  final String taskId;

  const SubTasksScreen({Key? key, required this.taskId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sub Tasks', style: context.headlineMedium),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(AppSpacing.mediumW),
        itemCount: 5,
        itemBuilder: (context, index) {
          return CheckboxListTile(
            value: index % 2 == 0,
            onChanged: (value) {},
            title: Text('Sub Task ${index + 1}', style: context.titleMedium),
            subtitle: Text('Due: Tomorrow', style: context.bodyMedium),
          );
        },
      ),
    );
  }
}