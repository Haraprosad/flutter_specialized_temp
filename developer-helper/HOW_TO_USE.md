# HOW TO USE — developer-helper

> Figma design → production-ready Flutter app on the flutter_specialized_temp
> template. Tool-independent: Claude Code, Cursor, or any coding agent.
> **You say two commands. Everything else is automatic.**

---

## Command 1 — Setup (once per project)

Copy this folder's contents into a fresh flutter_specialized_temp project,
connect the Figma MCP, then tell your agent:

```text
Follow developer-helper/SETUP.md and setup the system.
Figma file: <URL> · App name: <name>
```

The agent runs 8 steps: template identity → product capture → design tokens
from Figma (into your existing token structure) → screenshots of every screen →
user stories + navigation graph → screen index → PROJECT.md → TASKS.md.

**You only act at 4 human gates** (the agent stops and waits):

1. Confirm `docs/APP_OVERVIEW.md` (what you're building).
2. Approve the Figma-value → Dart-token mapping table (before any code changes).
3. Read and correct `design/USER_STORIES.md` (this becomes the routing spec).
4. Answer the PROJECT.md decision questions (auth, backend, monetization,
   offline, light/dark, platforms) and approve the blueprint.

## Command 2 — Build (repeat per phase)

```text
Follow developer-helper/BUILD.md — complete Phase <N>.
```

The agent selects its own persona, skills, and references from BUILD.md's
routing table, works the phase's tasks under mandatory quality gates, and stops
with a phase report. Phases run strictly in order (0 → 1 → 2 → features →
polish → final hardening). Repeat until Phase FINAL — that is a
production-ready, store-submittable app.

---

## What's in this folder

| File / folder | Role |
|---|---|
| **HOW_TO_USE.md** | This file — the user manual |
| **SETUP.md** | Command 1: the 8-step initialization the agent executes |
| **BUILD.md** | Command 2: phase execution, agent/skill routing, quality gates |
| **PROJECT_RULES.md** | The rulebook (locked stack, 14 non-negotiables, quality gates) — every agent session reads it first |
| **DOC_TEMPLATES.md** | Formats for PROJECT.md / TASKS.md, screen status discipline, bootstrap tree |
| **docs/** | Deep reference guides (getting started, architecture, routing, network, testing, deployment, …) — one topic per file |
| **skills-and-agents/** | 4 specialist personas + 5 hardened rule sets the agent adopts per phase |

## Rules you should personally enforce

1. **Never let the agent write feature code before PROJECT.md + TASKS.md exist.**
2. **Never skip a phase gate** — a phase is done only when every task is `[x]`
   with `flutter analyze` clean and mandatory tests green.
3. **Design changes go through tokens**, never through hardcoded values. When a
   screen's design is confirmed, flip its status to `[FINAL]` in
   `design/SCREEN_INDEX.md` — only you flip statuses.
4. Heavy testing (widget/integration/accessibility/60fps/pixel-perfect) runs
   once, in Phase FINAL — that's by design for speed; don't let the agent skip
   it there.
