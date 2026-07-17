# DOC_TEMPLATES — PROJECT.md & TASKS.md generation formats

> Used by SETUP.md Steps 7–8. These are format specifications only —
> all stack, token, and architecture decisions come from PROJECT_RULES.md and docs/,
> never from here.

---

## 1. PROJECT.md template (write to project root)

> Single source of truth. TASKS.md references it by section number (§N).
> Never duplicate a decision into another file — point to §N instead.

```markdown
# PROJECT.md — <App Name>

## §1. Project Identity
Name, one-liner, platforms, design source (Figma URL + screen count),
target device baseline, min OS versions.

## §2. Locked Stack
The flutter_specialized_temp stack (see PROJECT_RULES.md — non-negotiable):
BLoC · GetIt+Injectable constructor injection · GoRouter via RouteNames ·
Dio + safeApiCall → ApiResult<T> · Drift · Freezed + JsonParseUtils ·
design_management_system tokens · 3 flavors · ARB localization · AppLogger.
"These decisions are closed. Do not reopen without flagging to the human."

## §3. Design Tokens
Pointer only: design/DESIGN_TOKENS.md. No values duplicated here.

## §4. Project Structure
Pointer only: docs/02_ARCHITECTURE.md.

## §5. Data Model
Entities + Drift tables derived from design/USER_STORIES.md content sections.
Fields with types, relations, defaults.

## §6. Routes
Full table from design/SCREEN_INDEX.md + navigation graph:
| Route name | Path | Screen | Guard | Transition | Params |

## §7. External APIs
Every endpoint implied by user stories (seeds the json-server mock):
| Method + path | Used for | Request/response shape | Failure behavior |

## §8. V1 Scope
Feature list in build order (from docs/APP_OVERVIEW.md).

## §9. EXCLUDED from V1
Explicit not-building list. Agent must STOP and ask if a task seems to need
anything here — never improvise.

## §10. Open Questions
| # | Question | Blocks (T-NNN) | Resolved by |

## §11. Decision Log
| Date | Decision | Rationale | Made by |
```

**Generation rule — human intervention:** while generating, ASK (don't assume) about:
auth providers, backend status, monetization, offline needs, light/dark scope,
platform targets. Every answer becomes a §11 row.

---

## 2. TASKS.md template (write to project root)

Strict hierarchy: **Phase → Module → Task**. Never a task outside a module,
never a module outside a phase.

```markdown
# TASKS.md — <App Name>
Generated: <date> | Source: PROJECT.md + design/SCREEN_INDEX.md

## Quick View        ← always the FIRST section
> Status: [ ] todo · [~] in progress · [x] done · [!] blocked
> RULE: do NOT start Phase N+1 until every task in Phase N is [x].

| Phase | Name | Modules | Tasks | Status |
|-------|------|---------|-------|--------|

## Phase N — <Name>
> **Phase summary:** what & why, 2–4 lines. Estimated time.
> **Depends on:** … / **Unlocks:** …

### Module N.M — <Name>
> **Module summary:** scope, 2–3 lines.
> **Files touched:** real paths
> **Done when:** observable, verifiable criterion

  T-NNN [ ] one-line task — enough context to act without re-reading anything,
            reference PROJECT.md §N and SCREEN_INDEX row where relevant

## Decision Log      ← always the LAST section (newest on top)
```

Task numbering: T-<phase><2-digit sequence> (T-001…, T-101…, T-201…).

---

## 3. Screen status discipline (used in design/SCREEN_INDEX.md)

| Status | Meaning | Agent behaviour |
|---|---|---|
| `[FINAL]` | Designer confirmed | Build pixel-perfect vs screenshot. No TODOs. |
| `[DRAFT]` | Still iterating | Widget tree + BLoC + routing only, tokens as placeholders, `// TODO: Finalize from Figma` on styled values, max 30 min styling. |
| `[BLOCKED]` | Awaiting design decision | Data layer + BLoC only. No UI. |

- Every screen defaults to `[DRAFT]`. Only the human flips a status.
- When a design update arrives: refresh the screenshot, search that screen's
  widgets for `// TODO: Finalize from Figma`, update values, run the visual
  check, then flip to `[FINAL]`.
- Token-first makes updates cheap: a brand-wide change is one line in a token
  file, not a per-screen hunt.

---

## 4. Bootstrap decision tree (agent start-of-session, verbatim rule)

```
Does PROJECT.md exist in the project root?
├── YES → Does TASKS.md exist?
│         ├── YES → Read Quick View, find first [ ] task, work it.
│         └── NO  → Generate TASKS.md (§2 above), then work.
└── NO  → Run SETUP.md. Write NO Flutter code until
          PROJECT.md and TASKS.md exist. If Figma MCP is unavailable and no
          screenshots exist → STOP and ask the human for a design source.
```
