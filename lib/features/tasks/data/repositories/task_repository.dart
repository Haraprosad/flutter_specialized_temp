import 'package:flutter_specialized_temp/features/tasks/data/datasources/task_local_datasources.dart';
import 'package:flutter_specialized_temp/features/tasks/domain/entities/task_entity.dart';
import 'package:flutter_specialized_temp/features/tasks/domain/repositories/task_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: TaskRepository)
class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl(this.localDataSource);
  final TaskLocalDataSource localDataSource;

  @override
  Future<List<TaskEntity>> getTasks() async {
    final models = await localDataSource.getTasks();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<TaskEntity> getTaskById(String id) async {
    final model = await localDataSource.getTaskById(id);
    return model.toEntity();
  }

  // Implement other repository methods...
}
