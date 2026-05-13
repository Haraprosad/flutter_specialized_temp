# Flutter Specialized Template — Project Intelligence

> **Claude Code reads this file automatically every session.**
> Keep it up to date. It is the single source of truth for all agents.

---

## Project Identity

| Field            | Value                                      |
|------------------|--------------------------------------------|
| App Name         | _FILL_IN_                                  |
| Package Name     | _FILL_IN_ (e.g. `com.company.appname`)     |
| Flutter Version  | 3.41+ stable (Dart 3.11+)                  |
| Template         | flutter_specialized_temp (Clean Arch + BLoC + Injectable + GoRouter + Drift) |
| Current Version  | 1.0.0+1                                    |
| Current Phase    | DESIGN_SYSTEM_SETUP / FEATURE_DEV / RELEASE (pick one) |

---

## How to Invoke Agents

Paste the agent invocation line into Claude Code as your first message.

| Goal                               | Say this                          |
|------------------------------------|-----------------------------------|
| Set up design system               | `@agent design-system`            |
| Build a new feature                | `@agent feature <feature-name>`   |
| Create mock API for a feature      | `@agent json-server <feature-name>` |
| Write tests first (TDD round)      | `@agent tdd <feature-name>`       |

Each agent file lives in `.claude/agents/`. Read the agent file before starting work.

---

## Always-Active Rules (apply in EVERY task)

These override any generic Flutter advice. No exceptions.

1. **Clean Architecture**: `domain/` → `data/` → `presentation/`. Never reverse the dependency.
2. **BLoC only** for state management — no Riverpod, no Provider, no GetX.
3. **Constructor injection only** — never `sl<T>()` inside BLoCs / use cases / repos.
4. **`JsonParseUtils` on every `@JsonKey`** + `@Default` on every non-nullable field.
5. **`safeApiCall` wraps every API call** — `ApiResult<T>` always returns to BLoC.
6. **`switch` on `ApiResult` exhaustively** — Dart 3 sealed class, no if/else escape.
7. **Design tokens only** — no raw `EdgeInsets`, `Color(0xFF...)`, `TextStyle(fontSize:)`.
8. **All four async states** — initial, loading, loaded (empty + populated), error.
9. **`ListView.builder` + `itemExtent` + `RepaintBoundary` + `ValueKey`** for lists.
10. **`context.loc.<key>` for every user-visible string** — zero hard-coded English.
11. **After annotation changes**: `./scripts/codegen.sh` before anything else.
12. **Before commit**: `flutter analyze --fatal-infos` + `flutter test` must pass.

---

## Project Memory Files (read before relevant tasks)

| File                                      | When to Read                              |
|-------------------------------------------|-------------------------------------------|
| `.claude/memory/PROJECT_STATE.md`         | Every session start                       |
| `.claude/memory/DESIGN_DECISIONS.md`      | Before any UI / widget work               |
| `.claude/memory/FEATURE_REGISTRY.md`      | Before adding a feature or route          |

---

## Skills (read before generating code in that domain)

| File                              | Domain                                      |
|-----------------------------------|---------------------------------------------|
| `.claude/skills/FLUTTER_TEMPLATE.md` | Full template patterns (read for any feature work) |
| `.claude/skills/DESIGN_SYSTEM.md` | Token files, DMS structure, theme extension |
| `.claude/skills/JSON_SERVER.md`   | Mock API setup and teardown                 |
| `.claude/skills/TDD.md`           | Test-first patterns, coverage requirements  |

---

## Context Files (read when architecture questions arise)

| File                               | Content                                   |
|------------------------------------|-------------------------------------------|
| `.claude/context/ARCHITECTURE.md`  | Layer rules, dependency flow, SOLID map   |
| `.claude/context/CONVENTIONS.md`   | File naming, class naming, folder naming  |

---

## Current Sprint / Active Work

```
Feature in progress : _FILL_IN_ or "none"
Mock API status     : running / not started
Tests written       : yes / no
UI status           : not started / in progress / done
```

> **Update this section** after each work session.

---

## Key Scripts

```bash
flutter run -t lib/flavors/main_development.dart   # dev
flutter run -t lib/main_preview.dart               # responsive preview
./scripts/codegen.sh                               # after @freezed / @injectable changes
./scripts/clean.sh                                 # nuclear reset
flutter analyze --fatal-infos --fatal-warnings
flutter test
flutter test integration_test
npx json-server --watch mock/db.json --port 3000 --routes mock/routes.json  # mock API
```
