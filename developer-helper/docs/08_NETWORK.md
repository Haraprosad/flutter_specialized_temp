# Guide 8 — Network Management System

Complete walkthrough of the `lib/core/network/` system: architecture, every component's role, and the step-by-step flow for integrating a new API call using Clean Architecture.

---

## Overview

Every HTTP request in this application goes through the **Network Management System** at `lib/core/network/`. Direct use of `Dio`, `http`, or any other HTTP client outside this system is **forbidden**. The system provides:

- Centralized HTTP configuration (`DioClient`)
- Interceptor chain (auth, token refresh, retry, error mapping, logging)
- Standardized error handling (`NetworkErrorHandler` → `ApiCallFailureModel`)
- Type-safe result wrapping (`ApiResult<T>` sealed class)
- Two base repository strategies (simple CRUD vs. high-traffic with caching)
- Connectivity monitoring (`ConnectivityCubit`)
- Offline-first patterns (mutation queue, auto-sync)
- Optimistic update patterns
- Parallel API loading for dashboard-style screens

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         PRESENTATION LAYER                             │
│  BLoC / Cubit                                                          │
│  ┌─────────────────────────────────────────────────────────────┐       │
│  │  switch (result) {                                          │       │
│  │    case ApiSuccess(:final data): emit(Loaded(data));        │       │
│  │    case ApiFailure(:final failure): emit(Error(failure));   │       │
│  │  }                                                          │       │
│  └──────────────────────────┬──────────────────────────────────┘       │
│                             │ calls UseCase                            │
├─────────────────────────────┼──────────────────────────────────────────┤
│                         DOMAIN LAYER                                   │
│  UseCase                    │                                          │
│  ┌──────────────────────────┴──────────────────────────────────┐       │
│  │  Future<ApiResult<T>> call(params) =>                       │       │
│  │      _repository.someMethod(params);                        │       │
│  └──────────────────────────┬──────────────────────────────────┘       │
│  Repository Interface       │ (abstract class)                         │
│  ┌──────────────────────────┴──────────────────────────────────┐       │
│  │  Future<ApiResult<List<Entity>>> getItems();                │       │
│  └──────────────────────────┬──────────────────────────────────┘       │
├─────────────────────────────┼──────────────────────────────────────────┤
│                         DATA LAYER                                     │
│  RepositoryImpl             │ extends BaseApiRepository                │
│  ┌──────────────────────────┴──────────────────────────────────┐       │
│  │  safeApiCall(                                               │       │
│  │    tag: 'getItems',                                         │       │
│  │    call: () async {                                         │       │
│  │      final models = await _remote.getItems();               │       │
│  │      return models.map((m) => m.toEntity()).toList();       │       │
│  │    },                                                       │       │
│  │  );                                                         │       │
│  └──────────────────────────┬──────────────────────────────────┘       │
│  Remote DataSource          │                                          │
│  ┌──────────────────────────┴──────────────────────────────────┐       │
│  │  final response = await _dioClient.client.get('/items');    │       │
│  │  return (response.data as List)                             │       │
│  │      .map((e) => ItemModel.fromJson(e)).toList();           │       │
│  └──────────────────────────┬──────────────────────────────────┘       │
│                             │                                          │
├─────────────────────────────┼──────────────────────────────────────────┤
│                    NETWORK MANAGEMENT SYSTEM                           │
│  DioClient                  │                                          │
│  ┌──────────────────────────┴──────────────────────────────────┐       │
│  │  Dio instance + Interceptor Chain:                          │       │
│  │    1. RetryInterceptor (exponential backoff for 5xx/timeout)│       │
│  │    2. AuthInterceptor (Bearer token injection)              │       │
│  │    3. TokenRefreshInterceptor (401 → refresh → retry)       │       │
│  │    4. ErrorInterceptor (DioException → AppException)        │       │
│  │    5. LogInterceptor (debug only)                           │       │
│  └──────────────────────────┬──────────────────────────────────┘       │
│                             │ HTTP                                     │
│                             ▼                                          │
│                        [ Backend API ]                                 │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Component Reference

