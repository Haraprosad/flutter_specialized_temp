# Code Conventions

> Naming, structure, and style rules. Apply in ALL generated code.

---

## File Naming

| Type                   | Convention                        | Example                              |
|------------------------|-----------------------------------|--------------------------------------|
| Entity                 | `<name>_entity.dart`              | `order_entity.dart`                  |
| Model                  | `<name>_model.dart`               | `order_model.dart`                   |
| Repository interface   | `<name>_repository.dart`          | `order_repository.dart`              |
| Repository impl        | `<name>_repository_impl.dart`     | `orders_repository_impl.dart`        |
| Remote DataSource      | `<name>s_remote_datasource.dart`  | `orders_remote_datasource.dart`      |
| Local DataSource       | `<name>s_local_datasource.dart`   | `orders_local_datasource.dart`       |
| UseCase                | `<verb>_<name>_usecase.dart`      | `get_orders_usecase.dart`            |
| BLoC                   | `<name>s_bloc.dart`               | `orders_bloc.dart`                   |
| Event                  | `<name>s_event.dart`              | `orders_event.dart` (part of bloc)   |
| State                  | `<name>s_state.dart`              | `orders_state.dart` (part of bloc)   |
| Screen                 | `<name>s_screen.dart`             | `orders_screen.dart`                 |
| Test (mirror structure)| same path under `test/`           | `test/features/dlt_orders/...`       |

---

## Class Naming

| Type                   | Convention                        | Example                        |
|------------------------|-----------------------------------|--------------------------------|
| Entity                 | `<Name>Entity`                    | `OrderEntity`                  |
| Model                  | `<Name>Model`                     | `OrderModel`                   |
| Repository interface   | `<Name>Repository`                | `OrderRepository`              |
| Repository impl        | `<Name>sRepositoryImpl`           | `OrdersRepositoryImpl`         |
| DataSource             | `<Name>sRemoteDatasource`         | `OrdersRemoteDatasource`       |
| UseCase                | `<Verb><Name>UseCase`             | `GetOrdersUseCase`             |
| BLoC                   | `<Name>sBloc`                     | `OrdersBloc`                   |
| Event (abstract)       | `<Name>sEvent`                    | `OrdersEvent`                  |
| State (abstract)       | `<Name>sState`                    | `OrdersState`                  |
| Screen widget          | `<Name>sScreen`                   | `OrdersScreen`                 |
| View widget (inner)    | `<Name>sView`                     | `OrdersView`                   |
| Private sub-widget     | `_<Name>Card`, `_<Name>ListTile`  | `_OrderCard`                   |

---

## Variable Naming

| Rule                                                  | Example                                |
|-------------------------------------------------------|----------------------------------------|
| Private repository fields: `_remote`, `_local`        | `final OrdersRemoteDatasource _remote;` |
| BLoC use case fields: `_getOrders`, `_deleteOrder`    | `final GetOrdersUseCase _getOrders;`   |
| Handler methods: `_on<EventName>`                     | `_onFetchOrders`, `_onDeleteOrder`     |
| State fields in `OrdersLoaded`: `orders`, `hasMore`   | descriptive, no prefixes               |
| Mock in tests: `mock<ClassName>`                      | `mockOrderRepository`                  |

---

## Feature Folder Naming

All feature folders use the `dlt_` prefix:

```
lib/features/dlt_auth/
lib/features/dlt_home/
lib/features/dlt_orders/
lib/features/dlt_profile/
```

Mason brick generates without prefix. Rename manually after scaffold.

---

## Enum Naming

```dart
// Enums in models: <Name>Status, <Name>Type, <Name>Category
enum OrderStatus {
  @JsonValue('pending')    pending,
  @JsonValue('processing') processing,
  @JsonValue('shipped')    shipped,
}

// Always include a fallback/default value used by toEnum()
// Place enum definition BELOW the model class in the same file
```

---

## Freezed Model Conventions

```dart
@freezed
class OrderModel with _$OrderModel {
  const factory OrderModel({
    // 1. Required string fields first
    // 2. Required numeric fields
    // 3. Optional/nullable fields last
    // 4. Nested objects / lists last
  }) = _OrderModel;

  const OrderModel._();  // ← Always present for toEntity()

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  NameEntity toEntity() => ...;
}
// Enum for this model (if any) goes here
// fromJson helper for enum (if any) goes here
```

---

## BLoC State Conventions

```dart
// States always use EquatableMixin, not extends Equatable
// (sealed classes in Dart 3 — use sealed + extends pattern)

sealed class OrdersState with EquatableMixin {
  @override List<Object?> get props => [];
}

final class OrdersInitial extends OrdersState {}
final class OrdersLoading extends OrdersState {}
final class OrdersLoaded extends OrdersState {
  final List<OrderEntity> orders;
  final bool hasMore;
  final int currentPage;
  const OrdersLoaded({required this.orders, this.hasMore = true, this.currentPage = 1});
  @override List<Object?> get props => [orders, hasMore, currentPage];
}
final class OrdersError extends OrdersState {
  final String message;
  const OrdersError(this.message);
  @override List<Object?> get props => [message];
}
```

---

## Test Naming Conventions

```dart
// Groups by class, then behaviour
group('OrderModel', () {
  test('parses valid JSON correctly', () { ... });
  test('handles null values without throwing', () { ... });
});

// BLoC tests use blocTest with description starting with 'emits'
blocTest<OrdersBloc, OrdersState>(
  'emits [Loading, Loaded] when FetchOrders succeeds',
  ...
);

// Widget tests use testWidgets with 'shows' / 'taps' / 'navigates'
testWidgets('shows empty state when orders list is empty', ...);
testWidgets('retry button dispatches FetchOrders event', ...);
```

---

## Import Order (enforced by `import_sorter` or manual discipline)

```dart
// 1. Dart core
import 'dart:async';
import 'dart:convert';

// 2. Flutter
import 'package:flutter/material.dart';

// 3. Third-party packages
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';

// 4. Template core (absolute imports)
import 'package:flutter_specialized_temp/core/network/...';

// 5. Feature-local (relative imports)
import '../../domain/entities/order_entity.dart';
import '../bloc/orders_bloc.dart';
```

---

## Comment Standards

```dart
/// Public API: use doc comments (///)
/// [param] description
/// Returns [OrderEntity] or throws [AppException].

// Internal logic: use inline comments (//) sparingly
// Only when the WHY is not obvious from the code

// ❌ Bad: explains WHAT (already clear from code)
// create the order
final order = OrderModel.fromJson(json);

// ✅ Good: explains WHY (not obvious)
// Backend returns amount as String when currency is BDT — convert to double
@JsonKey(name: 'amount', fromJson: JsonParseUtils.toDouble)
```
