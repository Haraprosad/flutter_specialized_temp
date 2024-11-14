import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_specialized_temp/features/tasks/domain/usecases/get_tasks.dart';
import 'package:flutter_specialized_temp/features/tasks/presentation/bloc/task_event.dart';
import 'package:flutter_specialized_temp/features/tasks/presentation/bloc/task_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTasks getTasks;

  TaskBloc(this.getTasks) : super(TaskInitial()) {
    on<GetTasksEvent>((event, emit) async {
      emit(TaskLoading());
      try {
        final tasks = await getTasks();
        emit(TasksLoaded(tasks));
      } catch (e) {
        emit(TaskError(e.toString()));
      }
    });
  }
}