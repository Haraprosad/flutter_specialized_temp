import 'package:flutter_specialized_temp/features/tasks/domain/entities/task_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final createdAt = DateTime(2024, 1, 15, 10);

  final tTask = TaskEntity(
    id: '1',
    title: 'Test Task',
    description: 'A test task description',
    isCompleted: false,
    createdAt: createdAt,
  );

  group('TaskEntity', () {
    test('supports value equality via Equatable', () {
      final duplicate = TaskEntity(
        id: '1',
        title: 'Test Task',
        description: 'A test task description',
        isCompleted: false,
        createdAt: createdAt,
      );

      expect(tTask, equals(duplicate));
    });

    test('instances with different fields are not equal', () {
      final different = TaskEntity(
        id: '2',
        title: 'Other Task',
        description: 'Different description',
        isCompleted: true,
        createdAt: createdAt,
      );

      expect(tTask, isNot(equals(different)));
    });

    test('props contains all fields', () {
      expect(
        tTask.props,
        containsAll([
          tTask.id,
          tTask.title,
          tTask.description,
          tTask.isCompleted,
          tTask.createdAt,
        ]),
      );
    });

    test('isCompleted reflects the correct completion status', () {
      expect(tTask.isCompleted, isFalse);

      final completed = TaskEntity(
        id: '3',
        title: 'Done',
        description: 'Finished',
        isCompleted: true,
        createdAt: DateTime(2024),
      );

      expect(completed.isCompleted, isTrue);
    });
  });
}
