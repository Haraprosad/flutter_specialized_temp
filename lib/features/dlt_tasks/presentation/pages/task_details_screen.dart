import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_specialized_temp/core/utils/app_spacing.dart';
import 'package:flutter_specialized_temp/features/dlt_tasks/presentation/bloc/task_bloc.dart';
import 'package:flutter_specialized_temp/features/dlt_tasks/presentation/bloc/task_event.dart';
import 'package:flutter_specialized_temp/features/dlt_tasks/presentation/bloc/task_state.dart';

class TaskDetailsScreen extends StatelessWidget {
  final String taskId;

  const TaskDetailsScreen({Key? key, required this.taskId}) : super(key: key);

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
              padding: EdgeInsets.all(AppSpacing.mediumW),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 Text("Details Loaded")
                ],
              ),
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}