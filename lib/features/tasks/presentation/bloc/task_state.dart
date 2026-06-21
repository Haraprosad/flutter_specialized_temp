import 'package:equatable/equatable.dart';
import 'package:flutter_specialized_temp/features/tasks/domain/entities/task_entity.dart';

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
  const TasksLoaded(this.tasks);
  final List<TaskEntity> tasks;

  @override
  List<Object?> get props => [tasks];
}

class TaskDetailsLoaded extends TaskState {
  const TaskDetailsLoaded(this.task);
  final TaskEntity task;

  @override
  List<Object?> get props => [task];
}

class TaskError extends TaskState {
  const TaskError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
