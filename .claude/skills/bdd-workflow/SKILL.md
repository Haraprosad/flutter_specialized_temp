---
name: bdd-workflow
description: >
  Behavior-Driven Development rules for this template (Phase 4). Activates when
  writing or running tests, or scaffolding a behavior spec suite before
  implementation. Keywords: BDD, behavior, scenario, Given, When, Then,
  specification, unit test, widget test, bloc_test, integration test,
  mocktail, fixtures, edge cases, coverage.
---

# BDD Workflow

Write the behavior specification suite first; it is the executable spec that
describes **what the system does**, not how it does it. Implementation (Phase 5)
makes every scenario pass. The `test/` tree mirrors `lib/` exactly.

## Philosophy

BDD shifts focus from "testing units" to "specifying behaviors." Every test
group describes a **Given** context, every test describes a **When** trigger and
**Then** expected outcome. Tests read like living documentation.

```dart
group('Given a valid JSON response', () {
  test('When parsing, Then all model fields are populated correctly', () { ... });
});

group('Given missing or null fields in JSON', () {
  test('When parsing, Then defaults are applied without crashing', () { ... });
});
```

## Order of writing (each layer is a "scenario round")

1. **Model behavior scenarios** — `test/features/dlt_<name>/data/models/<name>_model_test.dart`
   - Given valid JSON → When parsing → Then correct values
   - Given null/missing fields → When parsing → Then safe defaults
   - Given wrong types → When parsing → Then `JsonParseUtils` converts safely
   - Given unknown enum value → When parsing → Then fallback used
   - Given a model → When round-tripping (fromJson→toJson→fromJson) → Then equality holds
   - Given a model → When calling `toEntity()` → Then domain entity maps correctly
2. **Entity behavior** (if it has logic) — `domain/entities/<name>_entity_test.dart`.
3. **Use case behavior** — `domain/usecases/<name>_usecase_test.dart`
   - Given a successful repository response → When calling the use case → Then `ApiSuccess` returned
   - Given a failed repository response → When calling the use case → Then `ApiFailure` returned
4. **Repository impl behavior** — `data/repositories/<name>_repository_impl_test.dart`
   - Given datasource returns data → When calling repo → Then entities mapped correctly
   - Given datasource throws → When calling repo → Then error handled gracefully
5. **BLoC behavior** — `presentation/bloc/<name>_bloc_test.dart`
   - Given initial state → When event fired → Then expected state sequence emitted
   - Use `bloc_test` with BDD-named descriptions.
6. **Widget behavior** — `presentation/pages/<name>_screen_test.dart`
   - Given loading state → When rendered → Then spinner visible
   - Given loaded-empty state → When rendered → Then empty message shown
   - Given loaded-populated state → When rendered → Then list items visible
   - Given error state → When rendered → Then error message + retry shown
   - Given error state → When retry tapped → Then fetch event dispatched
7. **Integration behavior** — `integration_test/<name>_flow_test.dart`
   - Given the app is launched → When user navigates to feature → Then happy path completes

## Tooling & helpers (already in the repo)

- `mocktail` for mocks (see `test/helpers/mocks.dart`).
- Fixtures in `test/fixtures/*.json` (e.g. `task_fixture.json`,
  `auth_fixture.json`) — load real-shaped JSON, don't inline big maps.
- Shared helpers: `test/helpers/pump_app.dart` (wraps widget under test with
  theme/localization/providers), `finders.dart`, `test_helpers.dart`.
- Reference suites: `test/features/dlt_tasks/` (Drift) and
  `test/features/dlt_auth/` (API).

## Rules

- Write **all** behavior scenarios for a layer before implementing it. Run them
  and confirm they fail — that is correct and expected.
- Do not write implementation while writing specs. Do not edit specs to make
  them pass; fix the implementation.
- Name every `group` as a **Given** context and every `test` as a **When/Then**
  behavior. Tests should read as documentation of system behavior.
- Models: cover the nasty inputs (`null`, `"123"` vs `123`, missing field,
  unknown enum value) — these are the bugs the real backend will surface.
- Every async screen spec asserts all four states render.

```bash
flutter test                                # confirm specs FAIL before implementing
flutter test test/features/dlt_<name>/...   # one layer at a time
flutter test --coverage
flutter test integration_test
```

Full patterns: `docs/05_TESTING.md`.
