# Agent: Test-Driven Development

**Invoked by**: `@agent tdd <feature-name>`

**Purpose**: Write ALL tests BEFORE writing implementation code. Tests define the contract. Implementation must make these tests pass — not the other way around.

**Reads first**: `.claude/skills/TDD.md`, `.claude/skills/FLUTTER_TEMPLATE.md`

**Prerequisite**: Mock API must be ready (`@agent json-server` completed).

**Updates after**: `.claude/memory/FEATURE_REGISTRY.md` (tests written: ✅)

---

## TDD Cycle (Red → Green → Refactor)

```
1. WRITE failing test  (Red)
2. Write MINIMUM code to pass  (Green)
3. REFACTOR without breaking tests
4. Repeat for next behaviour
```

Claude Code follows this exactly. Never write implementation and tests simultaneously.

---

## Execution Order (strict — do not reorder)

```
Round 1 → Model tests        (data/models/)
Round 2 → Entity tests        (domain/entities/)
Round 3 → Use case tests      (domain/usecases/)
Round 4 → Repository tests    (data/repositories/)
Round 5 → BLoC tests          (presentation/bloc/)
Round 6 → Widget tests        (presentation/pages/)
Round 7 → Integration test    (integration_test/)
```

After each round: run `flutter test <specific_file>` and confirm RED before implementing.

---

## Round 1 — Model Tests

**File**: `test/features/dlt_<name>/data/models/<name>_model_test.dart`

Must cover all 10 scenarios below. These protect against backend inconsistencies.

```dart
group('<Name>Model', () {
  // 1. Happy path — well-formed JSON
  test('parses valid JSON correctly', () { /* all fields present and correct type */ });

  // 2. Missing fields — @Default kicks in
  test('handles completely empty JSON', () {
    final model = <Name>Model.fromJson({});
    // assert all non-nullable fields equal their @Default value
  });

  // 3. Explicit null values
  test('handles null values gracefully', () {
    final json = {'id': null, 'name': null, 'amount': null};
    // assert defaults, not exceptions
  });

  // 4. Wrong types — JsonParseUtils converts
  test('handles wrong types without crashing', () {
    // int where String expected, String where double expected, etc.
  });

  // 5. Extreme values
  test('handles extreme numeric values', () {
    // 0, negative, very large, double.infinity
  });

  // 6. Unknown enum value → fallback
  test('unknown enum value falls back to default', () {
    final json = {'status': 'totally_unknown_value_xyz'};
    expect(<Name>Model.fromJson(json).status, equals(<Name>Status.defaultValue));
  });

  // 7. Round-trip: toJson → fromJson → equals original
  test('round-trips through JSON serialization', () {
    final original = <Name>Model(/* known values */);
    final restored = <Name>Model.fromJson(original.toJson());
    expect(restored, equals(original));
  });

  // 8. toEntity() converts all fields correctly
  test('toEntity() maps all fields correctly', () {
    final model = <Name>Model(/* values */);
    final entity = model.toEntity();
    expect(entity.id, equals(model.id));
    // ... every field
  });

  // 9. toEntity() with null date uses sensible fallback
  test('toEntity() handles null date without throwing', () {
    final model = <Name>Model(createdAt: null);
    expect(() => model.toEntity(), returnsNormally);
  });

  // 10. Malformed nested object doesn't crash
  test('malformed nested object is handled safely', () {
    final json = {'nested_object': 'not-an-object'};
    expect(() => <Name>Model.fromJson(json), returnsNormally);
  });
});
```

Run: `flutter test test/features/dlt_<name>/data/models/` → All RED ✅

---

## Round 2 — Entity Tests

**File**: `test/features/dlt_<name>/domain/entities/<name>_entity_test.dart`

```dart
group('<Name>Entity equality', () {
  test('two entities with same values are equal', () {
    final a = <Name>Entity(id: '1', /* ... */);
    final b = <Name>Entity(id: '1', /* ... */);
    expect(a, equals(b));
  });

  test('entities with different id are not equal', () {
    final a = <Name>Entity(id: '1', /* ... */);
    final b = <Name>Entity(id: '2', /* ... */);
    expect(a, isNot(equals(b)));
  });

  test('props contains all fields', () {
    final entity = <Name>Entity(id: '1', /* all fields */);
    expect(entity.props, hasLength(/* number of fields */));
  });
});
```

Run → RED ✅

---

## Round 3 — Use Case Tests

**File**: `test/features/dlt_<name>/domain/usecases/get_<name>s_usecase_test.dart`

```dart
void main() {
  late Get<Name>sUseCase useCase;
  late Mock<Name>Repository mockRepo;

  setUp(() {
    mockRepo = Mock<Name>Repository();
    useCase = Get<Name>sUseCase(mockRepo);
  });

  group('Get<Name>sUseCase', () {
    test('returns list of entities on success', () async {
      final entities = [<Name>Entity(/* ... */)];
      when(() => mockRepo.get<Name>s())
          .thenAnswer((_) async => ApiSuccess(entities));

      final result = await useCase();

      expect(result, isA<ApiSuccess<List<<Name>Entity>>>());
      verify(() => mockRepo.get<Name>s()).called(1);
    });

    test('returns ApiFailure on network error', () async {
      when(() => mockRepo.get<Name>s())
          .thenAnswer((_) async => ApiFailure(
                ApiCallFailureModel(code: 500, translatedMessage: 'Server error'),
              ));

      final result = await useCase();

      expect(result, isA<ApiFailure>());
    });

    test('passes page and limit parameters through', () async {
      when(() => mockRepo.get<Name>s(
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => ApiSuccess([]));

      await useCase(page: 2, limit: 10);

      verify(() => mockRepo.get<Name>s(page: 2, limit: 10)).called(1);
    });
  });
}
```

