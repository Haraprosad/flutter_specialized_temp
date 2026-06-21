# flutter_specialized_temp

A production-ready Flutter starter — Clean Architecture, BLoC, Injectable DI,
multi-flavor, a unified Design Management System, and full testing infra —
wired for a disciplined Claude Code workflow.

## Start here

| If you want to… | Go to |
|---|---|
| **Build an app with this template** (the runbook) | **[docs/00_WORKFLOW.md](docs/00_WORKFLOW.md)** |
| Set up & run the template for the first time | [docs/01_GETTING_STARTED.md](docs/01_GETTING_STARTED.md) |
| Browse all reference guides | [docs/README.md](docs/README.md) |
| Understand the project rules Claude follows | [CLAUDE.md](CLAUDE.md) |

## The mental model (one paragraph)

[CLAUDE.md](CLAUDE.md) is the always-loaded project rulebook (the 12
non-negotiables + phase order). **Skills** under `.claude/skills/` auto-activate
based on what you're working on (models, BLoCs, tests, tokens…). **Agents**
under `.claude/agents/` are specialists you summon by name
(`@design-system-architect`, `@feature-developer`, …) for a phase of work.
**`docs/`** is static reference: [00_WORKFLOW.md](docs/00_WORKFLOW.md) is the
runbook that ties it all together; the numbered guides go deep on each topic.

## Claude Code config layout

```
CLAUDE.md                       # project memory — loads every conversation
.claude/
├── agents/                     # specialists you summon with @name
│   ├── design-system-architect.md   # Phase 1
│   ├── mock-backend-builder.md       # Phase 3
│   ├── feature-developer.md          # Phases 4–5 (TDD → implement)
│   └── ui-polish-specialist.md       # Phase 6
└── skills/                     # auto-triggering rule sets
    ├── flutter-template-core/SKILL.md
    ├── design-system-setup/SKILL.md
    ├── json-server-mocking/SKILL.md
    ├── tdd-workflow/SKILL.md
    └── ui-polish-performance/SKILL.md
```

## Quick start

```bash
# 1. Env files (fill in BASE_URL — http://localhost:3000/ for the mock)
cp ".env copy.development" .env.development
cp ".env copy.staging"     .env.staging
cp ".env copy.production"  .env.production

# 2. Install deps + generate code
flutter pub get
./scripts/codegen.sh

# 3. Run (development flavor)
flutter run -t lib/flavors/main_development.dart
```

Then follow **[docs/00_WORKFLOW.md](docs/00_WORKFLOW.md)** to build your first
feature.

## Editing the rules

These files are meant to evolve — but change each rule in the **one place** it
lives, never duplicate it across files:
- **[CLAUDE.md](CLAUDE.md)** — project-wide rules and phase order.
- **`.claude/skills/`** — hardened rules per concern.
- **`.claude/agents/`** — specialist personas.
