# Project Memory — Flutter App on flutter_specialized_temp

> This file is Claude's persistent memory for this project. It loads on every conversation. Keep it tight and high-signal. Detailed rules live in `.claude/skills/`.

---

## What this project is

A production Flutter application built on the **flutter_specialized_temp** template. The template is the source of truth for architecture; this app inherits all of its conventions.

**Stack (non-negotiable):**
- Flutter 3.x / Dart 3.x
- Clean Architecture per feature (`domain/` `data/` `presentation/`)
- BLoC for state (`flutter_bloc`), never Riverpod/Provider/GetX
- GetIt + Injectable for DI, **constructor injection only**
- GoRouter for routing
- Dio for HTTP (via `DioClient` with interceptor stack)
- Drift for local SQL
- Freezed for models, `JsonParseUtils` for every field
- `ApiResult<T>` sealed-class for all API returns
- Design Management System tokens for every UI value
- Three flavors: development / staging / production

---

## The 12 Non-Negotiables (memorize these)

1. Clean Architecture per feature. Domain layer has **zero** Flutter/Dio dependencies (only `equatable`).
2. BLoCs depend on **use cases**, never repositories directly.
3. DI is **constructor injection**. Never `sl<T>()` inside BLoCs / use cases / repositories / datasources.
4. Every model `@JsonKey` uses a `JsonParseUtils` converter + `@Default`.
5. Every API call goes through `safeApiCall` (or `optimizedApiCall` for high-traffic features). Returns `ApiResult<T>`.
6. Every BLoC handler `switch`es on `ApiResult` exhaustively (Dart 3 sealed-class syntax).
7. Every UI value uses a design token (`AppSpacing.X`, `context.colors.X`, `context.textTheme.X`). No raw literals.
8. Every interactive widget is accessible (`tooltip`, `Semantics`, ≥48×48 tap target, scales to 200% text).
9. Every scrollable form wraps in `SingleChildScrollView` with keyboard padding. Rows/Columns use `Flexible`/`Expanded`.
10. Every release build: `--obfuscate --split-debug-info=build/debug-info`. Symbols archived per release.
11. Every async screen handles all four states: initial, loading, loaded-empty, loaded-populated, error.
12. After any annotation change: `./scripts/codegen.sh`. Before any commit: `flutter analyze --fatal-infos --fatal-warnings && flutter test`.

If any of these is at risk in a generated change, **stop and fix before continuing.**

---

## Development phases (in order)

This project follows a strict phase order. Don't skip phases. The full runbook
is `docs/00_WORKFLOW.md`; this table is the terse map.

| Phase | Goal | Agent / Skill to use |
|---|---|---|
| 0 | Template setup (app name, package, env, icon, splash) | Reference: `docs/01_GETTING_STARTED.md` |
| 1 | **Design system customization** (colors, fonts, spacing for THIS app's brand) | Agent: `design-system-architect` + Skill: `design-system-setup` |
| 2 | Feature requirements gathering (define entities, endpoints, screens for one feature at a time) | Human-led, written into `docs/features/<name>.md` |
| 3 | **Mock backend** via `json-server` (build the API contract before backend exists) | Agent: `mock-backend-builder` + Skill: `json-server-mocking` |
| 4 | **BDD** — write behavior specs first (model scenarios → use case behaviors → BLoC state flows → widget interactions) | Agent: `feature-developer` + Skill: `bdd-workflow` |
| 5 | **Implementation** — make the tests pass, layer by layer (domain → data → presentation) | Agent: `feature-developer` + Skill: `flutter-template-core` |
| 6 | **UI polish & performance** — animations, micro-interactions, profile-mode tuning | Agent: `ui-polish-specialist` + Skill: `ui-polish-performance` |
| 7 | Swap mock for real backend (only `BASE_URL` and small datasource tweaks should change) | No new agent — minimal change by definition |

One feature flows through phases 2 → 6 before the next feature starts. Don't parallelize.

---

## Where to find things

| You want to know about... | Read... |
|---|---|
| Overall workflow (the runbook) | `docs/00_WORKFLOW.md` |
| Template architecture in detail | `docs/02_ARCHITECTURE.md` |
| How to build one feature end-to-end | `docs/03_FEATURE_GUIDE.md` |
| Design tokens reference | `docs/04_DESIGN_SYSTEM.md` |
| Testing patterns | `docs/05_TESTING.md` |
| Release / store submission | `docs/06_DEPLOYMENT.md` |
| Hardened rules per task | `.claude/skills/<skill>/SKILL.md` |
| Specialist personas | `.claude/agents/*.md` |

---

## Code organization rules (recap)

```
lib/
├── core/                            # cross-feature: DI, network, storage, router, design system, db
├── features/<name>/             # one folder per feature
│   ├── data/                        # models (Freezed + JsonParseUtils), datasources, repo impls
│   ├── domain/                      # entities (Equatable), repo interfaces, use cases
│   └── presentation/                # BLoC, pages, widgets
├── common_actions/              # reusable patterns (e.g., infinite scrolling)
└── flavors/                         # main_*.dart per environment

test/                                # mirrors lib/ structure
mock/                                # json-server mock (phase 3); scripts in root package.json
docs/features/                       # one .md per feature (phase 2 output)
```

---

## Quality gates (no exceptions)

Before any feature is considered "done":

- [ ] `flutter analyze --fatal-infos --fatal-warnings` → zero issues
- [ ] `flutter test` → all green, including model edge-case tests
- [ ] `flutter test integration_test` → at least one end-to-end flow green
- [ ] All four async states rendered in widget tests
- [ ] No raw color / spacing / string literal in any widget
- [ ] No `sl<T>()` inside BLoCs / use cases / repositories
- [ ] Profile-mode run on physical device → 60fps sustained on the new screens
- [ ] Accessibility: tooltip on every IconButton, 200% text scale tested

---

## Forbidden shortcuts

- Mixing state management approaches ("just this once we'll use Provider")
- Hand-editing generated files (`.g.dart`, `.freezed.dart`, `injection.config.dart`)
- Raw `as` casts on JSON values — use `JsonParseUtils`
- `try/catch` around `DioException` inside BLoCs (that's the repository's job)
- Hardcoded English strings in widgets (use `context.loc.<key>`)
- `ListView(children: [...])` for lists > 10 items (use `ListView.builder` + `itemExtent`)

---

## Tone and verbosity for generated code

- No filler comments. Code explains itself; comments explain **why**, not **what**.
- One concept per file (entity, use case, datasource — each gets its own file).
- Match the existing template's naming, spacing, import ordering.
- When in doubt, mirror `lib/features/auth/` for auth-shaped features or `lib/features/tasks/` for Drift-backed features.
