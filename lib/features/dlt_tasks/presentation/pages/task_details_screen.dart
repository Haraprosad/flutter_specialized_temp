import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_specialized_temp/core/design_management_system/design_management_system.dart';
import 'package:flutter_specialized_temp/features/dlt_tasks/presentation/bloc/task_bloc.dart';
import 'package:flutter_specialized_temp/features/dlt_tasks/presentation/bloc/task_state.dart';

class TaskDetailsScreen extends StatelessWidget {
  const TaskDetailsScreen({required this.taskId, super.key});
  final String taskId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        if (state is TasksLoaded) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Task Details',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            body: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Text("Details Loaded")],
              ),
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
