# The Workflow — How to Build an App on This Template

This is the **canonical runbook**. Read it once, then follow it phase by phase.
It ties together the reference guides (`01`–`06`), the mock API, and the Claude
Code agents/skills under `.claude/`.

> New here? Read this top to bottom once. Then for each feature you build, you'll
> loop Phases 2 → 6.

---

## The mental model

Four things work together:

1. **`CLAUDE.md`** (repo root) — always-loaded project memory. The rulebook
   (the 12 non-negotiables, the phase order). Loads on every conversation.
2. **Skills** — `.claude/skills/<name>/SKILL.md`. Focused rule sets that
   auto-activate when relevant (talking about models/tests/tokens triggers the
   right one). You don't summon them.
3. **Agents** — `.claude/agents/<name>.md`. Specialist personas you summon by
   name for a phase of work (e.g. `@design-system-architect`).
4. **`docs/`** — static reference (this runbook + the numbered guides + your
   per-feature specs in `docs/features/`).

| Agent (summon by name) | Phase | Auto-loaded skill(s) |
|---|---|---|
| `@design-system-architect` | 1 | `design-system-setup` |
| `@mock-backend-builder` | 3 | `json-server-mocking` |
| `@feature-developer` | 4–5 | `bdd-workflow`, `flutter-template-core` |
| `@ui-polish-specialist` | 6 | `ui-polish-performance` |

---

## Phase 0 — One-time template setup

**Goal:** get the template running with your app's identity.

Follow [01_GETTING_STARTED.md](01_GETTING_STARTED.md) for the full steps (env
files, app name, package/bundle ID, icon, splash). Before moving on, capture the
product idea in [APP_OVERVIEW.md](APP_OVERVIEW.md) — it's the product-level
source of truth that feeds the Phase 1 brand brief and the Phase 2 feature specs.
Two things specific to this workflow:

- Set `BASE_URL=http://localhost:3000/` in `.env.development` — it'll point at
  the Phase 3 mock.
- Finish by confirming a clean state (`flutter analyze --fatal-infos
  --fatal-warnings && flutter test`) and running the dev flavor; you should see
  the template's reference auth flow working.

> **From a Figma design?** Copy-paste prompt to capture the product idea first
> (placeholder conventions are listed under "Copy-paste prompts" at the end):
>
> ```text
> I'm starting a new app on this template. Help me fill in docs/APP_OVERVIEW.md:
>
> Idea: <one paragraph — what the app is, who it's for, the problem it solves>
> Brand: primary <#hex>, accent <#hex>, font <family>, feel <snappy/smooth>
> Features I want, in build order: <feature 1>, <feature 2>, ...
>
> Draft docs/APP_OVERVIEW.md from the template already in that file. Don't write
> any code or feature specs yet — just the overview for me to confirm.
> ```

---

## Phase 1 — Customize the design system (once, first)

**Goal:** define this app's brand — colors, typography, spacing, motion —
**before any feature work**, because every screen will consume these tokens.

Summon the architect with your brand brief:

```
@design-system-architect

Set up the design system for my app.
- Primary #4A6FFF, secondary #FF6B6B, accent #FFC857
- Brand tone: minimal
- Display font: Poppins, body font: Inter (Google Fonts)
- Density: comfortable
- Motion: subtle
```

It edits the token + theme files under
`lib/core/design_management_system/` and `pubspec.yaml` fonts, then verifies in
preview (`flutter run -t lib/main_preview.dart`). **Don't proceed until you're
happy** — changing tokens later means re-reviewing every screen.

Reference: [04_DESIGN_SYSTEM.md](04_DESIGN_SYSTEM.md).

> **From a Figma design?** If you exported tokens, reconcile them instead of
> hand-writing the brief above — don't blindly overwrite or append:
>
> ```text
> @design-system-architect
>
> I exported design tokens from Figma at <tokens_file>.
>
> Reconcile them into lib/core/design_management_system/ — do NOT blindly
> overwrite or append:
> - Map each value to the nearest EXISTING token and reuse it.
> - Add a new token only for a genuinely new semantic role (not a one-off pixel
>   value), with both light and dark variants.
> - List any conflicts (incoming value close-but-not-equal to an existing token)
>   and ask me before changing them.
>
> Show me the mapping (incoming → existing token, plus any proposed new tokens)
> for approval BEFORE writing files. Then verify with:
> flutter analyze --fatal-infos --fatal-warnings and flutter run -t lib/main_preview.dart
> ```

