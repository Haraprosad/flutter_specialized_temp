# Guide 5 — Testing

Complete testing strategy for production-ready features using Behavior-Driven Development (BDD). Covers every test type, edge cases, and Play Store / App Store quality requirements. All tests use Given/When/Then naming for living documentation.

---

## Test Architecture

```
test/
├── helpers/
│   ├── mocks.dart          # All mock classes (add yours here)
│   ├── pump_app.dart       # Widget test helper: tester.pumpApp(widget)
│   ├── finders.dart        # Custom finders
│   └── test_helpers.dart   # Shared test utilities
├── fixtures/
│   ├── auth_fixture.json   # Sample API responses for tests
│   └── task_fixture.json
├── core/
│   ├── theme/              # ThemeBloc tests
│   ├── localization/       # LocaleBloc tests
│   ├── network/            # Network layer tests (interceptors, base_bloc)
│   └── storage/            # Storage tests
├── features/
│   ├── dlt_auth/
│   │   ├── data/           # Repository impl + model tests
│   │   ├── domain/         # Use case tests
│   │   └── presentation/   # BLoC tests
│   └── dlt_tasks/
│       ├── data/           # Model, repository, entity tests
│       ├── domain/         # Use case tests
│       └── presentation/   # BLoC tests
├── widget_test.dart        # Basic widget smoke test
└── integration_test/
    └── auth_flow_test.dart # Full auth flow integration test
```

---

## Test Types Per Feature

| Layer | Test Type | What to Test |
|---|---|---|
| **Model** | Unit | JSON parsing (all edge cases), `toEntity()`, round-trip |
| **Entity** | Unit | Equality, props |
| **Use Case** | Unit | Success and failure outcomes |
| **Repository** | Unit | Remote success, remote failure, cache behavior |
| **BLoC** | Unit | Every event → correct state sequence |
| **Page/Widget** | Widget | Rendering per state, user interactions, accessibility |
| **Full flow** | Integration | Real user journey (login → use feature → logout) |

---

## Mock Setup

The project uses **mockito** with `@GenerateNiceMocks` for generating mock classes. Nice mocks return sensible default values for unstubbed methods, reducing boilerplate.

Per-test file mock generation:

```dart
// At the top of your test file:
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'your_test_file.mocks.dart';

@GenerateNiceMocks([
  MockSpec<OrderRepository>(),
  MockSpec<GetOrdersUseCase>(),
  MockSpec<OrdersRemoteDatasource>(),
  MockSpec<OrdersBloc>(),
])
void main() { ... }
```

After adding or changing `@GenerateNiceMocks`, run:

```bash
./scripts/codegen.sh
```

Register fallback values for complex types only if using mocktail alongside mockito (rare):

```dart
// Only needed if mixing mocktail mocks with mockito-generated mocks.
// Prefer using @GenerateNiceMocks exclusively to avoid this.
setUpAll(() {
  registerFallbackValue(FetchOrders());
  registerFallbackValue(OrdersInitial());
});
```

---

## Widget Test Helper

The `tester.pumpApp()` extension wraps your widget with the minimum needed context:

```dart
// Usage:
await tester.pumpApp(
  MyWidget(),
  providers: [
    BlocProvider.value(value: mockBloc),
  ],
);
```

It provides: `MaterialApp`, `ScreenUtilInit`, optional `MultiBlocProvider`, and optional theme override.

---

## Model Tests — Edge Cases

This is the most critical layer. Backend responses are unpredictable — test every scenario.

