import 'package:flutter_specialized_temp/features/dlt_tasks/data/datasources/task_local_datasources.dart';
import 'package:flutter_specialized_temp/features/dlt_tasks/domain/entities/task_entity.dart';
import 'package:flutter_specialized_temp/features/dlt_tasks/domain/repositories/task_repository.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: TaskRepository)
class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource localDataSource;

  TaskRepositoryImpl(this.localDataSource);

  @override
  Future<List<TaskEntity>> getTasks() async {
    return await localDataSource.getTasks();
  }

  @override
  Future<TaskEntity> getTaskById(String id) async {
    return await localDataSource.getTaskById(id);
  }

  // Implement other repository methods...
}