---

## Phase 2 — Write the feature spec

**Goal:** define what the feature *is* before any code. One file per feature in
`docs/features/<name>.md`. This is the contract the next phases build against.

```markdown
# Feature: Orders

## User stories
- As a user, I can see a paginated list of my past orders.
- As a user, I can tap an order to see details, and cancel a pending one.

## Entities
- Order: id (String), customerName (String), totalAmount (double),
  status (enum), createdAt (DateTime), items (List<OrderItem>)
- OrderItem: id, productName, quantity (int), unitPrice (double)

## Endpoints (mocked first, then real)
- GET /orders?_page=1&_limit=20   → paginated list
- GET /orders/:id                 → one order
- POST /orders                    → create
- PATCH /orders/:id { status }    → cancel
- DELETE /orders/:id              → delete

## Screens
- OrdersListScreen — pull-to-refresh, infinite scroll
- OrderDetailScreen — view + cancel
- (optional) CreateOrderScreen — form

## Edge cases
- Empty list → "No orders yet" + CTA
- Network error → retry
```

Keep it terse.

> **From a Figma design?** Derive the spec from the screenshot instead of writing
> it by hand:
>
> ```text
> Here is a Figma screenshot of the <feature_name> screen: <screenshot>
>
> Read it and draft docs/features/<feature_name>.md following the template above.
> Infer from the image:
> - Entities and their fields (with types) visible or implied
> - The screen(s) and the reusable widget pieces
> - The REST endpoints implied (list/detail/create/update/delete as relevant)
> - ALL async states to handle: initial, loading, loaded-empty,
>   loaded-populated, error — not just the populated state shown
>
> Don't write any code yet. Show me the spec so I can confirm/correct it.
> ```

---

## Phase 3 — Mock the backend

**Goal:** a working HTTP API your dev build can hit, matching the real response
contract — zero backend dependency.

```
@mock-backend-builder

Build a json-server mock for the Orders feature.
Spec is in docs/features/orders.md.
```

It seeds `mock/db.json` (+ `mock/db.seed.json`) and verifies endpoints. Run it
from the **project root**:

```bash
npm install        # first time only
npm run mock       # http://localhost:3000
npm run mock:reset # restore seed data after mutating runs
```

Point the app at it via `.env.development` (`BASE_URL=http://localhost:3000/`;
emulator host differs — see [../mock/README.md](../mock/README.md)). The mock
also lets you force **empty / error / loading** states per request — the full
table is in [../mock/README.md](../mock/README.md).

> **From a Figma design?** A single brief drives Phases 3→5 — mock, behavior specs
> first, then all layers to a working screen:
>
> ```text
> @feature-developer
>
> Build the <feature_name> feature from this design: <screenshot>
> Spec: docs/features/<feature_name>.md. Follow CLAUDE.md exactly.
>
> 1. MOCK (Phase 3): seed mock/db.json (+ db.seed.json) with realistic data so the
>    screen renders every state via the existing switches — filled (default),
>    empty (?_state=empty), error (?_state=error), loading (?_delay=1500).
>
> 2. BEHAVIOR SPECS FIRST (Phase 4): write the behavior specification suite under
>    test/features/<feature_name>/ mirroring lib/ — model scenarios
>    (Given/When/Then), use case behaviors, bloc state flows, widget interactions
>    (all four states + retry), and an integration happy path. Confirm all specs
>    FAIL. Do not write implementation yet.
>
> 3. IMPLEMENT to green (Phase 5), layer by layer:
>    - domain/   : entity (Equatable, no Flutter/Dio), repository interface,
>                  use case(s) (@injectable)
>    - data/     : model (@freezed + JsonParseUtils converters + toEntity()),
>                  datasource, repository impl extending BaseApiRepository with
>                  safeApiCall → ApiResult<T>. Run ./scripts/codegen.sh after the model.
>    - presentation/
>        bloc/   : events/states; handler switches exhaustively on ApiResult;
>                  bloc_concurrency transformers
>        pages/  : <feature_name>_screen.dart — ONLY composes sections + wires
>                  BlocBuilder, rendering all states (initial, loading, empty,
>                  populated, error). The page is a thin assembler — it must NOT
>                  contain hundreds of lines of inline widget tree.
>        widgets/: every section of the screen is its own widget file here
>                  (header, list item, filter bar, empty-state, ... — one concept
>                  per file). If a chunk of the page has a name, it's a widget.
>    - routing  : register the route in lib/core/router/
>
> Hard rules (stop and fix if any is at risk):
> - Constructor injection only — never sl<T>() in bloc/usecase/repo/datasource.
> - Every UI value is a design token (AppSpacing.*, context.colors.*,
>   context.textTheme.*, AppDimensions.*). NO raw px/hex/strings.
> - Snap design values to the nearest token; if one is missing, tell me — don't
>   hardcode to match the screenshot.
> - All user-facing text via context.loc.<key> (add ARB keys).
> - Accessibility: tooltip on every IconButton, Semantics labels, ≥48×48 targets,
>   survives 200% text scale.
> - Responsive via flutter_screenutil; long lists use ListView.builder + itemExtent.
>
> After each layer run: flutter analyze --fatal-infos --fatal-warnings and the
> layer's tests. Don't advance until the previous layer is green.
> ```