### Core HTTP

| Component | File | Purpose |
|---|---|---|
| **DioClient** | `config/dio_client.dart` | Creates the single configured `Dio` instance with interceptor chain. Injected via `@lazySingleton`. |
| **RetryInterceptor** | `config/interceptors/retry_interceptor.dart` | Exponential backoff retry for transient failures (timeouts, 5xx). Max 3 retries: 1s → 2s → 4s. |
| **AuthInterceptor** | `config/interceptors/auth_interceptor.dart` | Injects `Authorization: Bearer <token>` header. Skips public paths (`/auth/login`, `/auth/register`, `/auth/refresh`). |
| **TokenRefreshInterceptor** | `config/interceptors/token_refresh_interceptor.dart` | On 401: refreshes token, queues concurrent requests, retries them transparently. |
| **ErrorInterceptor** | `config/interceptors/error_interceptor.dart` | Maps `DioException` → `AppException` hierarchy for uniform error handling. |

### Error Handling

| Component | File | Purpose |
|---|---|---|
| **NetworkErrorHandler** | `error_handling/network_error_handler.dart` | `@lazySingleton`. Translates raw errors → `ApiCallFailureModel` with localized messages. Handles Dio errors, HTTP status codes, and custom backend error formats. |
| **ApiCallFailureModel** | `error_handling/models/api_call_failure_model.dart` | Rich error model: HTTP code, translated message, technical message, field name, backend error code, stack trace. |
| **CustomException** | `error_handling/models/custom_exception.dart` | Pre-call and parsing error types (`preCallError`, `parsingError`, `noInternet`). |

### Result Types

| Component | File | Purpose |
|---|---|---|
| **ApiResult\<T\>** | `models/api_result.dart` | Sealed class: `ApiSuccess<T>` or `ApiFailure<T>`. Forces exhaustive error handling via Dart 3 `switch`. |

### Base Repositories

| Component | File | Purpose |
|---|---|---|
| **BaseApiRepository** | `base_api_repository.dart` | Lightweight base for simple CRUD repos. Provides `safeApiCall()` → wraps any API call in try/catch → `ApiResult<T>`. |
| **ScalableBaseRepository** | `repository/scalable_base_repository.dart` | Advanced base with circuit breaker, request batching, stale-while-revalidate caching, concurrent request limiting, performance stats. Use for high-traffic features. Provides `optimizedApiCall()`. |

### Connectivity & Offline

| Component | File | Purpose |
|---|---|---|
| **ConnectivityCubit** | `cubit/connectivity_cubit.dart` | Monitors network state. Emits `ConnectedState` / `DisconnectedState`. Used by `NetworkAwarePage`. |
| **ConnectionManager** | `services/connection_manager.dart` | Centralized connection state management with stream-based monitoring. |
| **MutationQueue** | `queue/mutation_queue.dart` | Queues mutations for offline-first behavior. Persists to disk. Processes when connectivity restores. |
| **AutoSyncService** | `services/auto_sync_service.dart` | Watches connectivity and drains the mutation queue when online. |

### Advanced Patterns

| Component | File | Purpose |
|---|---|---|
| **OptimisticUpdateHandler** | `patterns/optimistic_update_handler.dart` | Optimistic UI: apply change locally → API call → confirm or rollback. Also provides `OptimisticUpdateMixin`. |
| **ParallelApiLoader** | `loaders/parallel_api_loader.dart` | Execute multiple API calls in parallel with priority-based staged loading, cancellation, timeout, and metrics. |
| **BaseBloc** | `bloc/base_bloc.dart` | Optional base BLoC with `handleApiCall()` that auto-manages loading/success/error states. |

### Utilities