```dart
void main() {
  group('OrderModel', () {
    // 1. Happy path — well-formed response
    group('Given a valid JSON response', () {
      test('When parsing, Then all model fields are populated correctly', () {
        final json = {
          'id': 'ord_123',
          'customer_name': 'John Doe',
          'total_amount': 99.99,
          'status': 'processing',
          'created_at': '2024-01-15T10:30:00Z',
          'is_paid': true,
          'tags': ['urgent', 'fragile'],
        };
        final model = OrderModel.fromJson(json);

        expect(model.id, 'ord_123');
        expect(model.customerName, 'John Doe');
        expect(model.totalAmount, 99.99);
        expect(model.isPaid, true);
        expect(model.tags, ['urgent', 'fragile']);
      });
    });

    // 2. Missing fields — defaults kick in
    group('Given missing fields in JSON', () {
      test('When parsing, Then defaults are applied without crashing', () {
        final model = OrderModel.fromJson({});
        expect(model.id, '');
        expect(model.customerName, '');
        expect(model.totalAmount, 0.0);
        expect(model.isPaid, false);
        expect(model.tags, isEmpty);
        expect(model.orderStatus, OrderStatus.pending);
      });
    });

    // 3. Null values
    group('Given null values in JSON', () {
      test('When parsing, Then safe defaults are used', () {
        final json = {
          'id': null,
          'customer_name': null,
          'total_amount': null,
          'tags': null,
          'created_at': null,
        };
        final model = OrderModel.fromJson(json);
        expect(model.id, '');
        expect(model.customerName, '');
        expect(model.totalAmount, 0.0);
        expect(model.tags, isEmpty);
        expect(model.createdAt, isNull);
      });
    });

    // 4. Wrong types — JsonParseUtils converts safely
    group('Given wrong types in JSON', () {
      test('When parsing, Then JsonParseUtils converts safely without crashing', () {
        final json = {
          'id': 12345,                      // int instead of String
          'total_amount': '199.50',         // String instead of double
          'is_paid': 'yes',                 // String instead of bool
          'discount_percent': '15',         // String instead of int
          'tags': [1, null, 'food', true],  // Mixed types in list
        };
        final model = OrderModel.fromJson(json);
        expect(model.id, '12345');
        expect(model.totalAmount, 199.50);
        expect(model.isPaid, true);
        expect(model.tags, ['1', 'food', 'true']);
      });
    });

    // 5. Extreme values
    group('Given extreme values in JSON', () {
      test('When parsing, Then model handles them gracefully', () {
        final json = {
          'id': '',                                    // Empty string
          'total_amount': double.infinity,             // Infinity
          'discount_percent': -999,                    // Negative
          'created_at': 'not-a-date',                  // Invalid date string
        };
        final model = OrderModel.fromJson(json);
        expect(model.totalAmount, double.infinity);
        expect(model.createdAt, isNull); // DateTime.tryParse returns null
      });
    });

    // 6. Enum with unknown value
    group('Given an unknown enum value in JSON', () {
      test('When parsing, Then fallback enum is used', () {
        final json = {'order_status': 'unknown_status'};
        final model = OrderModel.fromJson(json);
        expect(model.orderStatus, OrderStatus.pending);
      });
    });

    // 7. Round-trip: fromJson → toJson → fromJson
    group('Given a fully constructed model', () {
      test('When round-tripping through JSON, Then equality holds', () {
        final original = OrderModel(
          id: '1',
          customerName: 'Test',
          totalAmount: 50.0,
          status: 'pending',
          isPaid: false,
          tags: ['a', 'b'],
        );
        final json = original.toJson();
        final restored = OrderModel.fromJson(json);
        expect(restored, equals(original));
      });
    });

    // 8. toEntity() conversion
    group('Given a model with all fields populated', () {
      test('When calling toEntity(), Then domain entity maps correctly', () {
        final date = DateTime(2024, 6, 15);
        final model = OrderModel(
          id: '42',
          customerName: 'Alice',
          totalAmount: 150.0,
          createdAt: date,
          orderStatus: OrderStatus.shipped,
        );
        final entity = model.toEntity();
        expect(entity.id, '42');
        expect(entity.customerName, 'Alice');
        expect(entity.totalAmount, 150.0);
        expect(entity.status, 'shipped');
        expect(entity.createdAt, date);
      });
    });

    // 9. toEntity() with null date uses fallback
    group('Given a model with null date', () {
      test('When calling toEntity(), Then now() is used as fallback', () {
        final model = OrderModel(id: '1', customerName: 'Test', totalAmount: 0);
        final entity = model.toEntity();
        expect(entity.createdAt, isNotNull);
      });
    });

    // 10. Nested objects
    group('Given a malformed nested object in JSON', () {
      test('When parsing, Then nested field defaults to null', () {
        // Test that malformed nested objects don't crash parsing
        final json = {
          'metadata': 'not-an-object',  // String instead of Map
        };
        final model = OrderModel.fromJson(json);
        expect(model.metadata, isNull);
      });
    });
  });
}
```

---

## Use Case Tests

