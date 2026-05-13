import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_specialized_temp/features/dlt_tasks/domain/entities/task_entity.dart';
import 'package:flutter_specialized_temp/features/dlt_tasks/domain/usecases/get_tasks.dart';
import 'package:flutter_specialized_temp/features/dlt_tasks/presentation/bloc/task_bloc.dart';
import 'package:flutter_specialized_temp/features/dlt_tasks/presentation/bloc/task_event.dart';
import 'package:flutter_specialized_temp/features/dlt_tasks/presentation/bloc/task_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockTaskRepository mockRepository;
  late GetTasks getTasks;

  final tTasks = [
    TaskEntity(
      id: '1',
      title: 'Task 1',
      description: 'Description 1',
      isCompleted: false,
      createdAt: DateTime(2024, 1, 15),
    ),
    TaskEntity(
      id: '2',
      title: 'Task 2',
      description: 'Description 2',
      isCompleted: true,
      createdAt: DateTime(2024, 1, 14),
    ),
  ];

  setUp(() {
    mockRepository = MockTaskRepository();
    getTasks = GetTasks(mockRepository);
  });

  group('TaskBloc', () {
    test('initial state is TaskInitial', () {
      final bloc = TaskBloc(getTasks);
      expect(bloc.state, isA<TaskInitial>());
      bloc.close();
    });

    blocTest<TaskBloc, TaskState>(
      'emits [TaskLoading, TasksLoaded] on successful GetTasksEvent',
      build: () {
        when(() => mockRepository.getTasks()).thenAnswer((_) async => tTasks);
        return TaskBloc(getTasks);
      },
      act: (bloc) => bloc.add(const GetTasksEvent()),
      expect: () => [isA<TaskLoading>(), isA<TasksLoaded>()],
    );

    blocTest<TaskBloc, TaskState>(
      'TasksLoaded carries the correct tasks',
      build: () {
        when(() => mockRepository.getTasks()).thenAnswer((_) async => tTasks);
        return TaskBloc(getTasks);
      },
      act: (bloc) => bloc.add(const GetTasksEvent()),
      expect: () => [isA<TaskLoading>(), TasksLoaded(tTasks)],
    );

    blocTest<TaskBloc, TaskState>(
      'emits [TaskLoading, TaskError] when repository throws',
      build: () {
        when(
          () => mockRepository.getTasks(),
        ).thenThrow(Exception('Network error'));
        return TaskBloc(getTasks);
      },
      act: (bloc) => bloc.add(const GetTasksEvent()),
      expect: () => [isA<TaskLoading>(), isA<TaskError>()],
    );

    blocTest<TaskBloc, TaskState>(
      'TaskError carries the error message string',
      build: () {
        when(
          () => mockRepository.getTasks(),
        ).thenThrow(Exception('Network error'));
        return TaskBloc(getTasks);
      },
      act: (bloc) => bloc.add(const GetTasksEvent()),
      expect: () => [
        isA<TaskLoading>(),
        isA<TaskError>().having(
          (s) => s.message,
          'message',
          contains('Network error'),
        ),
      ],
    );

    blocTest<TaskBloc, TaskState>(
      'emits [TaskLoading, TasksLoaded] with empty list when no tasks exist',
      build: () {
        when(() => mockRepository.getTasks()).thenAnswer((_) async => []);
        return TaskBloc(getTasks);
      },
      act: (bloc) => bloc.add(const GetTasksEvent()),
      expect: () => [isA<TaskLoading>(), const TasksLoaded([])],
    );

    blocTest<TaskBloc, TaskState>(
      'handles multiple sequential GetTasksEvent correctly',
      build: () {
        when(() => mockRepository.getTasks()).thenAnswer((_) async => tTasks);
        return TaskBloc(getTasks);
      },
      act: (bloc) async {
        bloc.add(const GetTasksEvent());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const GetTasksEvent());
      },
      expect: () => [
        isA<TaskLoading>(),
        isA<TasksLoaded>(),
        isA<TaskLoading>(),
        isA<TasksLoaded>(),
      ],
    );
  });
}
