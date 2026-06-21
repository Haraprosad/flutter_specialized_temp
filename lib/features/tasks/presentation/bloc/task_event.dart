import 'package:equatable/equatable.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class GetTasksEvent extends TaskEvent {
  const GetTasksEvent();
}

class GetTaskDetailsEvent extends TaskEvent {
  const GetTaskDetailsEvent(this.taskId);
  final String taskId;

  @override
  List<Object?> get props => [taskId];
}
