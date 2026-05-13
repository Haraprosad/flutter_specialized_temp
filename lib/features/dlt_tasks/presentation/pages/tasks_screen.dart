import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_specialized_temp/core/design_management_system/design_management_system.dart';
import 'package:flutter_specialized_temp/features/dlt_tasks/presentation/bloc/task_bloc.dart';
import 'package:flutter_specialized_temp/features/dlt_tasks/presentation/bloc/task_event.dart';
import 'package:flutter_specialized_temp/features/dlt_tasks/presentation/bloc/task_state.dart';
import 'package:flutter_specialized_temp/features/dlt_tasks/presentation/widgets/task_item.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<TaskBloc>().add(const GetTasksEvent());
    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks', style: Theme.of(context).textTheme.headlineMedium),
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TasksLoaded) {
            return ListView.separated(
              padding: EdgeInsets.all(AppSpacing.md),
              itemCount: state.tasks.length,
              separatorBuilder: (context, index) =>
                  SizedBox(height: AppSpacing.smV),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new task
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
