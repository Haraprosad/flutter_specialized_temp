# Skill: Test-Driven Development

> The discipline: tests define behaviour. Implementation satisfies tests. Never the reverse.

---

## The Cycle

```
1. RED   → Write a failing test for the NEXT small behaviour
2. GREEN → Write the MINIMUM code to make it pass (no extras)
3. REFACTOR → Clean up without breaking tests
4. Repeat
```

Resist the urge to write more implementation than the current failing test requires. Premature implementation creates bugs that tests don't catch.

---

## Mock Setup (once per feature)

```dart
// test/helpers/mocks.dart — add mocks here, not inline in test files

import 'package:mocktail/mocktail.dart';

// Repository mocks
class Mock<Name>Repository extends Mock implements <Name>Repository {}

// UseCase mocks
class MockGet<Name>sUseCase extends Mock {
  Future<ApiResult<List<<Name>Entity>>> call({int page = 1, int limit = 20}) =>
      super.noSuchMethod(
        Invocation.method(#call, [], {#page: page, #limit: limit}),
        returnValue: Future.value(const ApiSuccess([])),
      );
}

// Datasource mocks
class Mock<Name>sRemoteDatasource extends Mock implements <Name>sRemoteDatasource {}

// BLoC mocks (for widget tests only)
class Mock<Name>sBloc extends MockBloc<<Name>sEvent, <Name>sState>
    implements <Name>sBloc {}
```

```dart
// test/helpers/pump_app.dart — standard widget test wrapper

extension PumpApp on WidgetTester {
  Future<void> pumpApp(
    Widget widget, {
    List<BlocProvider> providers = const [],
    ThemeData? theme,
  }) async {
    await pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        child: MaterialApp(
          theme: theme ?? AppTheme.light,
          darkTheme: AppTheme.dark,
          home: providers.isEmpty
              ? widget
              : MultiBlocProvider(providers: providers, child: widget),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
  }
}
```

---

## Fixture Pattern (for realistic JSON test data)

```dart
// test/fixtures/<name>_fixture.dart

Map<String, dynamic> get validOrderJson => {
  'id': 'ord_01HXYZ',
  'customer_name': 'Rahim Uddin',
  'total_amount': 1250.50,
  'status': 'processing',
  'order_status': 'processing',
  'is_paid': false,
  'created_at': '2025-01-15T10:30:00Z',
  'tags': ['express', 'fragile'],
};

Map<String, dynamic> get emptyOrderJson => {};

Map<String, dynamic> get nullFieldsOrderJson => {
  'id': null,
  'customer_name': null,
  'total_amount': null,
};

Map<String, dynamic> get wrongTypesOrderJson => {
  'id': 12345,
  'total_amount': '199.50',
  'is_paid': 1,
};

OrderEntity get sampleOrderEntity => OrderEntity(
  id: 'ord_01HXYZ',
  customerName: 'Rahim Uddin',
  totalAmount: 1250.50,
  status: 'processing',
  createdAt: DateTime.parse('2025-01-15T10:30:00Z'),
);

List<OrderEntity> get sampleOrderList =>
    List.generate(5, (i) => sampleOrderEntity.copyWith(id: 'ord_0$i'));
```

---

## BlocTest Patterns

