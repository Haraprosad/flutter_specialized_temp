# Guide 3 — Feature Implementation Guide

The definitive guide for implementing a production-ready feature in this template. Covers every layer, pattern, and edge case.

---

## Table of Contents

1. [Scaffold a Feature](#1-scaffold-a-feature)
2. [Domain Layer](#2-domain-layer)
3. [Data Layer — Models](#3-data-layer--models)
4. [Data Layer — DataSources](#4-data-layer--datasources)
5. [Data Layer — Repository Implementation](#5-data-layer--repository-implementation)
6. [Dependency Injection Registration](#6-dependency-injection-registration)
7. [Presentation Layer — BLoC](#7-presentation-layer--bloc)
8. [Presentation Layer — Pages](#8-presentation-layer--pages)
9. [Routing](#9-routing)
10. [Design System Integration](#10-design-system-integration)
11. [API Integration Patterns](#11-api-integration-patterns)
12. [Testing the Feature](#12-testing-the-feature)
13. [Complete Checklist](#13-complete-checklist)

---

## 1. Scaffold a Feature

Use the included Mason brick to generate the full layer structure:

```bash
mason make feature
# Prompts: name (snake_case, e.g. "orders"), package_name
```

This creates:

```
lib/features/orders/
├── data/
│   ├── datasources/orders_remote_datasource.dart
│   ├── models/orders_model.dart
│   └── repositories/orders_repository_impl.dart
├── domain/
│   ├── entities/orders_entity.dart
│   ├── repositories/orders_repository.dart
│   └── usecases/get_orderss.dart
└── presentation/
    ├── bloc/orders_bloc.dart
    ├── bloc/orders_event.dart
    ├── bloc/orders_state.dart
    └── pages/orders_screen.dart
```

Or create manually following the same structure.

---

## 2. Domain Layer

The domain layer is **pure Dart** — no Flutter, no Dio, no external packages except `equatable` and `dartz` (optional). This is your business logic.

### Entity

```dart
// lib/features/orders/domain/entities/order_entity.dart
import 'package:equatable/equatable.dart';

class OrderEntity extends Equatable {
  final String id;
  final String customerName;
  final double totalAmount;
  final String status;
  final DateTime createdAt;

  const OrderEntity({
    required this.id,
    required this.customerName,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, customerName, totalAmount, status, createdAt];
}
```

**Rules:**
- Always extend `Equatable` for value comparison (critical for BLoC state rebuilds)
- Include all fields in `props` — if you forget one, the UI won't rebuild when it changes
- No JSON parsing or API concerns here

### Repository Interface

```dart
// lib/features/orders/domain/repositories/order_repository.dart
import '../entities/order_entity.dart';

abstract class OrderRepository {
  Future<List<OrderEntity>> getOrders({int page = 1, int limit = 20});
  Future<OrderEntity> getOrderById(String id);
  Future<OrderEntity> createOrder(Map<String, dynamic> data);
  Future<void> deleteOrder(String id);
}
```

**Rules:**
- Define only methods this feature needs (Interface Segregation)
- Return domain types (`OrderEntity`), never models (`OrderModel`)
- Throw `AppException` subtypes for error cases

### Use Case

```dart
// lib/features/orders/domain/usecases/get_orders_usecase.dart
import 'package:injectable/injectable.dart';
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

@injectable
class GetOrdersUseCase {
  final OrderRepository _repository;

  GetOrdersUseCase(this._repository);

  Future<List<OrderEntity>> call({int page = 1, int limit = 20}) {
    return _repository.getOrders(page: page, limit: limit);
  }
}
```

**Rules:**
- Annotate with `@injectable` (factory — new instance each time)
- One public `call()` method per use case (Single Responsibility)
- Accept parameters via `call()` arguments, not constructor
- Keep business logic here, not in the BLoC

---

## 3. Data Layer — Models

Models handle JSON serialization and the messy reality of backend responses. This is where `JsonParseUtils` protects you from crashes.

### Battle-Proof Model Pattern

```dart
// lib/features/orders/data/models/order_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_specialized_temp/core/network/utils/json_parse_utils.dart';
import '../../domain/entities/order_entity.dart';

part 'order_model.freezed.dart';
part 'order_model.g.dart';

@freezed
abstract class OrderModel with _$OrderModel {
  const factory OrderModel({
    // --- Every field uses JsonParseUtils for type safety ---
    // Backend might send null, wrong type, or missing key.
    // JsonParseUtils converts safely to a sensible default.

    @Default('')
    @JsonKey(name: 'id', fromJson: JsonParseUtils.toStringOrEmpty)
    String id,

    @Default('')
    @JsonKey(name: 'customer_name', fromJson: JsonParseUtils.toStringOrEmpty)
    String customerName,

    // Backend might send amount as String "99.99" or int 99 or null
    @Default(0.0)
    @JsonKey(name: 'total_amount', fromJson: JsonParseUtils.toDouble)
    double totalAmount,

    @Default('')
    @JsonKey(name: 'status', fromJson: JsonParseUtils.toStringOrEmpty)
    String status,

    // Backend might send ISO string, Unix timestamp, or null
    @JsonKey(name: 'created_at', fromJson: JsonParseUtils.toDateTime)
    DateTime? createdAt,

    // Backend might send bool as 0/1, "true"/"false", or null
    @Default(false)
    @JsonKey(name: 'is_paid', fromJson: JsonParseUtils.toBool)
    bool isPaid,

    // Nested object might be null or malformed
    @JsonKey(name: 'metadata')
    Map<String, dynamic>? metadata,

    // List of strings — backend might send null, mixed types, or missing
    @Default([])
    @JsonKey(name: 'tags', fromJson: JsonParseUtils.toStringList)
    List<String> tags,

    // Enum field with fallback — backend sends unexpected value? No crash.
    @Default(OrderStatus.pending)
    @JsonKey(name: 'order_status', fromJson: _orderStatusFromJson)
    OrderStatus orderStatus,

    // Nullable int — sometimes the field exists but is null
    @JsonKey(name: 'discount_percent', fromJson: JsonParseUtils.toIntOrNull)
    int? discountPercent,
  }) = _OrderModel;

  const OrderModel._();

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  // Convert to domain entity — this is the ONLY type that crosses
  // the domain/data boundary
  OrderEntity toEntity() => OrderEntity(
        id: id,
        customerName: customerName,
        totalAmount: totalAmount,
        status: orderStatus.name,
        createdAt: createdAt ?? DateTime.now(),
      );
}

enum OrderStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('processing')
  processing,
  @JsonValue('shipped')
  shipped,
  @JsonValue('delivered')
  delivered,
  @JsonValue('cancelled')
  cancelled;
}

OrderStatus _orderStatusFromJson(dynamic value) {
  return JsonParseUtils.toEnum(value, OrderStatus.values, OrderStatus.pending);
}
```

### JsonParseUtils — When to Use Each Converter

| Backend Sends | Field Type | Converter | Default |
|---|---|---|---|
| `null`, missing key | `String` | `toStringOrEmpty` | `''` |
| `null`, missing key | `int` | `toInt` | `0` |
| `null`, missing key | `double` | `toDouble` | `0.0` |
| `null`, missing key | `bool` | `toBool` | `false` |
| `null`, missing key | `int?` | `toIntOrNull` | `null` |
| `null`, missing key | `double?` | `toDoubleOrNull` | `null` |
| `null`, missing key | `String?` | `toStringOrNull` | `null` |
| `null`, missing key | `DateTime?` | `toDateTime` | `null` |
| `"42"` when you expect `int` | `int` | `toInt` | `42` |
| `42` when you expect `double` | `double` | `toDouble` | `42.0` |
| `1` / `"yes"` / `"true"` | `bool` | `toBool` | `true` |
| `"2024-01-15"` or `1705276800` | `DateTime?` | `toDateTime` | parsed |
| Unknown enum value | `enum` | `toEnum` | fallback |
| `null` or mixed array | `List<String>` | `toStringList` | `[]` |
| `null` or mixed array | `List<int>` | `toIntList` | `[]` |
| Nested JSON object | `T?` | `toObject(fromJson)` | `null` |
| Nested JSON array | `List<T>` | `toList(fromJson)` | `[]` |

**Rules:**
- Every `@JsonKey` must have a `fromJson` using `JsonParseUtils` — never trust the backend type
- Every field must have a `@Default` value (for non-nullable types)
- Always specify `name:` in `@JsonKey` to decouple from Dart naming
- Add `toEntity()` in a private constructor — converts model → domain
- Keep `part` directives for both `.freezed.dart` and `.g.dart`

---

## 4. Data Layer — DataSources

### Remote DataSource

```dart
// lib/features/orders/data/datasources/orders_remote_datasource.dart
import 'package:injectable/injectable.dart';
import '../models/order_model.dart';

@lazySingleton
class OrdersRemoteDatasource {
  final DioClient _dioClient;

  OrdersRemoteDatasource(this._dioClient);

  Future<List<OrderModel>> getOrders({int page = 1, int limit = 20}) async {
    final response = await _dioClient.get(
      '/orders',
      queryParameters: {'page': page, 'limit': limit},
    );
    // Handle both list and wrapped responses:
    // {"data": [...]} or directly [...]
    final data = response.data;
    if (data is List) {
      return data.map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    final list = data['data'] as List? ?? [];
    return list.map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<OrderModel> getOrderById(String id) async {
    final response = await _dioClient.get('/orders/$id');
    return OrderModel.fromJson(response.data);
  }

  Future<OrderModel> createOrder(Map<String, dynamic> data) async {
    final response = await _dioClient.post('/orders', data: data);
    return OrderModel.fromJson(response.data);
  }

  Future<void> deleteOrder(String id) async {
    await _dioClient.delete('/orders/$id');
  }
}
```

### Local DataSource (if offline-first)

```dart
// lib/features/orders/data/datasources/orders_local_datasource.dart
@lazySingleton
class OrdersLocalDatasource {
  final AppDatabase _db;

  OrdersLocalDatasource(this._db);

  Future<List<OrderModel>> getCachedOrders() async { /* ... */ }
  Future<void> cacheOrders(List<OrderModel> orders) async { /* ... */ }
  Future<void> clearCache() async { /* ... */ }
}
```

**Rules:**
- Annotate with `@lazySingleton` — one instance, created on first use
- Return models, never entities (conversion happens in the repository)
- Handle multiple response formats gracefully (list vs. wrapped)
- Let `DioException` propagate — the repository handles error mapping

---

## 5. Data Layer — Repository Implementation

### Simple CRUD — Use `BaseApiRepository`

```dart
// lib/features/orders/data/repositories/orders_repository_impl.dart
import 'package:injectable/injectable.dart';
import 'package:flutter_specialized_temp/core/network/base_api_repository.dart';
import 'package:flutter_specialized_temp/core/network/models/api_result.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/orders_remote_datasource.dart';

@LazySingleton(as: OrderRepository)
class OrdersRepositoryImpl extends BaseApiRepository implements OrderRepository {
  final OrdersRemoteDatasource _remote;

  OrdersRepositoryImpl(this._remote, super.errorHandler);

  @override
  Future<ApiResult<List<OrderEntity>>> getOrders({
    int page = 1,
    int limit = 20,
  }) =>
      safeApiCall(
        tag: 'getOrders',
        call: () async {
          final models = await _remote.getOrders(page: page, limit: limit);
          return models.map((m) => m.toEntity()).toList();
        },
      );

  @override
  Future<ApiResult<OrderEntity>> getOrderById(String id) =>
      safeApiCall(
        tag: 'getOrderById',
        call: () async {
          final model = await _remote.getOrderById(id);
          return model.toEntity();
        },
      );

  @override
  Future<ApiResult<OrderEntity>> createOrder(Map<String, dynamic> data) =>
      safeApiCall(
        tag: 'createOrder',
        call: () async {
          final model = await _remote.createOrder(data);
          return model.toEntity();
        },
      );

  @override
  Future<ApiResult<void>> deleteOrder(String id) =>
      safeApiCall(
        tag: 'deleteOrder',
        call: () => _remote.deleteOrder(id),
      );
}
```

### High-Traffic Feature — Use `ScalableBaseRepository`

For features that need caching, circuit breaking, or request batching:

```dart
@LazySingleton(as: OrderRepository)
class OrdersRepositoryImpl extends ScalableBaseRepository implements OrderRepository {
  final OrdersRemoteDatasource _remote;
  final OrdersLocalDatasource _local;

  OrdersRepositoryImpl(this._remote, this._local, super.errorHandler, super.cacheManager);

  @override
  Future<ApiResult<List<OrderEntity>>> getOrders({int page = 1, int limit = 20}) =>
      optimizedApiCall(
        cacheKey: 'orders_page_${page}_limit_$limit',
        apiCall: () async {
          final models = await _remote.getOrders(page: page, limit: limit);
          await _local.cacheOrders(models);
          return models.map((m) => m.toEntity()).toList();
        },
        cacheTTL: const Duration(minutes: 5),
      );
}
```

### Using `ApiResult` in BLoCs

```dart
// The sealed ApiResult forces you to handle both cases:
final result = await _getOrders();
switch (result) {
  case ApiSuccess(:final data):
    emit(OrdersLoaded(data));
  case ApiFailure(:final failure):
    emit(OrdersError(failure.translatedMessage));
}
```

---

## 6. Dependency Injection Registration

After adding `@injectable` / `@lazySingleton` / `@LazySingleton(as:)` annotations:

```bash
./scripts/codegen.sh
```

This regenerates `lib/core/di/injection.config.dart`.

### Annotation Reference

| Annotation | Scope | Use For |
|---|---|---|
| `@injectable` | Factory (new instance each time) | Use cases, BLoCs |
| `@singleton` | Eager singleton (created at startup) | Rarely needed — expensive one-time init |
| `@lazySingleton` | Lazy singleton (created on first use) | DataSources, Repositories, Services |
| `@LazySingleton(as: Interface)` | Register as interface type | Repository implementations |

### Constructor Injection — The Only Pattern

```dart
// ✅ CORRECT — constructor injection
@injectable
class GetOrdersUseCase {
  final OrderRepository _repo;
  GetOrdersUseCase(this._repo); // Injectable provides this automatically
}

// ❌ WRONG — service locator anti-pattern
@injectable
class GetOrdersUseCase {
  final _repo = sl<OrderRepository>(); // Hidden dependency, untestable
}
```

### Manual Registration (RegisterModule)

For third-party types that can't use annotations:

```dart
// lib/core/di/register_module.dart
@module
abstract class RegisterModule {
  @lazySingleton
  DioClient dioClient(AppConfig config) => DioClient(config);

  @lazySingleton
  AppDatabase appDatabase() => AppDatabase();
}
```

---

## 7. Presentation Layer — BLoC

### Events

```dart
// lib/features/orders/presentation/bloc/orders_event.dart
part of 'orders_bloc.dart';

abstract class OrdersEvent with EquatableMixin {
  @override
  List<Object?> get props => [];
}

class FetchOrders extends OrdersEvent {
  final int page;
  final bool refresh;

  FetchOrders({this.page = 1, this.refresh = false});

  @override
  List<Object?> get props => [page, refresh];
}

class RefreshOrders extends OrdersEvent {}

class DeleteOrder extends OrdersEvent {
  final String orderId;

  DeleteOrder(this.orderId);

  @override
  List<Object?> get props => [orderId];
}
```

### States

```dart
// lib/features/orders/presentation/bloc/orders_state.dart
part of 'orders_bloc.dart';

abstract class OrdersState with EquatableMixin {
  @override
  List<Object?> get props => [];
}

class OrdersInitial extends OrdersState {}

class OrdersLoading extends OrdersState {}

class OrdersLoaded extends OrdersState {
  final List<OrderEntity> orders;
  final bool hasMore;
  final int currentPage;

  OrdersLoaded({
    required this.orders,
    this.hasMore = true,
    this.currentPage = 1,
  });

  @override
  List<Object?> get props => [orders, hasMore, currentPage];
}

class OrdersError extends OrdersState {
  final String message;

  OrdersError(this.message);

  @override
  List<Object?> get props => [message];
}
```

### BLoC

```dart
// lib/features/orders/presentation/bloc/orders_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_specialized_temp/core/network/models/api_result.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/usecases/get_orders_usecase.dart';

part 'orders_event.dart';
part 'orders_state.dart';

@injectable
class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final GetOrdersUseCase _getOrders;

  OrdersBloc(this._getOrders) : super(OrdersInitial()) {
    on<FetchOrders>(_onFetchOrders);
    on<RefreshOrders>(_onRefreshOrders);
    on<DeleteOrder>(_onDeleteOrder);
  }

  Future<void> _onFetchOrders(
    FetchOrders event,
    Emitter<OrdersState> emit,
  ) async {
    // Don't show loading spinner when loading more pages
    if (event.page == 1) {
      emit(OrdersLoading());
    }

    final result = await _getOrders(page: event.page);

    switch (result) {
      case ApiSuccess(:final data):
        final currentOrders = state is OrdersLoaded && !event.refresh
            ? (state as OrdersLoaded).orders
            : <OrderEntity>[];
        emit(OrdersLoaded(
          orders: [...currentOrders, ...data],
          hasMore: data.length >= 20,
          currentPage: event.page,
        ));

      case ApiFailure(:final failure):
        emit(OrdersError(failure.translatedMessage));
    }
  }

  Future<void> _onRefreshOrders(
    RefreshOrders event,
    Emitter<OrdersState> emit,
  ) async {
    final result = await _getOrders(page: 1);

    switch (result) {
      case ApiSuccess(:final data):
        emit(OrdersLoaded(orders: data, hasMore: data.length >= 20));
      case ApiFailure(:final failure):
        emit(OrdersError(failure.translatedMessage));
    }
  }

  Future<void> _onDeleteOrder(
    DeleteOrder event,
    Emitter<OrdersState> emit,
  ) async {
    // Optimistic update — remove from UI immediately
    if (state is OrdersLoaded) {
      final current = state as OrdersLoaded;
      final updated = current.orders.where((o) => o.id != event.orderId).toList();
      emit(OrdersLoaded(
        orders: updated,
        hasMore: current.hasMore,
        currentPage: current.currentPage,
      ));
    }
    // The use case handles the API call; if it fails, the UI will
    // refresh on the next FetchOrders event
  }
}
```

**BLoC Rules:**
- Annotate with `@injectable`
- Depend on use cases only, never repositories directly
- Use `switch` on `ApiResult` — Dart forces exhaustive handling
- Catch `AppException` types only, never raw `DioException`
- Keep the BLoC thin — business logic belongs in use cases
- Always use `EquatableMixin` on events and states for rebuild optimization

---

## 8. Presentation Layer — Pages

```dart
// lib/features/orders/presentation/pages/orders_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_specialized_temp/core/design_management_system/design_management_system.dart';
import '../bloc/orders_bloc.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<OrdersBloc>()..add(FetchOrders()),
      child: const OrdersView(),
    );
  }
}

class OrdersView extends StatelessWidget {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: BlocConsumer<OrdersBloc, OrdersState>(
        listener: (context, state) {
          // Side effects: snackbar, navigation, dialog
          if (state is OrdersError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return switch (state) {
            OrdersInitial() || OrdersLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            OrdersLoaded(:final orders) => orders.isEmpty
                ? Center(
                    child: Text(
                      'No orders yet',
                      style: context.textTheme.bodyLarge,
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      context.read<OrdersBloc>().add(RefreshOrders());
                    },
                    child: ListView.builder(
                      itemCount: orders.length,
                      itemBuilder: (context, index) => _OrderCard(
                        order: orders[index],
                      ),
                    ),
                  ),
            OrdersError(:final message) => ErrorWidgetWithAction(
                message: message,
                onRetry: () =>
                    context.read<OrdersBloc>().add(FetchOrders()),
              ),
          };
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderEntity order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: AppSpacing.smPadding,
      child: ListTile(
        title: Text(
          order.customerName,
          style: context.textTheme.titleMedium,
        ),
        subtitle: Text(
          '\$${order.totalAmount.toStringAsFixed(2)}',
          style: context.textTheme.bodyMedium,
        ),
        trailing: Chip(label: Text(order.status)),
      ),
    );
  }
}
```

**Page Rules:**
- `BlocProvider` goes at the page level (stateful widget that creates the BLoC)
- Use `BlocConsumer` when you need both builder + listener
- Use `BlocBuilder` when you only need rebuilds
- Use `BlocListener` when you only need side effects (navigation, snackbar)
- Use Dart 3 switch expressions on state for exhaustive handling
- Use design system tokens for all spacing, colors, typography
- Handle every state: loading, loaded (empty + populated), error

---

## 9. Routing

### Add Route Definition

```dart
// lib/core/router/app_routes.dart
// Add your feature's routes:

GoRoute(
  path: RoutePaths.orders,
  name: RouteNames.orders,
  builder: (context, state) => const OrdersScreen(),
  routes: [
    GoRoute(
      path: 'detail/:id',
      name: RouteNames.orderDetail,
      builder: (context, state) {
        final orderId = state.pathParameters['id']!;
        return OrderDetailScreen(orderId: orderId);
      },
    ),
  ],
),
```

### Add Route Constants

```dart
// lib/core/router/route_paths.dart
static const orders = '/orders';

// lib/core/router/route_names.dart
static const orders = 'orders';
static const orderDetail = 'order-detail';
```

### Navigate to Feature

```dart
// From anywhere in the app:
context.goNamed(RouteNames.orders);
context.go('${RoutePaths.orders}/detail/123');

// Or with go:
context.go(RoutePaths.orders);
```

---

## 10. Design System Integration

### Single Import

```dart
import 'package:flutter_specialized_temp/core/design_management_system/design_management_system.dart';
```

This gives you access to all tokens and extensions.

### Responsive Spacing

```dart
Padding(
  padding: AppSpacing.mdPadding,        // EdgeInsets.all(medium)
  // Or specific sides:
  padding: AppSpacing.smHorizontal,     // EdgeInsets.symmetric(horizontal: small)
  child: ...,
)
```

### Responsive Dimensions

```dart
SizedBox(
  height: AppDimensions.buttonLarge,    // Standard button height
  width: AppDimensions.buttonLarge,
  child: ElevatedButton(...),
)

Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
  ),
)
```

### Context Extensions

```dart
// Colors
Container(color: context.colors.primary);
Container(color: context.colorScheme.surface);

// Typography
Text('Hello', style: context.textTheme.headlineMedium);
Text('Subtitle', style: context.textTheme.bodyLarge);

// Screen info
final width = context.screenWidth;
final height = context.screenHeight;
final isDark = context.isDarkMode;
final isTablet = context.isTablet;
```

### Adaptive Layout

```dart
// Different layouts for phone vs tablet
LayoutBuilder(
  builder: (context, constraints) {
    if (context.isTablet) {
      return _TabletLayout(orders: orders);
    }
    return _MobileLayout(orders: orders);
  },
)
```

See [Design System Guide](04_DESIGN_SYSTEM.md) for the complete token reference.

---

## 11. API Integration Patterns

### Public vs Authenticated Endpoints

The `AuthInterceptor` skips these public paths:
- `/auth/login`
- `/auth/register`
- `/auth/refresh`

All other endpoints get the `Authorization: Bearer <token>` header automatically.

### Error Handling Flow

```
API Call
  → DioException
    → ErrorInterceptor maps to AppException
      → NetworkErrorHandler creates ApiCallFailureModel
        → BLoC receives ApiFailure
          → UI shows localized error message
```

### Offline-First Pattern

```dart
@override
Future<ApiResult<List<OrderEntity>>> getOrders() async {
  // Try cache first
  final cached = await _local.getCachedOrders();
  if (cached.isNotEmpty) {
    // Return cached data immediately, refresh in background
    return ApiSuccess(cached.map((m) => m.toEntity()).toList());
  }
  // No cache — hit the network
  return safeApiCall(
    call: () async {
      final models = await _remote.getOrders();
      await _local.cacheOrders(models);
      return models.map((m) => m.toEntity()).toList();
    },
  );
}
```

### Optimistic Update Pattern

```dart
// In BLoC:
Future<void> _onDeleteOrder(DeleteOrder event, Emitter<OrdersState> emit) async {
  // 1. Update UI immediately
  final current = state as OrdersLoaded;
  emit(OrdersLoaded(orders: current.orders.where((o) => o.id != event.orderId).toList()));

  // 2. Call API
  final result = await _deleteOrder(event.orderId);

  // 3. On failure, rollback
  if (result is ApiFailure) {
    emit(current); // Restore previous state
    emit(OrdersError(result.failure.translatedMessage));
  }
}
```

---

## 12. Testing the Feature

See [Testing Guide](05_TESTING.md) for the complete strategy. Key tests per feature:

### Model Test — Edge Cases

```dart
// test/features/orders/data/models/order_model_test.dart
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OrderModel behavior scenarios', () {
    group('Given missing fields in JSON', () {
      test('When parsing, Then defaults are applied without crashing', () {
        final json = {'id': '123'}; // Missing most fields
        final model = OrderModel.fromJson(json);
        expect(model.customerName, '');       // Default from JsonParseUtils
        expect(model.totalAmount, 0.0);       // Default
        expect(model.createdAt, isNull);      // Nullable
        expect(model.tags, isEmpty);          // Empty list
      });
    });

    group('Given wrong types in JSON', () {
      test('When parsing, Then JsonParseUtils converts safely', () {
        final json = {
          'id': 123,                           // int instead of String
          'total_amount': '99.99',             // String instead of double
          'is_paid': 1,                        // int instead of bool
          'tags': ['food', null, 42, 'drink'], // Mixed types in list
        };
        final model = OrderModel.fromJson(json);
        expect(model.id, '123');              // toStringOrEmpty
        expect(model.totalAmount, 99.99);     // toDouble
        expect(model.isPaid, true);           // toBool(1) = true
        expect(model.tags, ['food', '42', 'drink']); // toStringList filters nulls
      });
    });

    group('Given an empty JSON response body', () {
      test('When parsing, Then all defaults are applied', () {
        final json = <String, dynamic>{};
        final model = OrderModel.fromJson(json);
        expect(model.id, '');
        expect(model.status, 'pending');
      });
    });

    group('Given a fully constructed model', () {
      test('When round-tripping through JSON, Then equality holds', () {
        final original = OrderModel(id: '1', customerName: 'John', totalAmount: 50.0);
        final json = original.toJson();
        final restored = OrderModel.fromJson(json);
        expect(restored, equals(original));
      });
    });

    group('Given a model with all fields populated', () {
      test('When calling toEntity(), Then domain entity maps correctly', () {
        final model = OrderModel(
          id: '1',
          customerName: 'Jane',
          totalAmount: 100.0,
          createdAt: DateTime(2024, 1, 15),
        );
        final entity = model.toEntity();
        expect(entity.id, '1');
        expect(entity.customerName, 'Jane');
      });
    });
  });
}
```

### Use Case Test

```dart
// test/features/orders/domain/usecases/get_orders_usecase_test.dart
void main() {
  late GetOrdersUseCase useCase;
  late MockOrderRepository mockRepo;

  setUp(() {
    mockRepo = MockOrderRepository();
    useCase = GetOrdersUseCase(mockRepo);
  });

  group('Given a successful repository response', () {
    test('When calling the use case, Then orders are returned', () async {
      final orders = [OrderEntity(...)];
      when(() => mockRepo.getOrders()).thenAnswer((_) async => ApiSuccess(orders));

      final result = await useCase();

      expect(result, isA<ApiSuccess<List<OrderEntity>>>());
      verify(() => mockRepo.getOrders()).called(1);
    });
  });

  group('Given a failed repository response', () {
    test('When calling the use case, Then failure is returned', () async {
      when(() => mockRepo.getOrders()).thenAnswer((_) async => ApiFailure(...));

      final result = await useCase();

      expect(result, isA<ApiFailure>());
    });
  });
}
```

### BLoC Test

```dart
// test/features/orders/presentation/bloc/orders_bloc_test.dart
void main() {
  late OrdersBloc bloc;
  late MockGetOrdersUseCase mockGetOrders;

  setUp(() {
    mockGetOrders = MockGetOrdersUseCase();
    bloc = OrdersBloc(mockGetOrders);
  });

  group('Given FetchOrders event', () {
    blocTest<OrdersBloc, OrdersState>(
      'When repository succeeds, Then emits [Loading, Loaded]',
      build: () {
        when(() => mockGetOrders()).thenAnswer(
          (_) async => ApiSuccess([OrderEntity(...)]),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(FetchOrders()),
      expect: () => [OrdersLoading(), isA<OrdersLoaded>()],
    );

    blocTest<OrdersBloc, OrdersState>(
      'When repository fails, Then emits [Loading, Error]',
      build: () {
        when(() => mockGetOrders()).thenAnswer(
          (_) async => ApiFailure(ApiCallFailureModel(
            code: 500,
            translatedMessage: 'Server error',
          )),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(FetchOrders()),
      expect: () => [OrdersLoading(), OrdersError('Server error')],
    );
  });
}
```

### Widget Test

```dart
// test/features/orders/presentation/pages/orders_screen_test.dart
void main() {
  group('Given loading state', () {
    testWidgets('When rendered, Then loading indicator is shown', (tester) async {
      await tester.pumpApp(
        BlocProvider.value(
          value: OrdersBloc(MockGetOrdersUseCase())..add(FetchOrders()),
          child: const OrdersView(),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('Given loaded state with orders', () {
    testWidgets('When rendered, Then order list items are visible', (tester) async {
      final mockBloc = MockOrdersBloc();
      when(() => mockBloc.state).thenReturn(
        OrdersLoaded(orders: [OrderEntity(id: '1', ...)]),
      );
      whenListen(mockBloc, Stream.fromIterable([]));

      await tester.pumpApp(
        BlocProvider.value(value: mockBloc, child: const OrdersView()),
      );
      expect(find.text('John'), findsOneWidget);
    });
  });

  group('Given error state', () {
    testWidgets('When rendered, Then error message and retry button are shown', (tester) async {
      final mockBloc = MockOrdersBloc();
      when(() => mockBloc.state).thenReturn(OrdersError('Something went wrong'));
      whenListen(mockBloc, Stream.fromIterable([]));

      await tester.pumpApp(
        BlocProvider.value(value: mockBloc, child: const OrdersView()),
      );
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}
```

---

## 13. Complete Checklist

For every new feature, verify:

- [ ] Domain layer created: entity, repository interface, use case(s)
- [ ] Entity extends `Equatable` with all fields in `props`
- [ ] Model uses `@freezed` (abstract class) with `JsonParseUtils` on every `@JsonKey`
- [ ] Model has `@Default` on every non-nullable field
- [ ] Model has `toEntity()` conversion
- [ ] DataSource annotated with `@lazySingleton`
- [ ] Repository implementation annotated with `@LazySingleton(as: Interface)`
- [ ] Repository uses `BaseApiRepository.safeApiCall()` or `ScalableBaseRepository`
- [ ] BLoC annotated with `@injectable`, depends on use cases only
- [ ] States and events use `EquatableMixin`
- [ ] Page uses `BlocProvider` + `BlocConsumer`/`BlocBuilder`
- [ ] Page handles all states: initial, loading, loaded (empty + populated), error
- [ ] Route added to `app_routes.dart` with path and name constants
- [ ] `./scripts/codegen.sh` run successfully
- [ ] `flutter analyze` passes with no errors
- [ ] Model tests cover: null fields, wrong types, empty JSON, round-trip
- [ ] Use case tests cover: success and failure
- [ ] BLoC tests cover: every event with success and failure outcomes
- [ ] Widget tests cover: loading, loaded, empty, error states
