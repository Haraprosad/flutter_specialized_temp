import 'package:flutter_specialized_temp/features/dlt_tasks/data/models/task_model.dart';
import 'package:flutter_specialized_temp/features/dlt_tasks/data/repositories/task_repository.dart';
import 'package:flutter_specialized_temp/features/dlt_tasks/domain/entities/task_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockTaskLocalDataSource mockDataSource;
  late TaskRepositoryImpl repository;

  final tTaskModels = [
    TaskModel(
      id: '1',
      title: 'Task 1',
      description: 'Description 1',
      isCompleted: false,
      createdAt: DateTime(2024, 1, 15),
    ),
    TaskModel(
      id: '2',
      title: 'Task 2',
      description: 'Description 2',
      isCompleted: true,
      createdAt: DateTime(2024, 1, 14),
    ),
  ];

  final tTaskEntities = tTaskModels.map((m) => m.toEntity()).toList();

  setUp(() {
    mockDataSource = MockTaskLocalDataSource();
    repository = TaskRepositoryImpl(mockDataSource);
  });

  group('TaskRepositoryImpl', () {
    group('getTasks', () {
      test('returns list of TaskEntity from data source', () async {
        when(() => mockDataSource.getTasks())
            .thenAnswer((_) async => tTaskModels);

        final result = await repository.getTasks();

        expect(result, equals(tTaskEntities));
        expect(result, everyElement(isA<TaskEntity>()));
        verify(() => mockDataSource.getTasks()).called(1);
      });

      test('returns empty list when data source has no tasks', () async {
        when(() => mockDataSource.getTasks()).thenAnswer((_) async => []);

        final result = await repository.getTasks();

        expect(result, isEmpty);
      });

      test('propagates exception from data source', () async {
        when(() => mockDataSource.getTasks())
            .thenThrow(Exception('Storage failure'));

        expect(() => repository.getTasks(), throwsA(isA<Exception>()));
      });
    });

    group('getTaskById', () {
      test('returns a single TaskEntity for a valid id', () async {
        when(() => mockDataSource.getTaskById('1'))
            .thenAnswer((_) async => tTaskModels.first);

        final result = await repository.getTaskById('1');

        expect(result, equals(tTaskEntities.first));
        expect(result.id, equals('1'));
        verify(() => mockDataSource.getTaskById('1')).called(1);
      });

      test('propagates StateError when task id not found', () async {
        when(() => mockDataSource.getTaskById('999'))
            .thenThrow(StateError('No element'));

        expect(
          () => repository.getTaskById('999'),
          throwsA(isA<StateError>()),
        );
      });
    });
  });
}
