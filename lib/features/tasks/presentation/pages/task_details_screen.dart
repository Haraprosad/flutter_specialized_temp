import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_specialized_temp/core/utils/app_spacing.dart';
import 'package:flutter_specialized_temp/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:flutter_specialized_temp/features/tasks/presentation/bloc/task_state.dart';

class TaskDetailsScreen extends StatelessWidget {
  final String taskId;

  const TaskDetailsScreen({Key? key, required this.taskId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        if (state is TaskDetailsLoaded) {
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
                  Text(
                    state.task.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: AppSpacing.mediumH),
                  Text(
                    state.task.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  SizedBox(height: AppSpacing.largeH),
                  Row(
                    children: [
                      Icon(
                        state.task.isCompleted
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                        color: state.task.isCompleted
                            ? Theme.of(context).primaryColor
                            : null,
                      ),
                      SizedBox(width: AppSpacing.smallW),
                      Text(
                        state.task.isCompleted ? 'Completed' : 'In Progress',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
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