# PROJECT_RULES — Flutter App on flutter_specialized_temp

> The always-loaded rulebook for any AI agent (or human) working on this project.
> Every agent session must read this file first, regardless of IDE/tool. Keep it
> tight and high-signal. Detailed rules live in `skills-and-agents/skills/`.

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

## The 14 Non-Negotiables (memorize these)

1. Clean Architecture per feature. Domain layer has **zero** Flutter/Dio dependencies (only `equatable`).
2. BLoCs depend on **use cases**, never repositories directly.
3. DI is **constructor injection**. Never `sl<T>()` inside BLoCs / use cases / repositories / datasources.
4. Every model `@JsonKey` uses a `JsonParseUtils` converter + `@Default`.
5. Every API call goes through `safeApiCall` (or `optimizedApiCall` for high-traffic features). Returns `ApiResult<T>`. `optimizedApiCall` does **stale-while-revalidate** caching — `staleTime` (default 5 min) serves cached data with no network on re-entry, then serves stale + silently refreshes in the background until `maxStaleAge` (default 1 hr). The cache is in-memory only (not durable across restarts); use Drift / the `MutationQueue` for offline persistence. See `docs/08_NETWORK.md` for the complete network system, interceptor chain, error handling pipeline, SWR caching, and step-by-step integration walkthrough.
6. Every BLoC handler `switch`es on `ApiResult` exhaustively (Dart 3 sealed-class syntax).
7. Every UI value uses a design token (`AppSpacing.X`, `context.colors.X`, `context.textTheme.X`). No raw literals.
8. Every interactive widget is accessible (`tooltip`, `Semantics`, ≥48×48 tap target, scales to 200% text).
9. Every scrollable form wraps in `SingleChildScrollView` with keyboard padding. Rows/Columns use `Flexible`/`Expanded`.
10. Every release build: `--obfuscate --split-debug-info=build/debug-info`. Symbols archived per release.
11. Every async screen handles all four states: initial, loading, loaded-empty, loaded-populated, error.
12. After any annotation change: `./scripts/codegen.sh`. Before any commit: `flutter analyze --fatal-infos --fatal-warnings && flutter test`.
13. All routing goes through `lib/core/router/`. Use `RouteNames` for navigation (`context.goNamed`/`context.pushNamed`), `RoutePaths` for path constants, `RouteTransitions` for page animations, and `RouteGuards` for protection. Never use `Navigator.push`/`Navigator.pushNamed`, never hardcode path strings, never create a new `GoRouter` instance. See `docs/07_ROUTING.md` for the full routing flow.
14. Every user-facing string comes from localization. In widgets use `context.loc.<key>` (backed by the ARB files in `lib/core/localization/l10n/`); outside a `BuildContext` use `ErrorMessagesKey` + `LocalizationService`. Switch languages only via `LocalizationActions.setLocale`. Add new keys to **all** ARB files, then run `flutter gen-l10n` (not `./scripts/codegen.sh`). Never hardcode a literal string in a widget, never edit `app_localizations*.dart` by hand. See `docs/09_LOCALIZATION.md` for the full flow.

If any of these is at risk in a generated change, **stop and fix before continuing.**

---

## Development phases (in order)

This project follows a strict phase order. Don't skip phases. Setup is driven
by `SETUP.md`, phase execution by `BUILD.md` (which contains the full
agent/skill routing table and phase definitions). This is the terse map:

| Stage / Phase | Goal | Agent + Skill (details: BUILD.md routing table) |
|---|---|---|
| Stage A (SETUP.md, once) | Figma → tokens, screenshots, user stories, SCREEN_INDEX, PROJECT.md, TASKS.md | `design-system-architect` + `design-system-setup` for tokens; rest per SETUP.md steps |
| Phase 0 | Foundation verify (template identity, tokens compile) | — |
| Phase 1 | Full routing skeleton + dummy pages, whole app navigable | Skill: `design-system-setup` |
| Phase 2 | Mock backend for ALL resources | `mock-backend-builder` + `json-server-mocking` |
| Phases 3…N | One feature per phase: spec → mandatory specs → implement | `feature-developer` + `bdd-workflow`, `flutter-template-core` |
| Phase FINAL−1 | Polish (motion, empty/error, perf) | `ui-polish-specialist` + `ui-polish-performance` |
| Phase FINAL | Hardening: deferred tests, a11y, 60fps, mock→real swap, release | both agents + `bdd-workflow`, `ui-polish-performance` |

One feature per phase, fully done before the next starts. Don't parallelize.
Mandatory test tier runs every phase; heavy tier is deferred to Phase FINAL
(definitions in BUILD.md "Testing tiers").

---

## Where to find things

| You want to know about... | Read... |
|---|---|
| **Map of all docs** (which file owns what + how to use them) | `docs/README.md` |
| This app's product vision (idea, users, brand, feature order) | `docs/APP_OVERVIEW.md` |
| How to use the whole system (the two commands) | `HOW_TO_USE.md` |
| Initialization steps (Figma → tokens/stories/PROJECT.md/TASKS.md) | `SETUP.md` |
| Phase execution + agent/skill routing | `BUILD.md` |
| Template architecture in detail | `docs/02_ARCHITECTURE.md` |
| How to build one feature end-to-end | `docs/03_FEATURE_GUIDE.md` |
| Design tokens reference | `docs/04_DESIGN_SYSTEM.md` |
| Testing patterns | `docs/05_TESTING.md` |
| Release / store submission | `docs/06_DEPLOYMENT.md` |
| Routing system (full flow guide) | `docs/07_ROUTING.md` |
| Network & API integration (DioClient, interceptors, `safeApiCall`, `ApiResult`, offline patterns) | `docs/08_NETWORK.md` |
| Localization (`context.loc`, ARB files, `LocaleBloc`, adding strings/languages, non-UI error translation) | `docs/09_LOCALIZATION.md` |
| Logging (`AppLogger`, severity levels, Sentry forwarding, where to log per layer) | `docs/10_LOGGING.md` |
| Local storage (tokens/PIN in `SecureStorageManager`, login id/prefs in `PreferencesManager`, via `AppStorage`) | `docs/11_STORAGE.md` |
| Hardened rules per task | `skills-and-agents/skills/<skill>/SKILL.md` |
| Specialist personas | `skills-and-agents/agents/*.md` |

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
- Hardcoded English strings in widgets (use `context.loc.<key>`; see `docs/09_LOCALIZATION.md`)
- Raw `print()` / `debugPrint()` for diagnostics — use `AppLogger` with the right severity (see `docs/10_LOGGING.md`)
- `ListView(children: [...])` for lists > 10 items (use `ListView.builder` + `itemExtent`)

---

## Tone and verbosity for generated code

- No filler comments. Code explains itself; comments explain **why**, not **what**.
- One concept per file (entity, use case, datasource — each gets its own file).
- Match the existing template's naming, spacing, import ordering.
- When in doubt, mirror `lib/features/auth/` for auth-shaped features or `lib/features/tasks/` for Drift-backed features.
