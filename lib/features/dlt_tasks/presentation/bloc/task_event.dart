abstract class TaskEvent {}

class GetTasksEvent extends TaskEvent {}
class GetTaskDetailsEvent extends TaskEvent {
  final String taskId;
  GetTaskDetailsEvent(this.taskId);
}