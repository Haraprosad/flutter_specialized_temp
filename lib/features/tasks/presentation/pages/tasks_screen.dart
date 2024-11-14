import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_specialized_temp/core/bloc/navigation_bloc.dart';
import 'package:flutter_specialized_temp/core/utils/app_spacing.dart';
import 'package:flutter_specialized_temp/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:flutter_specialized_temp/features/tasks/presentation/bloc/task_state.dart';
import 'package:flutter_specialized_temp/features/tasks/presentation/widgets/task_item.dart';

import '../../../../core/di/injection.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tasks',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: BlocProvider(
        create: (BuildContext ctx) =>sl<TaskBloc>(),
        child: BlocBuilder<TaskBloc, TaskState>(
          builder: (context, state) {
            if (state is TaskLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TasksLoaded) {
              return ListView.separated(
                padding: EdgeInsets.all(AppSpacing.mediumW),
                itemCount: state.tasks.length,
                separatorBuilder: (context, index) => SizedBox(height: AppSpacing.smallH),
                itemBuilder: (context, index) {
                  final task = state.tasks[index];
                  return TaskItem(task: task);
                },
              );
            } else if (state is TaskError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new task
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}