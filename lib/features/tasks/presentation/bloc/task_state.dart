import 'package:flutter_specialized_temp/features/tasks/domain/entities/task_entity.dart';

abstract class TaskState {}

class TaskInitial extends TaskState {}
class TaskLoading extends TaskState {}
class TasksLoaded extends TaskState {
  final List<TaskEntity> tasks;
  TasksLoaded(this.tasks);
}
class TaskDetailsLoaded extends TaskState {
  final TaskEntity task;
  TaskDetailsLoaded(this.task);
}
class TaskError extends TaskState {
  final String message;
  TaskError(this.message);
}