```dart
// Basic success test
blocTest<OrdersBloc, OrdersState>(
  'emits [Loading, Loaded] when FetchOrders succeeds with data',
  build: () {
    when(() => mockGetOrders()).thenAnswer(
      (_) async => ApiSuccess(sampleOrderList),
    );
    return bloc;
  },
  act: (b) => b.add(FetchOrders()),
  expect: () => [
    isA<OrdersLoading>(),
    isA<OrdersLoaded>()
        .having((s) => s.orders.length, 'count', 5)
        .having((s) => s.hasMore, 'hasMore', false),
  ],
  verify: (_) => verify(() => mockGetOrders()).called(1),
);

// With initial seed state
blocTest<OrdersBloc, OrdersState>(
  'appends to existing orders when fetching page 2',
  seed: () => OrdersLoaded(orders: sampleOrderList, currentPage: 1),
  build: () {
    when(() => mockGetOrders(page: 2, limit: 20)).thenAnswer(
      (_) async => ApiSuccess(sampleOrderList),
    );
    return bloc;
  },
  act: (b) => b.add(FetchOrders(page: 2)),
  expect: () => [
    isA<OrdersLoaded>()
        .having((s) => s.orders.length, 'total', 10),
  ],
);

// Failure
blocTest<OrdersBloc, OrdersState>(
  'emits [Loading, Error] on API failure',
  build: () {
    when(() => mockGetOrders()).thenAnswer(
      (_) async => ApiFailure(
        ApiCallFailureModel(code: 500, translatedMessage: 'সার্ভার ত্রুটি'),
      ),
    );
    return bloc;
  },
  act: (b) => b.add(FetchOrders()),
  expect: () => [
    isA<OrdersLoading>(),
    isA<OrdersError>().having((s) => s.message, 'message', 'সার্ভার ত্রুটি'),
  ],
);
```

---

## Widget Test Patterns

```dart
// Setup with mocked BLoC
late MockOrdersBloc mockBloc;

setUp(() {
  mockBloc = MockOrdersBloc();
  registerFallbackValue(FetchOrders());
});

// Loading state
testWidgets('shows CircularProgressIndicator when loading', (tester) async {
  when(() => mockBloc.state).thenReturn(OrdersLoading());
  whenListen(mockBloc, Stream.fromIterable([OrdersLoading()]));

  await tester.pumpApp(
    BlocProvider<OrdersBloc>.value(value: mockBloc, child: const OrdersView()),
  );

  expect(find.byType(CircularProgressIndicator), findsOneWidget);
  expect(find.byType(ListView), findsNothing);
});

// Error + retry
testWidgets('retry button dispatches FetchOrders', (tester) async {
  when(() => mockBloc.state).thenReturn(const OrdersError('Network error'));
  whenListen(mockBloc, Stream.fromIterable([]));

  await tester.pumpApp(
    BlocProvider<OrdersBloc>.value(value: mockBloc, child: const OrdersView()),
  );

  await tester.tap(find.text('Retry'));  // or find.byKey(Key('retry_button'))
  await tester.pump();

  verify(() => mockBloc.add(any(that: isA<FetchOrders>()))).called(1);
});

// Accessibility
testWidgets('delete icon has tooltip for screen reader', (tester) async {
  when(() => mockBloc.state).thenReturn(OrdersLoaded(orders: [sampleOrderEntity]));
  whenListen(mockBloc, Stream.fromIterable([]));

  await tester.pumpApp(
    BlocProvider<OrdersBloc>.value(value: mockBloc, child: const OrdersView()),
  );

  final iconButton = tester.widget<IconButton>(find.byType(IconButton).first);
  expect(iconButton.tooltip, isNotNull);
  expect(iconButton.tooltip, isNotEmpty);
});
```

---

## What NOT to Test

| Anti-pattern                          | Why                                      |
|---------------------------------------|------------------------------------------|
| Test that `fromJson` exists           | Tests behaviour, not existence           |
| Test generated code (`.g.dart`)       | Generated by `freezed` — already tested  |
| Test `injection.config.dart`          | Generated by `injectable`                |
| Mock the system under test            | If you mock `OrdersBloc` in bloc test, you're testing nothing |
| Use real network in unit tests        | Flaky, slow, non-deterministic          |
| Use `sleep()` or `Future.delayed()` in tests | Use `pumpAndSettle()` or `FakeAsync` |

---

## Running Tests

```bash
# All tests
flutter test

# Single file
flutter test test/features/dlt_orders/data/models/order_model_test.dart

# With coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html   # macOS
xdg-open coverage/html/index.html  # Linux

# Watch mode
flutter test --watch

# Integration (requires running device or emulator + mock server)
npm run mock &
flutter test integration_test
```

---

## Coverage Thresholds

```
Models       : 100% (every JSON edge case tested)
Entities     : 100%
Use Cases    : 100%
Repositories : ≥90%
BLoCs        : ≥90%
Pages        : ≥80%
```

These thresholds protect against production crashes. Do not lower them.
