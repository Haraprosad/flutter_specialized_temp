# BUILD.md — One-Command Phase Execution

> **User usage:** `Follow developer-helper/BUILD.md — complete Phase <N>.`
>
> **Agent contract:** you select the right persona, skills, and references
> yourself using the routing table below — the user only names the phase.
> PROJECT_RULES.md (the 14 non-negotiables) overrides everything.
> **Hard gate: never start Phase N if any task in Phase N−1 is not `[x]` —
> report the blocker instead.**

---

## Testing tiers (the speed rule)

- **Mandatory every task (fast, never skipped):**
  `flutter analyze --fatal-infos --fatal-warnings` · model parsing tests
  (JsonParseUtils edge cases) · bloc_test state flows · `./scripts/codegen.sh`
  after annotation changes · run against mock + visual compare vs screenshot.
- **Deferred to Phase FINAL (never skipped there):** widget tests for all four
  async states · integration_test flows · accessibility (tooltips, ≥48×48, 200%
  text scale) · profile-mode 60fps · pixel-perfect checklist per `[FINAL]`
  screen · localization sweep.

## Start-of-run ritual (every time, in order)

1. Read `PROJECT_RULES.md`.
2. Read `TASKS.md` Quick View → confirm the requested phase is next (gate above).
3. Read the requested phase's summary + its modules in `TASKS.md`.
4. For each UI task: open its `design/SCREEN_INDEX.md` row and follow the four
   links (screenshot, DESIGN_TOKENS section, USER_STORIES section, PROJECT.md §).
   **No repo-wide searching for design info — the index is the only entry point.**
5. Route via the table below: adopt the persona, read its skill file(s) fully.

If `PROJECT.md`/`TASKS.md` don't exist → STOP: run SETUP.md first
(bootstrap tree: DOC_TEMPLATES.md §4).

## Routing table (phase type → persona + skills + references)

| Phase / task type | Act as (agents/) | Read first (skills/) | Reference |
|---|---|---|---|
| Phase 0 — Foundation verify | — | design-system-setup | docs/01_GETTING_STARTED |
| Phase 1 — Routing skeleton + dummy pages | — | design-system-setup | docs/07_ROUTING, design/USER_STORIES.md §Navigation Graph |
| Phase 2 — Mock backend | mock-backend-builder | json-server-mocking | mock/README.md, PROJECT.md §7 |
| Feature phase — spec step | — | bdd-workflow | docs/03_FEATURE_GUIDE, design/USER_STORIES.md |
| Feature phase — mandatory specs (model/usecase/bloc, fail first) | feature-developer | bdd-workflow | docs/05_TESTING |
| Feature phase — implementation | feature-developer | flutter-template-core | docs/03_FEATURE_GUIDE, 08_NETWORK, 07_ROUTING, 09_LOCALIZATION, 11_STORAGE |
| Phase FINAL−1 — Polish | ui-polish-specialist | ui-polish-performance | docs/04_DESIGN_SYSTEM |
| Phase FINAL — Hardening & release | ui-polish-specialist + feature-developer | ui-polish-performance, bdd-workflow | docs/05_TESTING, 06_DEPLOYMENT |

Mid-build design-system change requested → act as design-system-architect
(skill: design-system-setup) and warn the user: token changes mean re-reviewing
every built screen.

## What each phase means

- **Phase 0 — Foundation verify.** SETUP Step 1 gates still green; tokens
  compile; fonts/assets registered.
- **Phase 1 — Full routing skeleton with dummy data ("walking skeleton").**
  From PROJECT.md §6: every route in `lib/core/router/` (RoutePaths, RouteNames,
  GoRoute, guards, transitions), shell route for bottom nav, one token-styled
  placeholder page per screen with dummy content and real navigation wired per
  USER_STORIES, splash → onboarding → auth-gate redirect with a fake auth flag.
  **Gate:** walk the ENTIRE navigation graph (every push/sheet/dialog) with zero
  crashes; analyze clean.
- **Phase 2 — Mock backend (all resources at once).** Seed `mock/db.json`
  (+ `db.seed.json`) from PROJECT.md §7: every resource, 15–25 realistic rows,
  envelope `{success, message, data}`, state switches (`?_state=empty|error`,
  `?_delay=N`) verified with curl.
- **Phases 3…N — one feature per phase.** Per feature:
  1. Spec — `docs/features/<name>.md` distilled from USER_STORIES (agent
     drafts, user skims).
  2. Mandatory specs first — model + usecase + bloc behavior tests, confirmed
     failing. Widget/integration scenarios: list as TODOs only (implemented in
     Phase FINAL).
  3. Implement — domain → data → presentation; replace the Phase-1 placeholder
     page. Tokens only, context.loc only, constructor injection, exhaustive
     ApiResult switch, all four async states rendered.
  4. Visual check vs `design/screens/<module>/<screen>.png`; obvious deltas
     fixed now, fine polish logged. `[DRAFT]` screens: structure only
     (DOC_TEMPLATES.md §3).
- **Phase FINAL−1 — Polish pass.** Motion tokens, real empty/error treatments,
  perf (const, itemExtent, RepaintBoundary, BlocSelector), pixel-perfect fixes
  against every `[FINAL]` screenshot.
- **Phase FINAL — Hardening & release.** The deferred test tier in full ·
  mock→real backend swap (only BASE_URL + model converters may change; more =
  architecture leak, fix the leak) · PROJECT_RULES.md quality gates ·
  `docs/06_DEPLOYMENT.md` (flavors, obfuscation + split-debug-info, store
  submission).

## Per-task loop

1. Take the first `[ ]` task, top to bottom (`[~]` while working).
2. Build per persona/skill rules; UI matches the screenshot using tokens only,
   respecting the screen's `[DRAFT]`/`[FINAL]` status.
3. Mandatory gates (tier above) green → then mark `[x]`.
4. New architectural decision → Decision Log row. Anything in PROJECT.md §9
   EXCLUDED seems needed → STOP and ask the user.

## End-of-phase report (print, update Quick View, then STOP)

```text
Phase <N> complete: <n> tasks [x]
Gates: analyze ✓ · mandatory tests ✓ · flows vs screenshots ✓
Decisions logged: <list or none>
Deferred to Phase FINAL: <accumulating list>
Next: "Follow developer-helper/BUILD.md — complete Phase <N+1>"
```
