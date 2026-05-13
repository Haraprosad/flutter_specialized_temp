# Flutter Specialized Template — Source of Truth

A **production-ready, battle-proof Flutter starter** built with Clean Architecture, BLoC, Injectable DI, multi-flavor support, a unified Design Management System, and comprehensive testing infrastructure.

> **New to this template?** Follow the guides in order:
>
> 1. [Getting Started](01_GETTING_STARTED.md) — Set up your app, run it
> 2. [Architecture](02_ARCHITECTURE.md) — Understand the codebase
> 3. [Feature Guide](03_FEATURE_GUIDE.md) — Build a feature end-to-end
> 4. [Design System](04_DESIGN_SYSTEM.md) — UI tokens, responsive/adaptive patterns
> 5. [Testing](05_TESTING.md) — Unit, widget, bloc, integration tests
> 6. [Deployment](06_DEPLOYMENT.md) — Build, sign, submit to stores

---

## Quick Start

```bash
# 1. Copy env templates and fill in BASE_URL / SENTRY_DSN
cp ".env copy.development" .env.development
cp ".env copy.staging"     .env.staging
cp ".env copy.production"  .env.production

# 2. Install dependencies and generate code
flutter pub get
./scripts/codegen.sh

# 3. Run in development mode
flutter run -t lib/flavors/main_development.dart
```

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

---

## Architecture at a Glance

```
lib/
├── main.dart                        # App entry
├── flavors/                         # Environment configs & entry points
├── core/
│   ├── bloc/                        # ThemeBloc, NavigationBloc
│   ├── database/                    # Drift DB, tables, DAOs
│   ├── design_management_system/    # Tokens, themes, styles, extensions
│   ├── di/                          # GetIt + Injectable setup
│   ├── exceptions/                  # AppException hierarchy
│   ├── extensions/                  # String, DateTime helpers
│   ├── localization/                # ARB files, LocaleBloc
│   ├── logger/                      # AppLogger (Sentry-aware)
│   ├── network/                     # DioClient, interceptors, error handling
│   ├── observers/                   # BlocObserver, RouterObserver
│   ├── router/                      # GoRouter config & guards
│   ├── services/                    # MemoryManagementService
│   ├── storage/                     # SecureStorage + Preferences
│   └── widgets/                     # Shared UI components
├── features/
│   ├── dlt_auth/                    # Auth feature (reference implementation)
│   ├── dlt_home/                    # Home feature
│   ├── dlt_profile/                 # Profile feature
│   └── dlt_tasks/                   # Tasks feature (with Drift DB)
└── dlt_common_actions/
    └── infinite_scrolling/          # Reusable infinite-scroll pattern
```

Each feature follows the same structure:

```
features/<name>/
├── domain/         → entities, repository interfaces, use cases
├── data/           → models (Freezed), datasources, repository implementations
└── presentation/   → BLoC (events/states), pages, widgets
```

---

## Key Commands

```bash
# Development
flutter run -t lib/flavors/main_development.dart
flutter run -t lib/main_preview.dart          # Responsive preview

# Code generation (after adding @freezed / @injectable / Drift)
./scripts/codegen.sh

# Full clean rebuild
./scripts/clean.sh

# Analysis
flutter analyze --fatal-infos --fatal-warnings

# Testing
flutter test
flutter test --coverage
flutter test integration_test

# Production build
flutter build appbundle -t lib/flavors/main_production.dart --release \
  --obfuscate --split-debug-info=build/debug-info
```

---

## Guide Index

| # | Guide | Purpose |
|---|---|---|
| 1 | [Getting Started](01_GETTING_STARTED.md) | Configure app name, package, icon, env; first run |
| 2 | [Architecture](02_ARCHITECTURE.md) | Full architecture walkthrough, file-purpose map, SOLID |
| 3 | [Feature Guide](03_FEATURE_GUIDE.md) | Build a feature: DI, models, API, BLoC, routing, design system |
| 4 | [Design System](04_DESIGN_SYSTEM.md) | Tokens, responsive/adaptive, themes, styles, extensions |
| 5 | [Testing](05_TESTING.md) | Unit, widget, bloc, integration; edge cases; store readiness |
| 6 | [Deployment](06_DEPLOYMENT.md) | Build flavors, signing, store submission, CI/CD, monitoring |