| Component | File | Purpose |
|---|---|---|
| **JsonParseUtils** | `utils/json_parse_utils.dart` | Type-safe JSON converters for handling inconsistent backend responses (null → default, String → int, etc.). |
| **DebounceUtils** | `utils/debounce_utils.dart` | Debounce utility for search inputs and rapid-fire API calls. |
| **ScalableCacheManager** | `cache/scalable_cache_manager.dart` | In-memory (L1) cache with **stale-while-revalidate**: each entry has a stale window (`staleAfter`) and a hard `maxAge`. `peek()` reports fresh/stale/miss; warmup, LRU eviction, stats. In-memory only — does **not** survive an app restart (use Drift / the mutation queue for durable storage). |
| **AppImageCacheManager** | `cache/app_image_cache_manager.dart` | Image-specific cache with size limits and eviction. |

### Constants & Enums

| Component | File | Purpose |
|---|---|---|
| **NetworkConstants** | `constants/network_constants.dart` | Timeout values, content types, retry config. |
| **ResponseCode** | `constants/response_code.dart` | HTTP status code constants. |
| **ErrorMessagesKey** | `constants/error_messages_key.dart` | Localization keys for error messages. |
| **CustomErrorType** | `enums/custom_error_type.dart` | Error type enum: `preCallError`, `parsingError`, `noInternet`. |

---

## Complete API Integration Flow: Step-by-Step

When you need to integrate a new API endpoint, follow these steps in order. This walkthrough uses a "Products" feature as an example (`GET /products`).

### Step 1 — Domain Layer: Entity

Create the domain entity. This is **pure Dart** — no dependencies on Flutter, Dio, or any package except `equatable`.

```dart
// lib/features/products/domain/entities/product_entity.dart
import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  const ProductEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
  });

  final String id;
  final String name;
  final double price;
  final String description;

  @override
  List<Object?> get props => [id, name, price, description];
}
```

### Step 2 — Domain Layer: Repository Interface

Define what the feature can do, returning `ApiResult<T>` for every method that hits the network.

```dart
// lib/features/products/domain/repositories/product_repository.dart
import 'package:flutter_specialized_temp/core/network/models/api_result.dart';
import '../entities/product_entity.dart';

abstract class ProductRepository {
  Future<ApiResult<List<ProductEntity>>> getProducts({int page = 1, int limit = 20});
  Future<ApiResult<ProductEntity>> getProductById(String id);
  Future<ApiResult<ProductEntity>> createProduct(Map<String, dynamic> data);
  Future<ApiResult<void>> deleteProduct(String id);
}
```

> **Key:** Return types are always `Future<ApiResult<DomainType>>`, never raw models.

### Step 3 — Domain Layer: Use Case

One use case per action. Annotate with `@injectable`.

```dart
// lib/features/products/domain/usecases/get_products_usecase.dart
import 'package:injectable/injectable.dart';
import 'package:flutter_specialized_temp/core/network/models/api_result.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

@injectable
class GetProductsUseCase {
  final ProductRepository _repository;

  GetProductsUseCase(this._repository);

  Future<ApiResult<List<ProductEntity>>> call({int page = 1, int limit = 20}) {
    return _repository.getProducts(page: page, limit: limit);
  }
}
```

### Step 4 — Data Layer: Model (Freezed + JsonParseUtils)

Models handle serialization. Every `@JsonKey` uses `JsonParseUtils`.

```dart
// lib/features/products/data/models/product_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_specialized_temp/core/network/utils/json_parse_utils.dart';
import '../../domain/entities/product_entity.dart';

part 'product_model.freezed.dart';
part 'product_model.g.dart';

@freezed
abstract class ProductModel with _$ProductModel {
  const factory ProductModel({
    @Default('')
    @JsonKey(name: 'id', fromJson: JsonParseUtils.toStringOrEmpty)
    String id,

    @Default('')
    @JsonKey(name: 'name', fromJson: JsonParseUtils.toStringOrEmpty)
    String name,

    @Default(0.0)
    @JsonKey(name: 'price', fromJson: JsonParseUtils.toDouble)
    double price,

    @Default('')
    @JsonKey(name: 'description', fromJson: JsonParseUtils.toStringOrEmpty)
    String description,
  }) = _ProductModel;

  const ProductModel._();

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  ProductEntity toEntity() => ProductEntity(
        id: id,
        name: name,
        price: price,
        description: description,
      );
}
```

