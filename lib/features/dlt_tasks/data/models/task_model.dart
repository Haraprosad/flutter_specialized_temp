import 'package:flutter_specialized_temp/features/dlt_tasks/domain/entities/task_entity.dart';

class TaskModel extends TaskEntity {
  TaskModel({
    required String id,
    required String title,
    required String description,
    required bool isCompleted,
    required DateTime createdAt,
  }) : super(
          id: id,
          title: title,
          description: description,
          isCompleted: isCompleted,
          createdAt: createdAt,
        );

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      isCompleted: json['isCompleted'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
