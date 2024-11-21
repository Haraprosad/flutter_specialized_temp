import 'package:flutter_specialized_temp/features/dlt_tasks/domain/entities/task_entity.dart';
import 'package:flutter_specialized_temp/features/dlt_tasks/domain/repositories/task_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetTasks {
  final TaskRepository repository;

  GetTasks(this.repository);

  Future<List<TaskEntity>> call() async {
    return await repository.getTasks();
  }
}