---

## Phase 4 — BDD: write the behavior specs first

**Goal:** the behavior specification suite that defines correct system behavior.
Specs should fail — that is the point.

```
Build behavior specs for the Orders feature following BDD, using docs/features/orders.md
as the spec. Don't write implementation yet — only scenarios that should fail now.
```

`@feature-developer` (with the `bdd-workflow` skill) scaffolds, mirroring `lib/`:

- `test/features/orders/data/models/order_model_test.dart` — behavior
  scenarios (Given valid/null/wrong-type JSON → When parsing → Then correct
  defaults, round-trip, `toEntity` mapping)
- `.../domain/usecases/get_orders_usecase_test.dart` — Given success/failure →
  When called → Then correct `ApiResult`
- `.../presentation/bloc/orders_bloc_test.dart` — Given initial state → When
  event → Then state sequence, with `bloc_test`
- `.../presentation/pages/orders_screen_test.dart` — Given each async state →
  When rendered → Then correct UI + retry interaction
- `integration_test/orders_flow_test.dart` — Given app launched → When user
  navigates → Then happy path completes

```bash
flutter test     # confirm all specs FAIL
```

---

## Phase 5 — Implement to green, layer by layer

**Goal:** make tests pass, domain → data → presentation → routing. The
`feature-developer` agent (with `flutter-template-core`) drives this.

1. **Domain** — entity (`Equatable`), repository interface, use cases.
2. **Data** — model (`@freezed` + `JsonParseUtils` + `toEntity()`), datasource,
   repository impl extending `BaseApiRepository` with `safeApiCall` →
   `ApiResult<T>`. Run `./scripts/codegen.sh` after the model.
3. **Presentation** — BLoC (exhaustive `switch` on `ApiResult`,
   `bloc_concurrency` transformers), then pages/widgets (design tokens only, all
   four states).
4. **Routing** — paths/names/`GoRoute` in `lib/core/router/`.

After each layer:
```bash
./scripts/codegen.sh                              # if annotations changed
flutter analyze --fatal-infos --fatal-warnings
flutter test
```

**Hard rule:** don't advance a layer until the previous layer's tests are green.
Full code-level detail: [03_FEATURE_GUIDE.md](03_FEATURE_GUIDE.md),
[05_TESTING.md](05_TESTING.md).

---

## Phase 6 — UI polish & performance

**Goal:** from "passes tests" to "delightful and fast."

```
@ui-polish-specialist

Polish the Orders feature. Add animations and micro-interactions, give empty/
error states real treatment, and verify 60fps in profile mode on a mid-range
device.
```

Verify on a physical device:
```bash
flutter run --profile -t lib/flavors/main_production.dart
```
DevTools → Performance: target frame build < 8 ms, raster < 8 ms.

