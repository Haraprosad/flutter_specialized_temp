import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_specialized_temp/core/database/dao/task_dao.dart';
import 'package:flutter_specialized_temp/core/database/tables/tasks_table.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// Central Drift database. Registered as a lazy singleton so GetIt provides
/// the same instance to all DAOs throughout the app's lifetime.
///
/// **Adding a new table:**
/// 1. Create a table class in `lib/core/database/tables/`.
/// 2. Add it to the `tables` list below.
/// 3. Bump [schemaVersion] and add a migration step in [migration].
/// 4. Run `./scripts/codegen.sh`.
@lazySingleton
@DriftDatabase(tables: [Tasks], daos: [TaskDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          // Add migration steps here as schemaVersion grows.
          // Example:
          //   if (from < 2) await m.addColumn(tasks, tasks.someNewColumn);
        },
      );

  /// DAO accessors — used by feature repositories via DI.
  TaskDao get taskDao => TaskDao(this);
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'app.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
