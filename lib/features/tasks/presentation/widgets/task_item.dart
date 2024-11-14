import 'package:flutter/material.dart';
import 'package:flutter_specialized_temp/core/router/route_names.dart';
import 'package:flutter_specialized_temp/features/tasks/domain/entities/task_entity.dart';
import 'package:go_router/go_router.dart';

class TaskItem extends StatelessWidget {
  final TaskEntity task;

  const TaskItem({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(
          task.title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          task.description,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        trailing: Icon(
          task.isCompleted ? Icons.check_circle : Icons.circle_outlined,
          color: task.isCompleted ? Theme.of(context).primaryColor : null,
        ),
        onTap: () {
          context.pushNamed(
            RouteNames.taskDetails,
            pathParameters: {'taskId': task.id},
          );
        },
      ),
    );
  }
}