```dart
void main() {
  late GetOrdersUseCase useCase;
  late MockOrderRepository mockRepo;

  setUp(() {
    mockRepo = MockOrderRepository();
    useCase = GetOrdersUseCase(mockRepo);
  });

  group('Given a successful repository response', () {
    test('When calling the use case, Then orders are returned', () async {
      final orders = [OrderEntity(id: '1', customerName: 'A', totalAmount: 10, status: 'pending', createdAt: DateTime.now())];
      when(() => mockRepo.getOrders()).thenAnswer(
        (_) async => ApiSuccess(orders),
      );

      final result = await useCase();

      expect(result, isA<ApiSuccess<List<OrderEntity>>>());
      final data = (result as ApiSuccess).data;
      expect(data.length, 1);
    });
  });

  group('Given a failed repository response', () {
    test('When calling the use case, Then failure is returned', () async {
      when(() => mockRepo.getOrders()).thenAnswer(
        (_) async => ApiFailure(ApiCallFailureModel(
          code: 500,
          translatedMessage: 'Server error',
        )),
      );

      final result = await useCase();

      expect(result, isA<ApiFailure>());
    });
  });

  group('Given page and limit parameters', () {
    test('When calling the use case, Then parameters are forwarded to repository', () async {
      when(() => mockRepo.getOrders(page: any(named: 'page'), limit: any(named: 'limit')))
          .thenAnswer((_) async => ApiSuccess([]));

      await useCase(page: 2, limit: 10);

      verify(() => mockRepo.getOrders(page: 2, limit: 10)).called(1);
    });
  });
}
```

---

## BLoC Tests

Use `bloc_test` from the `bloc_test` package:

```dart
void main() {
  late OrdersBloc bloc;
  late MockGetOrdersUseCase mockGetOrders;
  late MockDeleteOrderUseCase mockDeleteOrder;

  setUp(() {
    mockGetOrders = MockGetOrdersUseCase();
    mockDeleteOrder = MockDeleteOrderUseCase();
    bloc = OrdersBloc(mockGetOrders, mockDeleteOrder);
  });

  tearDown(() => bloc.close());

  group('Given FetchOrders event', () {
    blocTest<OrdersBloc, OrdersState>(
      'When repository returns data, Then emits [Loading, Loaded]',
      build: () {
        when(() => mockGetOrders()).thenAnswer(
          (_) async => ApiSuccess([OrderEntity(...)]),
        );
        return bloc;
      },
      act: (b) => b.add(FetchOrders()),
      expect: () => [
        OrdersLoading(),
        isA<OrdersLoaded>().having((s) => s.orders.length, 'length', 1),
      ],
    );

    blocTest<OrdersBloc, OrdersState>(
      'When repository returns empty list, Then emits [Loading, Loaded] with empty orders',
      build: () {
        when(() => mockGetOrders()).thenAnswer(
          (_) async => ApiSuccess([]),
        );
        return bloc;
      },
      act: (b) => b.add(FetchOrders()),
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
      act: (b) => b.add(FetchOrders()),
      expect: () => [OrdersLoading(), OrdersError('Server error')],
    );
  });

  group('Given DeleteOrder event', () {
    blocTest<OrdersBloc, OrdersState>(
      'When order exists in loaded state, Then order is removed optimistically',
      build: () => bloc,
      seed: () => OrdersLoaded(
        orders: [OrderEntity(id: '1', ...), OrderEntity(id: '2', ...)],
        hasMore: false,
      ),
      act: (b) => b.add(DeleteOrder('1')),
      expect: () => [
        isA<OrdersLoaded>().having((s) => s.orders.length, 'length', 1),
      ],
    );
  });
}
```

---

## Widget Tests

```dart
void main() {
  group('OrdersView', () {
    group('Given loading state', () {
      testWidgets('When rendered, Then loading indicator is shown', (tester) async {
        final mockBloc = MockOrdersBloc();
        when(() => mockBloc.state).thenReturn(OrdersLoading());
        whenListen(mockBloc, Stream.fromIterable([OrdersLoading()]));

        await tester.pumpApp(
          BlocProvider.value(value: mockBloc, child: const OrdersView()),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('Given loaded state with no orders', () {
      testWidgets('When rendered, Then empty message is shown', (tester) async {
        final mockBloc = MockOrdersBloc();
        when(() => mockBloc.state).thenReturn(const OrdersLoaded(orders: []));
        whenListen(mockBloc, Stream.fromIterable([const OrdersLoaded(orders: [])]));

        await tester.pumpApp(
          BlocProvider.value(value: mockBloc, child: const OrdersView()),
        );

        expect(find.text('No orders yet'), findsOneWidget);
      });
    });

    group('Given loaded state with orders', () {
      testWidgets('When rendered, Then order list items are visible', (tester) async {
        final mockBloc = MockOrdersBloc();
        when(() => mockBloc.state).thenReturn(
          OrdersLoaded(orders: [OrderEntity(id: '1', customerName: 'John', ...)]),
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
        when(() => mockBloc.state).thenReturn(OrdersError('Network error'));
        whenListen(mockBloc, Stream.fromIterable([]));

        await tester.pumpApp(
          BlocProvider.value(value: mockBloc, child: const OrdersView()),
        );

        expect(find.text('Network error'), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
      });

      testWidgets('When retry is tapped, Then FetchOrders event is dispatched', (tester) async {
        final mockBloc = MockOrdersBloc();
        when(() => mockBloc.state).thenReturn(OrdersError('Error'));
        whenListen(mockBloc, Stream.fromIterable([]));

        await tester.pumpApp(
          BlocProvider.value(value: mockBloc, child: const OrdersView()),
        );

        await tester.tap(find.text('Retry'));
        verify(() => mockBloc.add(FetchOrders())).called(1);
      });
    });

    group('Given loaded state with orders', () {
      testWidgets('When user pulls to refresh, Then RefreshOrders event is dispatched', (tester) async {
        final mockBloc = MockOrdersBloc();
        when(() => mockBloc.state).thenReturn(
          OrdersLoaded(orders: [OrderEntity(id: '1', customerName: 'A', ...)]),
        );
        whenListen(mockBloc, Stream.fromIterable([]));

        await tester.pumpApp(
          BlocProvider.value(value: mockBloc, child: const OrdersView()),
        );

        // Simulate pull-to-refresh
        await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
        await tester.pumpAndSettle();

        verify(() => mockBloc.add(RefreshOrders())).called(1);
      });
    });
  });
}
```

