---
name: tdd-workflow
description: >
  Test-Driven Development rules for this template (Phase 4). Activates when
  writing or running tests, or scaffolding a test suite before implementation.
  Keywords: TDD, test, unit test, widget test, bloc_test, integration test,
  mocktail, fixtures, edge cases, red-green, coverage.
---

# TDD Workflow

Write the failing test suite first; it is the executable spec. Implementation
(Phase 5) makes it green. The `test/` tree mirrors `lib/` exactly.

## Order of writing (each layer is a "round")

1. **Model edge cases** — `test/features/dlt_<name>/data/models/<name>_model_test.dart`
   - null fields, wrong types, missing keys, enum fallback, round-trip
     (`fromJson`→`toJson`), `toEntity()` mapping. This is where `JsonParseUtils`
     robustness is proven.
2. **Entity** (if it has logic) — `domain/entities/<name>_entity_test.dart`.
3. **Use case** — `domain/usecases/<name>_usecase_test.dart` — success +
   failure paths, returns `ApiResult`.
4. **Repository impl** — `data/repositories/<name>_repository_impl_test.dart` —
   maps datasource output, error handling.
5. **BLoC** — `presentation/bloc/<name>_bloc_test.dart` — every event → state
   sequence with `bloc_test`.
6. **Widget** — `presentation/pages/<name>_screen_test.dart` — all async states:
   initial, loading, loaded-empty, loaded-populated, error + retry interaction.
7. **Integration** — `integration_test/<name>_flow_test.dart` — end-to-end happy
   path.

## Tooling & helpers (already in the repo)

- `mocktail` for mocks (see `test/helpers/mocks.dart`).
- Fixtures in `test/fixtures/*.json` (e.g. `task_fixture.json`,
  `auth_fixture.json`) — load real-shaped JSON, don't inline big maps.
- Shared helpers: `test/helpers/pump_app.dart` (wraps widget under test with
  theme/localization/providers), `finders.dart`, `test_helpers.dart`.
- Reference suites: `test/features/dlt_tasks/` (Drift) and
  `test/features/dlt_auth/` (API).

## Rules

- Write **all** tests for a layer before implementing it. Run them and confirm
  RED — that is correct and expected.
- Do not write implementation while writing tests. Do not edit tests to make
  them pass; fix the implementation.
- Models: cover the nasty inputs (`null`, `"123"` vs `123`, missing field,
  unknown enum value) — these are the bugs the real backend will surface.
- Every async screen test asserts all four states render.

```bash
flutter test                                # confirm RED before implementing
flutter test test/features/dlt_<name>/...   # one layer at a time
flutter test --coverage
flutter test integration_test
```

Full patterns: `docs/05_TESTING.md`.
