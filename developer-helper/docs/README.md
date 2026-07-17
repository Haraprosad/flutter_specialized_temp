# Documentation Hub — flutter_specialized_temp

This folder is the **deep reference** for the template. Each guide owns exactly
**one topic**, and nothing is documented in two places — when you need detail on
a layer, there's exactly one file to open.

> **First time here?** Read the root [README.md](../README.md) (the
> fork → running-app journey), then [HOW_TO_USE.md](../HOW_TO_USE.md) (the
> runbook). Come back to this hub when you need a specific topic.

---

## How to use these docs

**Reading order (first time)**

1. [../README.md](../README.md) — what this template is + the newbie journey.
2. [HOW_TO_USE.md](../HOW_TO_USE.md) — the runbook: the two-command flow (SETUP + BUILD).
3. Then **build**, opening the numbered guide for whatever layer you're on.

**The one rule: single source of truth.** Every topic has exactly one home (see
the map below). When something changes, edit it *there* and link from anywhere
else — never copy it. The only deliberate duplication is layered: [PROJECT_RULES.md](../PROJECT_RULES.md)
carries a *terse summary* of the rules so Claude always has them in context,
while the full detail lives in the owning guide and in `skills-and-agents/skills/`.

**Which file does what** (the doc map — find the owner before you write)

| File | Its one job | Open it when… |
|---|---|---|
| [../README.md](../README.md) | Project front door: what it is + fork→run journey | You (or a teammate) just cloned the template |
| [../PROJECT_RULES.md](../PROJECT_RULES.md) | Claude's always-loaded rulebook: 14 non-negotiables, phase order, doc map | You want the rules in one terse place (Claude reads this every session) |
| [HOW_TO_USE.md](../HOW_TO_USE.md) | The runbook — the two-command flow: SETUP.md then BUILD.md per phase | You're deciding *what to do next* |
| [APP_OVERVIEW.md](APP_OVERVIEW.md) | **Your app's** product vision (idea, users, brand, feature order) | Starting a new app — fill this first |
| [SETUP.md](../SETUP.md) | Copy-paste prompts: Figma design → working screen | You're driving a feature with Claude |
| [01_GETTING_STARTED.md](01_GETTING_STARTED.md) | First-run setup + all commands/scripts | Configuring name/package/icon/env, or you need a command |
| [02_ARCHITECTURE.md](02_ARCHITECTURE.md) | Architecture, file-purpose map, the `lib/` tree, SOLID | You want to understand the codebase shape |
| [03_FEATURE_GUIDE.md](03_FEATURE_GUIDE.md) | Build one feature end-to-end, layer by layer | Implementing a feature |
| [04_DESIGN_SYSTEM.md](04_DESIGN_SYSTEM.md) | Design tokens, themes, responsive/adaptive | Writing any UI |
| [05_TESTING.md](05_TESTING.md) | Unit/widget/bloc/integration patterns, edge cases | Writing tests |
| [06_DEPLOYMENT.md](06_DEPLOYMENT.md) | Build flavors, signing, store submission, CI/CD | Shipping |
| [07_ROUTING.md](07_ROUTING.md) | GoRouter: names/paths, guards, transitions | Adding a route or navigating |
| [08_NETWORK.md](08_NETWORK.md) | DioClient, interceptors, `safeApiCall`, `ApiResult`, offline | Calling an API |
| [09_LOCALIZATION.md](09_LOCALIZATION.md) | `context.loc`, ARB files, `LocaleBloc`, new strings/languages | Adding user-facing text |
| [10_LOGGING.md](10_LOGGING.md) | `AppLogger`, severity levels, Sentry forwarding | Adding diagnostics |
| [11_STORAGE.md](11_STORAGE.md) | `AppStorage`, secure storage (tokens/PIN), preferences | Persisting local data |
| [features/](features/) | One `.md` per feature — the Phase 2 spec output | Specifying or building a feature |
| `skills-and-agents/agents/*` | Specialist personas you summon by `@name` | (Claude's config — see root README) |
| `skills-and-agents/skills/*` | Hardened rules per concern, auto-triggered | (Claude's config — see root README) |

---

## Guide catalog (numbered reference)

| # | Guide | Purpose |
|---|---|---|
| 0 | [How to use](../HOW_TO_USE.md) | The runbook — SETUP.md + BUILD.md two-command flow |
| — | [App Overview](APP_OVERVIEW.md) | Your app's product-level source of truth — write the idea here first |
| — | [Setup steps](../SETUP.md) | Copy-paste prompts for Figma design → working screen |
| 1 | [Getting Started](01_GETTING_STARTED.md) | Configure app name, package, icon, env; first run; all scripts |
| 2 | [Architecture](02_ARCHITECTURE.md) | Full architecture walkthrough, file-purpose map, SOLID |
| 3 | [Feature Guide](03_FEATURE_GUIDE.md) | Build a feature: DI, models, API, BLoC, routing, design system |
| 4 | [Design System](04_DESIGN_SYSTEM.md) | Tokens, responsive/adaptive, themes, styles, extensions |
| 5 | [Testing](05_TESTING.md) | Unit, widget, bloc, integration; edge cases; store readiness |
| 6 | [Deployment](06_DEPLOYMENT.md) | Build flavors, signing, store submission, CI/CD, monitoring |
| 7 | [Routing](07_ROUTING.md) | GoRouter: route names/paths, guards, transitions, navigation |
| 8 | [Network](08_NETWORK.md) | DioClient, interceptors, `safeApiCall`, `ApiResult`, offline |
| 9 | [Localization](09_LOCALIZATION.md) | `context.loc`, ARB files, `LocaleBloc`, strings/languages |
| 10 | [Logging](10_LOGGING.md) | `AppLogger`, severity levels, Sentry forwarding, where to log |
| 11 | [Local Storage](11_STORAGE.md) | `AppStorage`, secure storage, preferences, `StorageKeys` |

> Architecture diagram, quick-start commands, and the `lib/` tree are **not**
> repeated here — they live in their owners: [02_ARCHITECTURE.md](02_ARCHITECTURE.md)
> and [01_GETTING_STARTED.md](01_GETTING_STARTED.md).

---

## What's Included

| Category | Details |
|---|---|
| **Architecture** | Clean Architecture — strict domain / data / presentation separation per feature |
| **State Management** | BLoC with Injectable use-case wiring; constructor injection only |
| **DI** | GetIt + Injectable — auto-generated registration via `build_runner` |
| **Routing** | GoRouter with auth guards, shell routes, and typed route definitions |
| **Network** | Dio with auth, token-refresh, retry, and error interceptors |
| **Caching** | L1 in-memory + L2 disk via `ScalableCacheManager` |
| **Connectivity** | `ConnectivityCubit`, `NetworkAwarePage`, `OfflineIndicatorBanner` |
| **Auth** | Login / register / logout via clean use-case layer (reference feature) |
| **Design System** | Single import for all tokens, themes, styles, and extensions |
| **Responsive** | `flutter_screenutil` + adaptive layouts + device preview mode |
| **Localization** | ARB-based i18n (English + Bengali), `context.loc.<key>` |
| **Database** | Drift (SQLite) with type-safe DAOs and generated queries |
| **Testing** | Unit, widget, bloc, integration tests with mocktail and fixtures |
| **CI/CD** | GitHub Actions for test + deploy pipelines |
| **Environments** | Dev / Staging / Prod via `.env.*` files |
| **Feature Scaffold** | Mason brick: `mason make feature` generates the full layer structure |