### Step 5 — Data Layer: Remote DataSource

Injects `DioClient` and makes the actual HTTP calls. Returns **models**, not entities.

```dart
// lib/features/products/data/datasources/product_remote_datasource.dart
import 'package:injectable/injectable.dart';
import 'package:flutter_specialized_temp/core/network/config/dio_client.dart';
import '../models/product_model.dart';

@lazySingleton
class ProductRemoteDatasource {
  final DioClient _dioClient;

  ProductRemoteDatasource(this._dioClient);

  Future<List<ProductModel>> getProducts({int page = 1, int limit = 20}) async {
    final response = await _dioClient.client.get(
      '/products',
      queryParameters: {'page': page, 'limit': limit},
    );
    final data = response.data;
    if (data is List) {
      return data
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    final list = data['data'] as List? ?? [];
    return list
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ProductModel> getProductById(String id) async {
    final response = await _dioClient.client.get('/products/$id');
    return ProductModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ProductModel> createProduct(Map<String, dynamic> data) async {
    final response = await _dioClient.client.post('/products', data: data);
    return ProductModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteProduct(String id) async {
    await _dioClient.client.delete('/products/$id');
  }
}
```

> **Important:** Use `_dioClient.client` to access the Dio instance. Let `DioException` propagate — the repository handles error mapping via `safeApiCall`.

### Step 6 — Data Layer: Repository Implementation

Extend `BaseApiRepository` for simple CRUD. Every method wraps its call in `safeApiCall()` which catches errors and returns `ApiResult<T>`.

```dart
// lib/features/products/data/repositories/product_repository_impl.dart
import 'package:injectable/injectable.dart';
import 'package:flutter_specialized_temp/core/network/base_api_repository.dart';
import 'package:flutter_specialized_temp/core/network/models/api_result.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';

@LazySingleton(as: ProductRepository)
class ProductRepositoryImpl extends BaseApiRepository
    implements ProductRepository {
  final ProductRemoteDatasource _remote;

  ProductRepositoryImpl(this._remote, super.errorHandler);

  @override
  Future<ApiResult<List<ProductEntity>>> getProducts({
    int page = 1,
    int limit = 20,
  }) =>
      safeApiCall(
        tag: 'getProducts',
        call: () async {
          final models = await _remote.getProducts(page: page, limit: limit);
          return models.map((m) => m.toEntity()).toList();
        },
      );

  @override
  Future<ApiResult<ProductEntity>> getProductById(String id) =>
      safeApiCall(
        tag: 'getProductById',
        call: () async {
          final model = await _remote.getProductById(id);
          return model.toEntity();
        },
      );

  @override
  Future<ApiResult<ProductEntity>> createProduct(Map<String, dynamic> data) =>
      safeApiCall(
        tag: 'createProduct',
        call: () async {
          final model = await _remote.createProduct(data);
          return model.toEntity();
        },
      );

  @override
  Future<ApiResult<void>> deleteProduct(String id) =>
      safeApiCall(
        tag: 'deleteProduct',
        call: () => _remote.deleteProduct(id),
      );
}
```

### Step 7 — Presentation Layer: BLoC (Exhaustive ApiResult Handling)

The BLoC calls use cases and `switch`es on `ApiResult` exhaustively.

