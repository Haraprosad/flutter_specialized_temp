import 'package:flutter_specialized_temp/features/dlt_tasks/data/models/task_model.dart';
import 'package:injectable/injectable.dart';

@injectable
class TaskLocalDataSource {
  final List<TaskModel> _dummyTasks = [
    TaskModel(
      id: '1',
      title: 'Complete Project Documentation',
      description: 'Write comprehensive documentation for the Flutter project',
      isCompleted: false,
      createdAt: DateTime.now(),
    ),
    TaskModel(
      id: '2',
      title: 'Implement Unit Tests',
      description: 'Add unit tests for all repository implementations',
      isCompleted: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  Future<List<TaskModel>> getTasks() async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    return _dummyTasks;
  }

  Future<TaskModel> getTaskById(String id) async {
    await Future.delayed(const Duration(seconds: 1));
    return _dummyTasks.firstWhere((task) => task.id == id);
  }
}