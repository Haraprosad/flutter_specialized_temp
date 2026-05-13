import 'package:drift/drift.dart';
import 'package:flutter_specialized_temp/core/database/app_database.dart';
import 'package:flutter_specialized_temp/core/database/tables/tasks_table.dart';

part 'task_dao.g.dart';

/// Data Access Object for offline task storage.
///
/// All queries use Drift's type-safe query builder. Raw SQL is never needed
/// for these operations — if a query feels complex enough to require raw SQL,
/// consider whether it belongs in the DAO or in a read-model.
@DriftAccessor(tables: [Tasks])
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {
  TaskDao(super.db);

  /// Returns all tasks ordered by creation date (newest first).
  Future<List<Task>> getAllTasks() =>
      (select(tasks)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();

  /// Watches all tasks; emits a new list whenever the table changes.
  Stream<List<Task>> watchAllTasks() =>
      (select(tasks)..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();

  /// Returns a single task by [id], or null if not found.
  Future<Task?> getTaskById(String id) =>
      (select(tasks)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Returns only tasks that have local changes not yet synced.
  Future<List<Task>> getDirtyTasks() =>
      (select(tasks)..where((t) => t.isDirty.equals(true))).get();

  /// Inserts or replaces a task row. Use for sync-from-server writes
  /// (isDirty = false) and local writes (isDirty = true).
  Future<void> upsertTask(TasksCompanion companion) =>
      into(tasks).insertOnConflictUpdate(companion);

  /// Bulk-upsert a list of tasks — used when syncing server responses.
  Future<void> upsertAll(List<TasksCompanion> companions) =>
      batch((b) => b.insertAllOnConflictUpdate(tasks, companions));

  /// Marks a task as dirty so [AutoSyncService] picks it up on reconnect.
  Future<void> markDirty(String id) => (update(tasks)
        ..where((t) => t.id.equals(id)))
      .write(const TasksCompanion(isDirty: Value(true)));

  /// Clears dirty flag after a successful server sync.
  Future<void> markSynced(String id) => (update(tasks)
        ..where((t) => t.id.equals(id)))
      .write(const TasksCompanion(isDirty: Value(false)));

  /// Deletes a single task locally. Caller is responsible for queueing a
  /// server-delete mutation before calling this.
  Future<int> deleteTask(String id) =>
      (delete(tasks)..where((t) => t.id.equals(id))).go();

  /// Deletes all tasks (used during logout / full cache clear).
  Future<int> clearAll() => delete(tasks).go();
}