```dart
// lib/features/products/presentation/bloc/products_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_specialized_temp/core/network/models/api_result.dart';
import '../../domain/usecases/get_products_usecase.dart';

part 'products_event.dart';
part 'products_state.dart';

@injectable
class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final GetProductsUseCase _getProducts;

  ProductsBloc(this._getProducts) : super(ProductsInitial()) {
    on<FetchProducts>(_onFetchProducts);
  }

  Future<void> _onFetchProducts(
    FetchProducts event,
    Emitter<ProductsState> emit,
  ) async {
    emit(ProductsLoading());

    final result = await _getProducts(page: event.page);

    // Dart 3 sealed class — MUST handle both branches
    switch (result) {
      case ApiSuccess(:final data):
        emit(ProductsLoaded(products: data));
      case ApiFailure(:final failure):
        emit(ProductsError(failure.translatedMessage));
    }
  }
}
```

### Step 8 — Run Code Generation

After adding all `@injectable` / `@lazySingleton` / `@LazySingleton(as:)` annotations:

```bash
./scripts/codegen.sh
```

This regenerates `lib/core/di/injection.config.dart` so GetIt knows about your new classes.

---

## Error Handling Flow (Detailed)

When an API call fails, the error travels through a defined pipeline:

```
1. Remote DataSource calls _dioClient.client.get('/products')
        │
        ▼ (HTTP error occurs)
2. Dio throws DioException
        │
        ▼
3. RetryInterceptor checks: Is it transient (timeout/5xx)?
   ├── YES → Retry with exponential backoff (1s → 2s → 4s, max 3 retries)
   └── NO  → Pass through
        │
        ▼
4. ErrorInterceptor maps DioException → AppException hierarchy
        │
        ▼
5. Exception propagates up to Repository's safeApiCall()
        │
        ▼
6. safeApiCall() catches the error
   └── Calls NetworkErrorHandler.handleError(error, stackTrace)
        │
        ▼
7. NetworkErrorHandler creates ApiCallFailureModel:
   ├── HTTP status code
   ├── Translated message (localized for the user's language)
   ├── Technical message (for debugging)
   ├── Backend error code (e.g., "VALIDATION_ERROR")
   ├── Field name (for field-level validation errors)
   └── Stack trace
        │
        ▼
8. safeApiCall() returns ApiFailure(failureModel)
        │
        ▼
9. Use Case passes ApiFailure through to BLoC
        │
        ▼
10. BLoC switch(result):
    case ApiFailure(:final failure):
      emit(ErrorState(failure.translatedMessage));
        │
        ▼
11. UI shows localized error message to user
```

### 401 Flow (Token Refresh)

```
1. API returns 401 Unauthorized
        │
        ▼
2. TokenRefreshInterceptor catches the 401
   ├── Locks the refresh mutex (queues other concurrent requests)
   ├── Calls /auth/refresh with the refresh token
   ├── Stores new access token in SecureStorage
   ├── Unlocks mutex, replays all queued requests with new token
   └── If refresh also fails → forces logout
```

---

## Choosing Your Base Repository

| Scenario | Base Class | Method |
|---|---|---|
| Simple CRUD (most features) | `BaseApiRepository` | `safeApiCall()` |
| High-traffic, needs caching | `ScalableBaseRepository` | `optimizedApiCall()` |
| Dashboard loading multiple APIs | Use `ParallelApiLoader` in your BLoC | `loadParallel()` |

### When to Use ScalableBaseRepository

Use `ScalableBaseRepository` + `optimizedApiCall()` when your feature needs:
- **Stale-while-revalidate caching** — instant re-entry with silent background refresh (see below)
- **Circuit breaker** — Stop hammering a failing API (opens after 5 failures, resets after 1 minute)
- **Request batching** — Coalesce identical concurrent requests
- **Concurrent limiting** — Max 10 concurrent requests

