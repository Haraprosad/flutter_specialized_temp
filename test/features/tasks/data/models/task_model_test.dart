import 'dart:convert';

import 'package:flutter_specialized_temp/features/tasks/data/models/task_model.dart';
import 'package:flutter_specialized_temp/features/tasks/domain/entities/task_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_helpers.dart';

void main() {
  final tTaskJson = {
    'id': '1',
    'title': 'Complete Project Documentation',
    'description': 'Write comprehensive documentation for the Flutter project',
    'isCompleted': false,
    'createdAt': '2024-01-15T10:00:00.000',
  };

  final tTaskModel = TaskModel(
    id: '1',
    title: 'Complete Project Documentation',
    description: 'Write comprehensive documentation for the Flutter project',
    isCompleted: false,
    createdAt: DateTime(2024, 1, 15, 10),
  );

  group('TaskModel', () {
    group('fromJson', () {
      test('creates model from a valid JSON map', () {
        final result = TaskModel.fromJson(tTaskJson);

        expect(result.id, equals(tTaskModel.id));
        expect(result.title, equals(tTaskModel.title));
        expect(result.description, equals(tTaskModel.description));
        expect(result.isCompleted, equals(tTaskModel.isCompleted));
        expect(result.createdAt, equals(tTaskModel.createdAt));
      });

      test('parses fixture file correctly', () {
        final raw = readFixture('task_fixture.json');
        final list = (jsonDecode(raw) as List<dynamic>)
            .cast<Map<String, dynamic>>();

        expect(list, hasLength(2));

        final first = TaskModel.fromJson(list.first);
        expect(first.id, equals('1'));
        expect(first.isCompleted, isFalse);

        final second = TaskModel.fromJson(list.last);
        expect(second.id, equals('2'));
        expect(second.isCompleted, isTrue);
      });
    });

    group('toJson', () {
      test('serializes model to a valid JSON map', () {
        final json = tTaskModel.toJson();

        expect(json['id'], equals(tTaskModel.id));
        expect(json['title'], equals(tTaskModel.title));
        expect(json['isCompleted'], equals(tTaskModel.isCompleted));
      });

      test('round-trip fromJson → toJson preserves data', () {
        final roundTripped = TaskModel.fromJson(tTaskModel.toJson());

        expect(roundTripped, equals(tTaskModel));
      });
    });

    group('toEntity', () {
      test('converts model to TaskEntity with matching fields', () {
        final entity = tTaskModel.toEntity();

        expect(entity, isA<TaskEntity>());
        expect(entity.id, equals(tTaskModel.id));
        expect(entity.title, equals(tTaskModel.title));
        expect(entity.description, equals(tTaskModel.description));
        expect(entity.isCompleted, equals(tTaskModel.isCompleted));
        expect(entity.createdAt, equals(tTaskModel.createdAt));
      });
    });

    group('equality', () {
      test('two models with same data are equal', () {
        final copy = TaskModel(
          id: tTaskModel.id,
          title: tTaskModel.title,
          description: tTaskModel.description,
          isCompleted: tTaskModel.isCompleted,
          createdAt: tTaskModel.createdAt,
        );

        expect(tTaskModel, equals(copy));
      });
    });
  });
}
