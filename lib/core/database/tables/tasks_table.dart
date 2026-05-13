import 'package:drift/drift.dart';

/// Local SQLite table for offline task storage.
///
/// Column names mirror the remote API payload so that [TaskModel.toCompanion()]
/// conversions stay trivial. All nullable remote fields are also nullable here.
class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  BoolColumn get isCompleted =>
      boolean().withDefault(const Constant(false))();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  /// Whether this row has local changes not yet synced to the server.
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