```dart
@LazySingleton(as: ProductRepository)
class ProductRepositoryImpl extends ScalableBaseRepository
    implements ProductRepository {
  final ProductRemoteDatasource _remote;

  ProductRepositoryImpl(
    this._remote,
    super.errorHandler,
    super.cacheManager,
  );

  @override
  Future<ApiResult<List<ProductEntity>>> getProducts({
    int page = 1,
    int limit = 20,
    bool refresh = false,
  }) =>
      optimizedApiCall(
        cacheKey: 'products_page_${page}_limit_$limit',
        apiCall: () async {
          final models = await _remote.getProducts(page: page, limit: limit);
          return models.map((m) => m.toEntity()).toList();
        },
        staleTime: const Duration(minutes: 5),   // fresh window
        maxStaleAge: const Duration(hours: 1),    // hard expiry
        bypassCache: refresh,                     // pull-to-refresh forces network
      );
}
```

### Stale-while-revalidate (SWR)

`optimizedApiCall()` implements stale-while-revalidate so screens re-open
instantly and update themselves silently. Each cached entry has two phases:

| Phase | Window | Behavior on read |
|---|---|---|
| **Fresh** | `now < staleTime` | Return cached value. **No network call.** |
| **Stale** | `staleTime ≤ now < maxStaleAge` | Return cached value **immediately**, then fire a **background refresh** that updates the cache for the next read. The user never waits or sees a spinner. |
| **Expired** | `now ≥ maxStaleAge` | Cache miss — fetch and wait (shows loading). |

Concretely, with `staleTime: 5min`: revisit the screen within 5 minutes and it
serves the cached data with zero network. After 5 minutes the next visit still
paints instantly from cache *and* kicks off a silent refresh in the background,
so the data is up to date by the next frame without a loading state. Only after
`maxStaleAge` (default 1 hour) does a visit block on the network again.

Parameters:
- `staleTime` (alias: `cacheTTL`) — how long data stays fresh. Default 5 min.
- `maxStaleAge` — hard expiry past which stale data is no longer served. Default 1 hour. Clamped up to at least `staleTime`.
- `bypassCache: true` — skip the cache entirely and fetch (use for pull-to-refresh).

Background revalidation is deduplicated (one in-flight refresh per `cacheKey`)
and best-effort: if it fails the user keeps the served stale value and the
failure is logged, never thrown.

> **Scope:** the cache is **in-memory only** — it does not survive an app
> restart. SWR optimizes in-session navigation. For data that must be readable
> offline after a cold start, persist it with Drift or queue writes through the
> `MutationQueue`.

---

## Advanced Patterns

### Offline-First with Mutation Queue

For features that need to work offline, queue mutations and sync when connectivity restores:

```dart
@LazySingleton(as: ProductRepository)
class ProductRepositoryImpl extends BaseApiRepository
    implements ProductRepository {
  final ProductRemoteDatasource _remote;
  final ProductLocalDatasource _local;
  final MutationQueue _mutationQueue;
  final ConnectivityCubit _connectivity;

  ProductRepositoryImpl(
    this._remote,
    this._local,
    this._mutationQueue,
    this._connectivity,
    super.errorHandler,
  );

  @override
  Future<ApiResult<ProductEntity>> createProduct(Map<String, dynamic> data) async {
    if (!_connectivity.isConnected) {
      // Offline: queue for later sync
      await _mutationQueue.enqueueMutation(
        type: 'create',
        entity: 'product',
        data: data,
      );
      // Return optimistic local result
      final localModel = ProductModel.fromJson(data);
      await _local.cacheProduct(localModel);
      return ApiSuccess(localModel.toEntity());
    }

    // Online: hit the API directly
    return safeApiCall(
      tag: 'createProduct',
      call: () async {
        final model = await _remote.createProduct(data);
        await _local.cacheProduct(model);
        return model.toEntity();
      },
    );
  }
}
```

### Optimistic Updates

Apply changes to UI immediately, rollback on failure:

