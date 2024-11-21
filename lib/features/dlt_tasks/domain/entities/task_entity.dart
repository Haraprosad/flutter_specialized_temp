class TaskEntity {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime createdAt;

  TaskEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.createdAt,
  });
}