> **From a Figma design?** Polish to match the screenshot — tokens only, all
> states intentional:
>
> ```text
> @ui-polish-specialist
>
> Polish the <feature_name> screen to match the design: <screenshot>
>
> - Bring it to visual fidelity using ONLY design tokens (snap, don't hardcode).
> - Give empty / loading / error states intentional treatment derived from the
>   design system (the screenshot only shows the populated state).
> - Add purposeful motion using app_motion.dart tokens (entrance, tap-to-detail,
>   press feedback, skeleton on load).
> - Performance: const, ListView.builder + itemExtent, RepaintBoundary,
>   BlocSelector/buildWhen for narrow rebuilds.
> - Verify against the mock and in lib/main_preview.dart across phone/tablet, and
>   in profile mode target 60fps (frame build < 8ms, raster < 8ms).
> ```

---

## Phase 7 — Swap the mock for the real backend

When the real backend is ready:

1. Update `.env.development` `BASE_URL` to the real API.
2. Compare response shapes; if any differ, fix only the model's `JsonParseUtils`
   converters / field names. **Domain and presentation should not change.**
3. Re-run the suite; update fixtures if the envelope wrapping changed.

If the swap needs more than `.env` + model tweaks, the architecture leaked —
trace what crossed a layer boundary and fix it.

---

## Loop per feature

For each new feature: spec (2) → mock (3) → BDD (4) → implement (5) → polish (6).
Build one feature fully before starting the next — don't parallelize.

### Suggested order

```
1. auth   (in template — customize to your flow)
2. home   (landing after login)
3. <core feature 1>
4. <core feature 2>
...
N. profile (settings, logout)
```

---

## Design-to-code: building a screen from a Figma design

