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
files, app name, package/bundle ID, icon, splash). Two things specific to this
workflow:

- Set `BASE_URL=http://localhost:3000/` in `.env.development` — it'll point at
  the Phase 3 mock.
- Finish by confirming a clean state (`flutter analyze --fatal-infos
  --fatal-warnings && flutter test`) and running the dev flavor; you should see
  the template's reference auth flow working.

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
for every step are in [prompt.md](prompt.md).

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
