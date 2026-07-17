# SETUP.md — One-Command System Initialization

> **User usage:** `Follow developer-helper/SETUP.md and setup the system. Figma file: <URL> · App name: <name>`
>
> **Agent contract:** execute the steps IN ORDER, one at a time. Each step lists
> its reference, output, and gate. **HUMAN GATE** = present the output and WAIT
> for approval. Never skip or reorder a step, never write feature code. When
> Step 8 completes, control moves to BUILD.md.
> PROJECT_RULES.md (the 14 non-negotiables) overrides everything here.

---

## Pre-flight (before Step 1)

Check each; ask the user for anything missing:

- [ ] flutter_specialized_temp project (`lib/core/design_management_system/` exists)
- [ ] `PROJECT_RULES.md`, `docs/`, `skills-and-agents/` are in the project root —
      copy from `developer-helper/` if not. If the tool auto-loads a memory file
      (Claude Code `CLAUDE.md`, Cursor rules), make it one line:
      *"Read PROJECT_RULES.md, then follow developer-helper/SETUP.md or BUILD.md as instructed."*
- [ ] Figma MCP available in the tool list AND file URL known — else STOP and ask
- [ ] `PROJECT.md`/`TASKS.md` do NOT exist — if they do, setup already ran; use BUILD.md

Read fully before starting: `PROJECT_RULES.md`, `DOC_TEMPLATES.md`.

---

## Step 1 — Template identity

- **Read:** `docs/01_GETTING_STARTED.md`
- **Do:** app name, package/bundle id, icon, splash, `.env.*` files,
  `BASE_URL=http://localhost:3000/` in `.env.development`. Ask for values not provided.
- **Gate:** `flutter analyze --fatal-infos --fatal-warnings && flutter test` → green.

## Step 2 — Product capture

- **Do:** interview the user (idea, personas, platforms, brand direction,
  **feature list in build order**) and fill `docs/APP_OVERVIEW.md`.
- **HUMAN GATE:** user confirms APP_OVERVIEW.md.

## Step 3 — Design tokens from Figma (exact values, template's structure)

- **Act as** `skills-and-agents/agents/design-system-architect.md`;
  **read first** `skills-and-agents/skills/design-system-setup/SKILL.md`.
- **Do:**
  1. get_variable_defs / get_design_context across the whole Figma file: every
     color (light+dark), text style (family/size/weight/line-height), spacing,
     radius, icon size, elevation, motion spec.
  2. Map each value into the EXISTING structure of
     `lib/core/design_management_system/` (AppColors/AppColorTokens,
     app_typography, AppSpacing, AppDimensions, AppMotion, themes/). Reconcile —
     snap near-duplicates to one token; add a new token only for a genuinely new
     semantic role, with light AND dark variants. NEVER restructure the token
     files; only change values / add tokens.
  3. Export all icons/images via download_assets to
     `assets/icons/<module>/ic_<snake>.svg` and
     `assets/images/<module>/img_<snake>.png`; register in pubspec.yaml.
  4. Write `design/DESIGN_TOKENS.md`: sections Colors / Typography / Spacing /
     Radius & Dimensions / Motion / Icons / Images; each row
     `| Figma name | value | Dart token or asset path | used on screens |`.
- **HUMAN GATE:** show the full Figma-value → Dart-token mapping table
  (conflicts flagged) BEFORE writing any Dart file. After approval: apply, then
  `flutter analyze` + `flutter run -t lib/main_preview.dart`.
  *This 30-minute review is what makes pixel-perfect cheap downstream.*

## Step 4 — Screenshots

- **Do:** get_metadata → list every top-level frame grouped by page/module; save
  each via get_screenshot to `design/screens/<module>/<screen>.png` (snake_case,
  name = frame name).
- **Gate:** output the module → screen list; user confirms nothing is missing.

## Step 5 — User stories + navigation graph

- **Do:** generate `design/USER_STORIES.md`. Per screen (screenshot + Figma frame):

  ```markdown
  ### <module>/<screen_name>
  - Purpose: one line
  - Content: displayed data + source (API resource / local)
  - Stories: "As a user, I can …" (every visible action)
  - Actions: | trigger (tap X) | result (navigate <route> / open <sheet|dialog|toast> / API call) |
  - Overlays: every bottom sheet, dialog, popup, toast linked to this screen (named)
  - States: initial / loading / loaded-empty / loaded-populated / error
  - Entry points: which screens navigate here, with what params
  ```

  End with `## Navigation Graph` — a mermaid flowchart of the full app:
  splash → onboarding → auth → shell(bottom-nav tabs) → every push/sheet/dialog edge.
- **HUMAN GATE:** user reads and corrects. This file IS the routing spec —
  errors here become routing errors.

## Step 6 — Screen index (the one entry point for all later work)

- **Do:** generate `design/SCREEN_INDEX.md`, one row per screen:
  `| Module | Screen | Route name | Screenshot | Tokens | Stories | Status |`
  All statuses start `[DRAFT]` (discipline: DOC_TEMPLATES.md §3 — only the
  human flips a status).
- **Gate:** every screenshot from Step 4 has exactly one row.

## Step 7 — PROJECT.md (the blueprint)

- **Read first:** `DOC_TEMPLATES.md` §1.
- **Do:** generate `PROJECT.md` in the project root: §1 Identity (APP_OVERVIEW)
  · §2 Locked Stack (the template's — closed decisions) · §3 tokens pointer ·
  §4 structure pointer · §5 Data Model (from USER_STORIES content) · §6 Routes
  (from SCREEN_INDEX + navigation graph) · §7 APIs (every endpoint the stories
  imply — seeds the mock) · §8 V1 Scope · §9 EXCLUDED · §10 Open Questions ·
  §11 Decision Log.
- **HUMAN GATE (mandatory questions):** ASK — never assume — about auth
  providers, backend status (real/mock), monetization, offline needs, light/dark
  scope, platform targets, anything ambiguous. Answers → §11 / §9. User approves
  the finished PROJECT.md.

## Step 8 — TASKS.md

- **Read first:** `DOC_TEMPLATES.md` §2.
- **Do:** generate `TASKS.md` in the project root using BUILD.md's phase plan:
  Phase 0 Foundation-verify → Phase 1 Routing skeleton with dummy data →
  Phase 2 Mock backend → Phases 3…N one feature each (APP_OVERVIEW build order:
  typically auth → home tab → … → settings/profile incl. logout +
  delete-account) → Phase FINAL−1 Polish → Phase FINAL Hardening & release.
  Quick View first, Phase→Module→T-NNN, every UI task references its
  SCREEN_INDEX row, Decision Log last.
- **Gate:** Quick View counts match tasks; every SCREEN_INDEX screen appears in a task.

---

## Completion report (print this, then STOP)

```text
✅ System initialized.
   design/  : DESIGN_TOKENS.md · USER_STORIES.md · SCREEN_INDEX.md · screens/
   assets/  : icons + images exported and registered
   tokens   : design_management_system updated, preview verified
   root     : PROJECT.md · TASKS.md

Next: say "Follow developer-helper/BUILD.md — complete Phase 0"
(then Phase 1, 2, … — phase gates are enforced).
```