```dart
// In BLoC:
Future<void> _onDeleteProduct(
  DeleteProduct event,
  Emitter<ProductsState> emit,
) async {
  final result = await OptimisticUpdateHandler.execute<void>(
    optimisticUpdate: () async {
      // Remove from UI immediately
      final current = state as ProductsLoaded;
      final updated = current.products.where((p) => p.id != event.id).toList();
      emit(ProductsLoaded(products: updated));
    },
    apiCall: () => _deleteProduct(event.id),
    onSuccess: (_) async {
      // Already removed from UI — nothing more needed
    },
    onFailure: (error) async {
      // Show error snackbar
    },
    rollback: () async {
      // Restore the previous state
      emit(state); // Re-emit the previous loaded state
    },
  );
}
```

### Parallel Loading (Dashboard Screens)

Load multiple APIs simultaneously for screens that need data from several endpoints:

```dart
@injectable
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetProductsUseCase _getProducts;
  final GetCategoriesUseCase _getCategories;
  final GetStatsUseCase _getStats;
  final ParallelApiLoader _parallelLoader;

  DashboardBloc(
    this._getProducts,
    this._getCategories,
    this._getStats,
    this._parallelLoader,
  ) : super(DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
  }

  Future<void> _onLoadDashboard(
    LoadDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());

    final result = await _parallelLoader.loadParallel(
      loaderKey: 'dashboard',
      loaders: {
        'products': LoaderConfig(
          loader: () => _getProducts(),
          priority: LoaderPriority.high,
        ),
        'categories': LoaderConfig(
          loader: () => _getCategories(),
          priority: LoaderPriority.normal,
        ),
        'stats': LoaderConfig(
          loader: () => _getStats(),
          priority: LoaderPriority.critical,
          timeout: const Duration(seconds: 10),
        ),
      },
    );

    if (result.isCompleteSuccess) {
      emit(DashboardLoaded(
        products: result.getData<List<ProductEntity>>('products') ?? [],
        categories: result.getData<List<CategoryEntity>>('categories') ?? [],
        stats: result.getData<StatsEntity>('stats'),
      ));
    } else if (result.isPartialSuccess) {
      // Show what loaded, error what failed
      emit(DashboardPartial(
        products: result.getData<List<ProductEntity>>('products'),
        error: result.getError('stats'),
      ));
    } else {
      emit(DashboardError('Failed to load dashboard'));
    }
  }
}
```

### Using BaseBloc for Simplified Error Handling

For simpler BLoCs, extend `BaseBloc` which auto-manages loading/success/error:

```dart
@injectable
class ProductDetailBloc extends BaseBloc<ProductDetailEvent, ProductDetailState> {
  final GetProductByIdUseCase _getProduct;

  ProductDetailBloc(this._getProduct) : super(ProductDetailState.initial());

  Future<void> _onLoadProduct(
    LoadProduct event,
    Emitter<ProductDetailState> emit,
  ) async {
    await handleApiCall<ProductEntity>(
      apiCall: () => _getProduct(event.id),
      onSuccess: (product) {
        emit(state.copyWith(isLoading: false, product: product));
      },
      emit: emit,
    );
  }
}
```

---

## Connectivity Monitoring

### NetworkAwarePage

Wrap any page to show an offline banner automatically:

```dart
NetworkAwarePage(
  child: Scaffold(
    body: YourContent(),
  ),
)
```

### React to Connectivity in BLoC

```dart
// Listen to connectivity changes
context.read<ConnectivityCubit>().stream.listen((state) {
  if (state is ConnectedState) {
    // Re-fetch data when back online
    context.read<ProductsBloc>().add(FetchProducts());
  }
});
```

---

## Request Flow Summary