Run → RED ✅

---

## Round 4 — Repository Tests

**File**: `test/features/dlt_<name>/data/repositories/<name>_repository_impl_test.dart`

```dart
group('<Name>RepositoryImpl', () {
  test('returns entities when remote call succeeds', () async {
    when(() => mockRemote.get<Name>s()).thenAnswer(
      (_) async => [<Name>Model(id: '1', /* ... */)],
    );

    final result = await repo.get<Name>s();

    expect(result, isA<ApiSuccess>());
    final data = (result as ApiSuccess).data;
    expect(data.first, isA<<Name>Entity>());
  });

  test('returns ApiFailure when remote throws DioException', () async {
    when(() => mockRemote.get<Name>s()).thenThrow(
      DioException(requestOptions: RequestOptions()),
    );

    final result = await repo.get<Name>s();

    expect(result, isA<ApiFailure>());
  });

  test('toEntity() is called on all returned models', () async {
    final models = List.generate(5, (i) => <Name>Model(id: '$i'));
    when(() => mockRemote.get<Name>s()).thenAnswer((_) async => models);

    final result = await repo.get<Name>s();

    final data = (result as ApiSuccess).data;
    expect(data, hasLength(5));
  });
});
```

Run → RED ✅

---

## Round 5 — BLoC Tests

**File**: `test/features/dlt_<name>/presentation/bloc/<name>_bloc_test.dart`

One `blocTest` per event per outcome:

```dart
blocTest<'emits [Loading, Loaded] on FetchSuccess',
  build: () {
    when(() => mockUseCase()).thenAnswer((_) async => ApiSuccess([/* entity */]));
    return bloc;
  },
  act: (b) => b.add(Fetch<Name>s()),
  expect: () => [
    <Name>Loading(),
    isA<<Name>Loaded>().having((s) => s.items, 'items', hasLength(1)),
  ],
);

blocTest<'emits [Loading, Error] on FetchFailure',
  // ...
);

blocTest<'removes item optimistically on Delete',
  seed: () => <Name>Loaded(items: [entity1, entity2]),
  act: (b) => b.add(Delete<Name>('id_of_entity1')),
  expect: () => [
    isA<<Name>Loaded>().having((s) => s.items, 'items', hasLength(1)),
  ],
);

// Test for EVERY event in the BLoC
```

Run → RED ✅

---

## Round 6 — Widget Tests

**File**: `test/features/dlt_<name>/presentation/pages/<name>_screen_test.dart`

One test per UI state. Never test real BLoC — always mock it.

```dart
group('<Name>Screen', () {
  testWidgets('shows CircularProgressIndicator while loading', (tester) async {
    // mock bloc state = Loading
    // pump widget
    // expect find.byType(CircularProgressIndicator)
  });

  testWidgets('shows empty state widget when list is empty', (tester) async {
    // mock bloc state = Loaded(items: [])
    // expect empty state widget
  });

  testWidgets('renders correct item count when loaded', (tester) async {
    // mock bloc state = Loaded(items: 3 items)
    // expect 3 card widgets
  });

  testWidgets('shows error message and retry button on error', (tester) async {
    // mock bloc state = Error('Network error')
    // expect find.text('Network error') and find.text('Retry')
  });

  testWidgets('retry button dispatches FetchEvent', (tester) async {
    // tap retry → verify mockBloc.add(FetchEvent()) called once
  });

  testWidgets('pull-to-refresh dispatches RefreshEvent', (tester) async {
    // fling gesture → verify mockBloc.add(RefreshEvent()) called once
  });

  testWidgets('accessibility: list items have semantic labels', (tester) async {
    // verify Semantics nodes exist on interactive elements
  });
});
```

Run → RED ✅

---

## Round 7 — Integration Test

**File**: `integration_test/<name>_flow_test.dart`

```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('<Name> end-to-end flow', () {
    testWidgets('user can view <name> list after login', (tester) async {
      // Launch real app against mock server (localhost:3000)
      // Login → navigate to feature → assert list renders
    });

    testWidgets('user can create a <name>', (tester) async {
      // Fill form → submit → assert new item appears in list
    });

    testWidgets('app shows offline banner when network lost', (tester) async {
      // disable network → navigate → expect OfflineIndicatorBanner
    });
  });
}
```

Run: `flutter test integration_test/<name>_flow_test.dart` → RED ✅

---

## Implementation Gate

**DO NOT write implementation code until all tests in Rounds 1–6 are in place and failing (RED).**

After all RED tests exist, hand off to `@agent feature <name>` with the instruction:

> "Tests are written in `test/features/dlt_<name>/`. Make them pass one round at a time starting from Round 1. Do not modify the test files."

---

## Coverage Requirement

```bash
flutter test --coverage
# Open coverage/html/index.html
```

Minimum coverage per feature:

| Layer        | Required |
|--------------|----------|
| Models       | 100%     |
| Entities     | 100%     |
| Use Cases    | 100%     |
| Repositories | 90%+     |
| BLoCs        | 90%+     |
| Pages        | 80%+     |

If coverage is below threshold, add tests — do not lower the threshold.
