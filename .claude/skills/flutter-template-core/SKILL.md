---
name: flutter-template-core
description: >
  Core architecture rules for the flutter_specialized_temp template. Activates
  when implementing any feature layer — entities, models, datasources,
  repositories, use cases, BLoCs, DI wiring, or network calls. Keywords: clean
  architecture, BLoC, use case, repository, datasource, ApiResult, safeApiCall,
  Freezed, JsonParseUtils, GetIt, Injectable, GoRouter.
---

# Flutter Template Core

Hardened rules for building features the template's way. This is the source of
truth for Phase 5 (implementation). Always mirror an existing feature:
`lib/features/dlt_auth/` for API-shaped features, `lib/features/dlt_tasks/` for
Drift-backed features.

## Layer boundaries (non-negotiable)

```
features/dlt_<name>/
├── domain/         entities (Equatable), repository interfaces, use cases
├── data/           models (Freezed), datasources, repository impls
└── presentation/   bloc (events/states), pages, widgets
```

- **Domain has zero Flutter/Dio imports.** Only `equatable` (+ Dart core). No
  `material.dart`, no `dio`, no Freezed in entities.
- **BLoCs depend on use cases, never repositories.** Use cases depend on
  repository *interfaces* (domain), never implementations.
- **Dependencies point inward**: presentation → domain ← data. Data implements
  domain interfaces; presentation never imports data directly.

## Dependency injection — constructor injection only

Never call `sl<T>()` / `getIt<T>()` inside BLoCs, use cases, repositories, or
datasources. Inject through the constructor and annotate:

```dart
@LazySingleton(as: TaskRepository)          // bind impl to interface
class TaskRepositoryImpl extends BaseApiRepository implements TaskRepository {
  final TaskRemoteDatasource _remote;
  TaskRepositoryImpl(this._remote, super.errorHandler);
}

@injectable                                  // use cases & blocs
class GetTasksUseCase { ... }
```

Annotations seen in this repo: `@LazySingleton(as: X)` for datasources /
repositories, `@injectable` for use cases and BLoCs. After any annotation
change run `./scripts/codegen.sh` (regenerates `injection.config.dart`). Never
hand-edit generated files.

## Models — Freezed + JsonParseUtils + toEntity

Models live in `data/models/`, extend the entity contract via a `toEntity()`
mapper. Pattern (see `lib/features/dlt_tasks/data/models/task_model.dart`):

```dart
@freezed
abstract class TaskModel with _$TaskModel {
  const factory TaskModel({ required String id, required String title, ... }) = _TaskModel;
  const TaskModel._();
  factory TaskModel.fromJson(Map<String, dynamic> json) => _$TaskModelFromJson(json);
  TaskEntity toEntity() => TaskEntity(id: id, title: title, ...);
}
```

- For untrusted/remote JSON, every field uses a `JsonParseUtils` converter
  (`JsonParseUtils.toInt/toDouble/toBool/toDateTime/toEnum/toStringOrEmpty/...`
  in `lib/core/network/utils/json_parse_utils.dart`) plus `@Default`. Never
  raw-`as`-cast a JSON value.
- One concept per file: one entity, one model, one use case per file.

## Network — every call through safeApiCall → ApiResult<T>

Repositories extend `BaseApiRepository`
(`lib/core/network/base_api_repository.dart`) and wrap calls in `safeApiCall`,
which returns `ApiResult<T>` (`lib/core/network/models/api_result.dart`, a
sealed class: `ApiSuccess<T>` / `ApiFailure<T>`):

```dart
@override
Future<ApiResult<List<TaskEntity>>> getTasks() => safeApiCall(
  tag: 'getTasks',
  call: () async {
    final models = await _remote.getTasks();
    return models.map((m) => m.toEntity()).toList();
  },
);
```

- For high-traffic features needing caching / batching / circuit-breaking,
  extend `ScalableBaseRepository` instead (`optimizedApiCall`).
- **Never** `try/catch` a `DioException` inside a BLoC — error mapping is the
  repository's job (`NetworkErrorHandler`).

## BLoC — exhaustive switch on ApiResult

Handlers switch on the sealed `ApiResult` exhaustively (Dart 3):

```dart
final result = await _getTasks();
switch (result) {
  case ApiSuccess(:final data):  emit(TasksLoaded(data));
  case ApiFailure(:final failure): emit(TasksError(failure.message));
}
```

Use `bloc_concurrency` transformers (`droppable()` for refresh,
`sequential()`/`restartable()` where appropriate). Emit all relevant states:
initial, loading, loaded-empty, loaded-populated, error.

## Routing

Add routes in `lib/core/router/`: path constant, route name, `GoRoute`
definition. Respect existing auth guards / shell routes.

## Localization

No hardcoded user-facing strings. Use `context.loc.<key>` (ARB files in
`lib/core/localization/`, English + Bengali).

## Before you commit

```bash
./scripts/codegen.sh                                  # if annotations changed
flutter analyze --fatal-infos --fatal-warnings        # zero issues
flutter test                                          # all green
```

See `docs/02_ARCHITECTURE.md` and `docs/03_FEATURE_GUIDE.md` for the full
walkthrough.