A common entry point: a designer has a Figma screen and wants it built as a
real, working feature. This is **not a new phase** — it's the normal phase
1→6 flow, *seeded by a design instead of a written spec*. Copy-paste prompts
for every step are in [Copy-paste prompts](#copy-paste-prompts-figma-design-to-working-screen)
at the end of this file.

The naïve version ("export tokens → screenshot → tell Claude to build the
screen") works, but skips the things that separate a throwaway mockup from
production code. Do it like this:

### Step 1 — Reconcile tokens (don't dump them)

Export tokens from Figma (e.g. Tokens Studio / "Design Tokens" plugin), but
**reconcile, don't overwrite.** The design system in
`lib/core/design_management_system/` is the single source of truth and is set
**once** in Phase 1.

- Map each Figma value to the **nearest existing token**.
- Add a new token only when the screen introduces a genuinely new *semantic*
  role (not a one-off pixel value), and add it to both light and dark.
- Never let a screen silently fork the palette/scale — that's how token drift
  and duplication creep back in.

Use `@design-system-architect` for this; if the screen needs **no** new tokens,
skip straight to Step 2.

### Step 2 — Derive a feature spec from the screenshot

A screenshot is a picture of **one state**, not a spec. Have Claude read the
screenshot and propose `docs/features/<name>.md` — entities/fields it can see,
the screens, the endpoints implied, and **all** async states (not just the one
shown). You confirm/correct it. This is Phase 2.

### Step 3 — Mock all states (Phase 3)

Seed `mock/db.json` so the screen can render every state via the existing
switches: filled (default), empty (`?_state=empty`), error (`?_state=error`),
loading (`?_delay=1500`). See [../mock/README.md](../mock/README.md).

### Step 4 — BDD, then implement (Phases 4–5)

Behavior specs first — even from a visual. Then implement layer by layer with
`@feature-developer`. The screen splits exactly as you described:

```
features/<name>/
├── domain/        entities, repository interface, use cases
├── data/          model (+ JsonParseUtils), datasource, repository impl
└── presentation/
    ├── bloc/      events / states / handler logic
    ├── pages/     <name>_screen.dart   ← the full screen (composition + BlocBuilder)
    └── widgets/   the reusable pieces of that screen
```

Then register the route in `lib/core/router/`.

### Step 5 — Match the design, then polish (Phase 6)

`@ui-polish-specialist` brings it to visual fidelity and 60fps. Two rules that
keep it production-grade:

- **Token fidelity beats pixel fidelity.** If a screenshot value doesn't map to
  a token, snap to the nearest token — never hardcode a raw px/hex to match the
  picture. A value you *can't* express is a signal to add a token (back to
  Step 1), decided deliberately.
- The screenshot usually shows only the filled state. Design empty / loading /
  error from the design system so all states feel intentional.

### What the naïve flow misses (the improvements)

| Gap in "screenshot → build it" | What to do instead |
|---|---|
| Dumping Figma tokens into the design system every screen | Reconcile to existing tokens; add new ones only for new semantic roles (Step 1) |
| Treating the screenshot as the spec | Derive & confirm `docs/features/<name>.md` first (Step 2) |
| Only "empty / fail / filled" | Cover **all** states: initial, loading, loaded-empty, loaded-populated, error |
| Jumping straight to implementation | Keep BDD — behavior specs are the contract for the later real-backend swap |
| Hardcoding px/hex to match the picture | Snap to tokens; no raw literals (non-negotiable #7) |
| Hardcoded visible text | Extract to ARB, use `context.loc.<key>` |
| "Looks right on my screen" | Verify responsive (`lib/main_preview.dart`) + accessibility (tooltips, 48×48, 200% text) |
| Done when it compiles | Done when quality gates pass (`flutter analyze` + `flutter test`) and it matches the design |

---

## Common pitfalls

| Pitfall | Fix |
|---|---|
| Skipping BDD ("I know what I want") | Behavior specs are the living documentation and the safety net for the backend swap. |
| Editing the design system mid-feature | Always Phase 1 first; mid-feature changes mean re-reviewing every prior screen. |
| Writing implementation before all specs exist | Write all behavior specs first, then implement. |
| Polishing before tests pass | You'll animate around bugs. Make it work, then make it nice. |
| `sl<T>()` "just this once" | It compounds and breaks the architecture. Constructor injection only. |
| Mock vs real backend envelope mismatch | Fix only the `DataSource`/model parsing — never the BLoC or UI. |

## When something feels wrong

If you're about to write code that contradicts `CLAUDE.md` or a skill, **stop**.
Either the rule is wrong for this case (discuss and update the skill) or the
situation isn't what you think (re-read the rule, find the existing pattern).
Don't silently break the architecture — consistency is the whole point.

---

## Copy-paste prompts: Figma design to working screen

The copy-paste prompts now live **inline in each phase above** — each phase has a
> **From a Figma design?** callout with the exact prompt for that step. They
enforce the rules in [../CLAUDE.md](../CLAUDE.md). This section is just the index,
the shared placeholder conventions, and the run/verify steps.

**Placeholder conventions (used in every prompt above)**

- `<feature_name>` — singular snake_case, e.g. `order`, `wallet`, `profile`.
- `<screenshot>` — path to the design image you dragged into the chat
  (e.g. `design/wallet_home.png`), or just attach it.
- `<tokens_file>` — path to the exported Figma tokens (e.g. `design/tokens.json`).

Run the prompts **in phase order**. Skip the Phase 1 token prompt if the screen
needs no new design tokens.

| Prompt | Lives in | What it does |
|---|---|---|
| Capture the app idea | [Phase 0](#phase-0--one-time-template-setup) | Draft `docs/APP_OVERVIEW.md` (once, before everything) |
| Reconcile Figma tokens | [Phase 1](#phase-1--customize-the-design-system-once-first) | Map exported tokens to existing ones (only if needed) |
| Derive the feature spec | [Phase 2](#phase-2--write-the-feature-spec) | Turn a screenshot into `docs/features/<name>.md` |
| Build end-to-end | [Phase 3](#phase-3--mock-the-backend) | One brief: mock → BDD → all layers → screen (Phases 3→5) |
| Match design + polish | [Phase 6](#phase-6--ui-polish--performance) | Visual fidelity, motion, 60fps |

### Run the mock while testing the screen

From the **project root** (see [../mock/README.md](../mock/README.md)):

```bash
npm install        # first time only
npm run mock       # http://localhost:3000
flutter run -t lib/flavors/main_development.dart   # BASE_URL=http://localhost:3000/
```

### Done checklist (the quality gates from CLAUDE.md)

- [ ] `flutter analyze --fatal-infos --fatal-warnings` → zero issues
- [ ] `flutter test` + `flutter test integration_test` → green
- [ ] All four async states render (asserted in widget tests)
- [ ] No raw color / spacing / string literals; no `sl<T>()` in bloc/usecase/repo
- [ ] Accessibility (tooltips, 48×48, 200% text) and responsive (preview) verified
- [ ] Screen matches the Figma design
