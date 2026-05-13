import 'package:flutter_specialized_temp/features/dlt_tasks/domain/entities/task_entity.dart';
import 'package:flutter_specialized_temp/features/dlt_tasks/domain/usecases/get_tasks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockTaskRepository mockRepository;
  late GetTasks useCase;

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
    useCase = GetTasks(mockRepository);
  });

  group('GetTasks use case', () {
    test('returns task list from repository on success', () async {
      when(() => mockRepository.getTasks()).thenAnswer((_) async => tTasks);

      final result = await useCase();

      expect(result, equals(tTasks));
      verify(() => mockRepository.getTasks()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('returns empty list when repository has no tasks', () async {
      when(() => mockRepository.getTasks()).thenAnswer((_) async => []);

      final result = await useCase();

      expect(result, isEmpty);
    });

    test('propagates exception when repository throws', () async {
      when(
        () => mockRepository.getTasks(),
      ).thenThrow(Exception('Network error'));

      expect(() => useCase(), throwsA(isA<Exception>()));
    });

    test('calls repository exactly once per invocation', () async {
      when(() => mockRepository.getTasks()).thenAnswer((_) async => tTasks);

      await useCase();
      await useCase();

      verify(() => mockRepository.getTasks()).called(2);
    });
  });
}