```
┌─────────────────────────────────────────────────────────────┐
│  1. BLoC dispatches event                                   │
│  2. BLoC calls UseCase                                      │
│  3. UseCase calls Repository interface method               │
│  4. RepositoryImpl.safeApiCall() wraps the call              │
│  5. Inside safeApiCall: calls DataSource method              │
│  6. DataSource uses _dioClient.client.get/post/etc           │
│  7. DioClient's interceptor chain processes the request:     │
│     a. RetryInterceptor → retry on transient errors          │
│     b. AuthInterceptor → inject Bearer token                 │
│     c. TokenRefreshInterceptor → handle 401 + refresh        │
│     d. ErrorInterceptor → map DioException → AppException    │
│     e. LogInterceptor → log request/response (debug only)    │
│  8. Response returns through the chain                       │
│  9. DataSource parses response → returns Model               │
│  10. RepositoryImpl converts Model → Entity via toEntity()   │
│  11. safeApiCall wraps result in ApiSuccess<Entity>           │
│      OR catches error → NetworkErrorHandler → ApiFailure     │
│  12. UseCase passes ApiResult<Entity> to BLoC                │
│  13. BLoC switch(result) → emits appropriate state           │
│  14. UI rebuilds based on new state                          │
└─────────────────────────────────────────────────────────────┘
```

---

## Quick Reference: What NOT To Do

| ❌ Wrong | ✅ Correct |
|---|---|
| `import 'package:dio/dio.dart'` in a BLoC | BLoC only imports use cases and `ApiResult` |
| `Dio().get('/api/items')` | `_dioClient.client.get('/items')` via injected `DioClient` |
| `try/catch DioException` in a BLoC | `switch(result)` on `ApiResult` in BLoC; error handling is the repository's job |
| `http.get(Uri.parse(...))` | All HTTP goes through `DioClient` and the interceptor chain |
| Returning raw `Response` from repository | Return `ApiResult<Entity>` from repository |
| Parsing JSON without `JsonParseUtils` | Every `@JsonKey` uses a `JsonParseUtils` converter |
| Handling errors as `String` messages | Use `ApiCallFailureModel` with translated messages |
| Skipping `safeApiCall()` in repository | Every repository method uses `safeApiCall()` or `optimizedApiCall()` |

---

## File Tree Reference

```
lib/core/network/
├── base_api_repository.dart            # Simple CRUD base (safeApiCall)
├── bloc/
│   ├── base_bloc.dart                  # Optional base BLoC with handleApiCall
│   └── base_bloc_state.dart            # Base state for BaseBloc
├── cache/
│   ├── app_image_cache_manager.dart     # Image-specific cache
│   └── scalable_cache_manager.dart      # In-memory cache w/ stale-while-revalidate
├── config/
│   ├── dio_client.dart                  # Dio instance + interceptor chain
│   └── interceptors/
│       ├── auth_interceptor.dart        # Bearer token injection
│       ├── error_interceptor.dart       # DioException → AppException
│       ├── retry_interceptor.dart       # Exponential backoff retry
│       └── token_refresh_interceptor.dart # 401 → refresh → retry
├── constants/
│   ├── error_messages_key.dart          # Localization keys for errors
│   ├── network_constants.dart           # Timeouts, content types
│   └── response_code.dart              # HTTP status code constants
├── cubit/
│   └── connectivity_cubit.dart          # Online/offline state management
├── enums/
│   └── custom_error_type.dart           # preCallError, parsingError, noInternet
├── error_handling/
│   ├── models/
│   │   ├── api_call_failure_model.dart   # Rich error model
│   │   └── custom_exception.dart        # Custom exception types
│   └── network_error_handler.dart       # Error → ApiCallFailureModel
├── loaders/
│   └── parallel_api_loader.dart         # Parallel API execution
├── models/
│   └── api_result.dart                  # Sealed class: ApiSuccess | ApiFailure
├── patterns/
│   └── optimistic_update_handler.dart   # Optimistic UI pattern
├── queue/
│   └── mutation_queue.dart              # Offline mutation queue
├── repository/
│   └── scalable_base_repository.dart    # Advanced base (circuit breaker, cache)
├── services/
│   ├── auto_sync_service.dart           # Auto-sync on connectivity restore
│   ├── connection_manager.dart          # Connection state management
│   └── localization_service/
│       ├── global_localization_service.dart
│       └── localization_service.dart
└── utils/
    ├── debounce_utils.dart              # Debounce for search/rapid calls
    └── json_parse_utils.dart            # Type-safe JSON converters
```
