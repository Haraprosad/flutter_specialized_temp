# flutter_specialized_temp

A production-ready Flutter starter — Clean Architecture, BLoC, Injectable DI,
multi-flavor, a unified Design Management System, and full testing infra —
wired for a disciplined Claude Code workflow.

---

## The newbie journey (fork → running app)

If you just copied this template to build your own app, follow these steps **in
order**. Each links to the deep guide; this is the map.

### Step 1 — Make it your app (Phase 0)

Detach from the template git history, set your app name, package/bundle ID,
icon, splash, and env files. All steps:
**[docs/01_GETTING_STARTED.md](docs/01_GETTING_STARTED.md)**.

```bash
git clone <template-repo-url> my_app && cd my_app
rm -rf .git && git init                 # start a fresh history
flutter pub get && ./scripts/codegen.sh
```

### Step 2 — Commit the rules (don't gitignore them!)

This template is driven by Claude Code. **Commit `CLAUDE.md`, `.claude/`,
`.github/`, and `docs/`** — they *are* the workflow. Only generated artifacts and
secrets get ignored:

| Commit ✅ | Ignore 🚫 |
|---|---|
| `CLAUDE.md` (the 14 non-negotiables) | `.claude/settings.local.json` (personal) |
| `.claude/agents/` + `.claude/skills/` (enforce architecture) | `.g.dart` / `.freezed.dart` / `injection.config.dart` (generated) |
| `.github/` (CI) | `.env*` (secrets) |
| `docs/` (your reference + specs) | `/build/`, `node_modules/` |

Optional: if you won't use Mason scaffolding, **delete** `mason.yaml` + `bricks/`
(don't gitignore them). Full rationale:
[docs/01_GETTING_STARTED.md → "What to keep, what to drop"](docs/01_GETTING_STARTED.md).

### Step 3 — Write down the app idea

Capture *what you're building and why* in
**[docs/APP_OVERVIEW.md](docs/APP_OVERVIEW.md)** (a ready-to-fill template:
idea, users, brand direction, feature build-order). This is the product-level
source of truth. Per-feature detail comes later in `docs/features/<name>.md`.

### Step 4 — Customize the design system from Figma tokens (Phase 1)

Export your Figma design tokens, then have the architect reconcile them into the
Design Management System **once, before any screen**:

```
@design-system-architect    # see docs/00_WORKFLOW.md → Prompt 1
```

### Step 5 — Build screens from screenshots (Phases 2–6)

Per feature: write its spec, mock the API, write behavior specs, then implement.
The copy-paste prompts live in **[docs/00_WORKFLOW.md](docs/00_WORKFLOW.md)**. The rules
the generated code must obey:

- **Page composition** → `lib/features/<name>/presentation/pages/` (one screen
  file that composes the sections).
- **Each section is its own widget** → `lib/features/<name>/presentation/widgets/`
  (one concept per file — never one giant page file).
- Every UI value is a **design token**; every string is **localized**; all four
  async states rendered. See the 14 non-negotiables in [CLAUDE.md](CLAUDE.md).

### Step 6 — Routing

Register the route in `lib/core/router/`, navigate with `RouteNames` +
`context.goNamed` / `context.pushNamed`. Never `Navigator.push`, never hardcode
paths. Full flow: **[docs/07_ROUTING.md](docs/07_ROUTING.md)**.

### Step 7 — Generate code & run

```bash
./scripts/codegen.sh                                 # after any annotation change
flutter analyze --fatal-infos --fatal-warnings && flutter test
flutter run -t lib/flavors/main_development.dart     # BASE_URL → mock or real API
```

---

## The mental model (one paragraph)

[CLAUDE.md](CLAUDE.md) is the always-loaded project rulebook (the 14
non-negotiables + phase order). **Skills** under `.claude/skills/` auto-activate
based on what you're working on (models, BLoCs, tests, tokens…). **Agents**
under `.claude/agents/` are specialists you summon by name
(`@design-system-architect`, `@feature-developer`, …) for a phase of work.
**`docs/`** is static reference: [00_WORKFLOW.md](docs/00_WORKFLOW.md) is the
runbook that ties it all together; the numbered guides go deep on each topic.

## Where to go next

| If you want to… | Go to |
|---|---|
| **The full runbook** (phases 0–7, the per-feature loop) | **[docs/00_WORKFLOW.md](docs/00_WORKFLOW.md)** |
| First-run setup (name, package, icon, env) | [docs/01_GETTING_STARTED.md](docs/01_GETTING_STARTED.md) |
| Figma → working screen prompts | [docs/00_WORKFLOW.md](docs/00_WORKFLOW.md#copy-paste-prompts-figma-design-to-working-screen) |
| Write the app idea | [docs/APP_OVERVIEW.md](docs/APP_OVERVIEW.md) |
| Browse all reference guides | [docs/README.md](docs/README.md) |
| The rules Claude follows | [CLAUDE.md](CLAUDE.md) |

## Claude Code config layout

```
CLAUDE.md                       # project memory — loads every conversation
.claude/
├── agents/                     # specialists you summon with @name
│   ├── design-system-architect.md   # Phase 1
│   ├── mock-backend-builder.md       # Phase 3
│   ├── feature-developer.md          # Phases 4–5 (BDD → implement)
│   └── ui-polish-specialist.md       # Phase 6
└── skills/                     # auto-triggering rule sets
    ├── flutter-template-core/SKILL.md
    ├── design-system-setup/SKILL.md
    ├── json-server-mocking/SKILL.md
    ├── bdd-workflow/SKILL.md
    └── ui-polish-performance/SKILL.md
```

## Editing the rules

These files are meant to evolve — but change each rule in the **one place** it
lives, never duplicate it across files:
- **[CLAUDE.md](CLAUDE.md)** — project-wide rules and phase order.
- **`.claude/skills/`** — hardened rules per concern.
- **`.claude/agents/`** — specialist personas.
