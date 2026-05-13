# Architecture Reference

> Quick reference for all agents. Read before generating any code that touches layers, DI, or routing.

---

## The Dependency Rule (absolute)

```
Presentation  →  Domain  ←  Data
```

- Presentation depends on Domain (uses entities, calls use cases)
- Data depends on Domain (implements repository interfaces, converts models → entities)
- Domain depends on NOTHING (pure Dart: equatable only)
- **No reverse arrows. Ever.**

---

## Dependency Flow (trace any bug through this)

```
UI (Page / Widget)
  └─→ BLoC  (@injectable, factory)
        └─→ UseCase  (@injectable, factory)
              └─→ Repository Interface  (abstract class in domain/)
                    └─→ RepositoryImpl  (@LazySingleton(as: Interface))
                          └─→ RemoteDataSource  (@lazySingleton)
                                └─→ DioClient
                          └─→ LocalDataSource  (@lazySingleton, optional)
                                └─→ AppDatabase / SecureStorageManager
```

**One-way only. Never skip levels. Never inject across features.**

---

## Layer Rules — What Lives Where

### domain/

| File type      | Rule                                           |
|----------------|------------------------------------------------|
| Entity         | `extends Equatable`, all fields in `props`, zero external deps |
| Repository IF  | `abstract class`, returns `ApiResult<T>` or domain types |
| UseCase        | `@injectable`, one `call()` method, delegates to repository |
| Imports        | `package:equatable` only (no Flutter, no Dio, no freezed) |

### data/

| File type      | Rule                                           |
|----------------|------------------------------------------------|
| Model          | `@freezed`, every `@JsonKey` uses `JsonParseUtils`, every non-nullable has `@Default`, has `toEntity()` |
| RemoteDS       | `@lazySingleton`, injects `DioClient`, returns models, lets exceptions propagate |
| LocalDS        | `@lazySingleton`, injects `AppDatabase` or storage, returns models |
| RepositoryImpl | `@LazySingleton(as: Interface)`, extends `BaseApiRepository`, wraps everything in `safeApiCall` |

### presentation/

| File type      | Rule                                           |
|----------------|------------------------------------------------|
| BLoC           | `@injectable`, injects use cases only, `switch` on `ApiResult`, uses `bloc_concurrency` transformers |
| Event          | `with EquatableMixin`, all fields in `props`  |
| State          | `with EquatableMixin`, all fields in `props`  |
| Screen         | `BlocProvider(create: (_) => sl<XBloc>()..add(InitEvent()))` |
| View           | `BlocConsumer` (both builder + listener), Dart 3 switch expression on state |

---

## DI Annotation Reference

| Annotation                     | Lifetime   | Use For                           |
|--------------------------------|------------|-----------------------------------|
| `@injectable`                  | Factory    | BLoCs, UseCases                   |
| `@lazySingleton`               | Lazy single| DataSources, Services             |
| `@LazySingleton(as: Interface)`| Lazy single| Repository Impls (bound to interface) |
| `@singleton`                   | Eager      | Avoid — only for mandatory startup init |
| `@module` class + `@lazySingleton` method | Manual | Third-party types (Dio, DB, etc.) |

**After any annotation change**: `./scripts/codegen.sh`
**Never edit**: `lib/core/di/injection.config.dart`

---

## ApiResult Pattern

```dart
// Repository returns:
Future<ApiResult<T>> someMethod() => safeApiCall(
  tag: 'someMethod',
  call: () async { /* ... */ return value; },
);

// BLoC consumes — ALWAYS switch, never if/else:
final result = await _someUseCase();
switch (result) {
  case ApiSuccess(:final data):
    emit(LoadedState(data));
  case ApiFailure(:final failure):
    emit(ErrorState(failure.translatedMessage));
}
```

---

## Error Flow

```
API call
  → DioException
    → ErrorInterceptor  (maps to AppException)
      → safeApiCall  (catches AppException → ApiCallFailureModel)
        → ApiFailure(failure)
          → BLoC  (emits ErrorState(failure.translatedMessage))
            → UI  (shows localised message)
```

BLoCs never catch `DioException`. Repositories never expose `DioException`. UI never shows raw exception messages.

---

## BLoC Concurrency Transformers

```dart
on<FetchEvent>(_onFetch, transformer: droppable());    // ignore concurrent
on<SearchEvent>(_onSearch, transformer: restartable()); // cancel & restart
on<CreateEvent>(_onCreate, transformer: sequential()); // queue mutations
on<DeleteEvent>(_onDelete, transformer: sequential()); // queue mutations
```

Import: `package:bloc_concurrency/bloc_concurrency.dart`

---

## Routing Rules

| Rule                              | Why                                    |
|-----------------------------------|----------------------------------------|
| Route paths in `route_paths.dart` | Single source of truth, no hard-coding |
| Route names in `route_names.dart` | Use `goNamed()`, not `go()` with strings |
| Auth guard in `route_guards.dart` | Centralised, not per-screen            |
| Shell routes for bottom nav        | `ScaffoldWithBottomNav` + `NavigationBloc` |
| Deep link parameters validated     | Treat as untrusted input               |

---

## SOLID Principles — Applied

| Principle | Concrete rule in this codebase                           |
|-----------|----------------------------------------------------------|
| **S**     | Each UseCase has one `call()`. Each BLoC manages one feature's state. |
| **O**     | New feature = new folder. No existing files modified.    |
| **L**     | `AuthRepositoryImpl` is substitutable for `AuthRepository` anywhere. |
| **I**     | `TaskRepository` has task methods only. `AuthRepository` has auth only. |
| **D**     | BLoC depends on `LoginUseCase` (abstraction). Injectable resolves the concrete. |