---

## Integration Tests

Integration tests run on a real device/emulator and test full user flows:

```dart
// integration_test/orders_flow_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Orders flow', () {
    testWidgets('user can view orders list', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to orders
      await tester.tap(find.text('Orders'));
      await tester.pumpAndSettle();

      // Verify orders list is shown
      expect(find.byType(ListView), findsOneWidget);
    });
  });
}
```

Run integration tests:

```bash
flutter test integration_test
```

---

## Play Store & App Store Quality Requirements

These testing practices ensure your app passes review on the first submission:

### Required Tests Before Submission

| Test | Why Stores Care |
|---|---|
| All states handled (loading, empty, error) | Apple rejects apps that show blank screens or crash on errors |
| No force unwraps / null crashes | Google Play crashes negatively affect visibility |
| Network offline behavior | Reviewers test on airplane mode |
| Deep links work | Apple validates universal links |
| Back navigation works correctly | Both stores test hardware back button / swipe back |
| No hardcoded strings (use l10n) | Apple requires proper localization support |
| Accessibility labels on interactive elements | Both stores check VoiceOver / TalkBack |
| No `print()` statements in release | Performance and security |
| Loading states for all async operations | UX consistency |
| Form validation on all inputs | Data integrity |

### Accessibility Testing

```dart
testWidgets('orders list is accessible', (tester) async {
  await tester.pumpApp(const OrdersView());

  // Verify semantics
  final semantics = await tester.getSemantics(find.byType(ListView));
  expect(semantics.label, isNotEmpty);
});
```

Ensure every interactive element has a semantics label:

```dart
IconButton(
  onPressed: () {},
  icon: const Icon(Icons.delete),
  tooltip: 'Delete order', // ← Required for accessibility
)
```

### Performance Testing Checklist

- [ ] No jank on scroll (use `ListView.builder`, not `ListView` with children)
- [ ] Images are cached (`CustomImageView` handles this)
- [ ] No unnecessary rebuilds (use `Equatable` on states, `const` constructors)
- [ ] No memory leaks (dispose controllers, close streams in BLoC)
- [ ] App starts within 2 seconds on mid-range devices
- [ ] No ANR (Android Not Responding) — no blocking operations on main thread

---

## Running Tests

```bash
# All tests
flutter test

# Specific file
flutter test test/features/orders/data/models/order_model_test.dart

# With coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# Watch mode (re-runs on file changes)
flutter test --watch

# Integration tests (requires device)
flutter test integration_test

# Analyze (catches issues tests might miss)
flutter analyze --fatal-infos --fatal-warnings
```

---

## Test Naming Convention

```
test/
  features/
    <feature_name>/
      data/
        models/
          <model_name>_test.dart          # Model edge-case tests
        repositories/
          <repo_name>_test.dart           # Repository tests
      domain/
        entities/
          <entity_name>_test.dart         # Entity equality tests
        usecases/
          <usecase_name>_test.dart        # Use case tests
      presentation/
        bloc/
          <bloc_name>_test.dart           # BLoC state tests
        pages/
          <page_name>_test.dart           # Widget rendering tests
```

---

## CI Integration

Tests run automatically via GitHub Actions (`.github/workflows/test.yml`) on every push and PR. The pipeline:

1. Runs `flutter analyze --fatal-infos`
2. Runs `flutter test --coverage`
3. Uploads coverage report as artifact
4. Blocks PR merge if any step fails
