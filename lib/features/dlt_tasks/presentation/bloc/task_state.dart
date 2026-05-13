import 'package:equatable/equatable.dart';
import 'package:flutter_specialized_temp/features/dlt_tasks/domain/entities/task_entity.dart';

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {
  const TaskInitial();
}

class TaskLoading extends TaskState {
  const TaskLoading();
}

class TasksLoaded extends TaskState {
  final List<TaskEntity> tasks;

  const TasksLoaded(this.tasks);

  @override
  List<Object?> get props => [tasks];
}

class TaskDetailsLoaded extends TaskState {
  final TaskEntity task;

  const TaskDetailsLoaded(this.task);

  @override
  List<Object?> get props => [task];
}

class TaskError extends TaskState {
  final String message;

  const TaskError(this.message);

  @override
  List<Object?> get props => [message];
}
