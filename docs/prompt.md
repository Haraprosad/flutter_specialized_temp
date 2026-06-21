# Prompts — Figma design → working screen

Copy-paste prompts for turning a Figma design into a production-ready feature on
this template. They enforce the rules in [../CLAUDE.md](../CLAUDE.md) and follow
the phases in [00_WORKFLOW.md](00_WORKFLOW.md) → "Design-to-code".

**Conventions for the placeholders below**

- `<feature_name>` — singular snake_case, e.g. `order`, `wallet`, `profile`.
- `<screenshot>` — path to the design image you dragged into the chat
  (e.g. `design/wallet_home.png`), or just attach it.
- `<tokens_file>` — path to the exported Figma tokens (e.g. `design/tokens.json`).

Run them **in order**. Skip Prompt 1 if the screen needs no new design tokens.

> **Before any prompt below:** capture the product idea in
> [APP_OVERVIEW.md](APP_OVERVIEW.md) (Prompt 0). It drives the brand brief in
> Prompt 1 and the per-feature specs in Prompt 2.

---

## Prompt 0 — Capture the app idea (once, before everything)

> Do this first. It's the product-level source of truth the later prompts read.

```
I'm starting a new app on this template. Help me fill in docs/APP_OVERVIEW.md:

Idea: <one paragraph — what the app is, who it's for, the problem it solves>
Brand: primary <#hex>, accent <#hex>, font <family>, feel <snappy/smooth>
Features I want, in build order: <feature 1>, <feature 2>, ...

Draft docs/APP_OVERVIEW.md from the template already in that file. Don't write
any code or feature specs yet — just the overview for me to confirm.
```

---

## Prompt 1 — Reconcile Figma tokens into the design system (only if needed)

> Use this once per brand, or when a screen genuinely introduces a new token.
> Most screens reuse existing tokens — skip this if so.

```
@design-system-architect

I exported design tokens from Figma at <tokens_file>.

Reconcile them into lib/core/design_management_system/ — do NOT blindly
overwrite or append:
- Map each value to the nearest EXISTING token and reuse it.
- Add a new token only for a genuinely new semantic role (not a one-off pixel
  value), with both light and dark variants.
- List any conflicts (incoming value close-but-not-equal to an existing token)
  and ask me before changing them.

Show me the mapping (incoming → existing token, plus any proposed new tokens)
for approval BEFORE writing files. Then verify with:
flutter analyze --fatal-infos --fatal-warnings and flutter run -t lib/main_preview.dart
```

---

## Prompt 2 — Derive the feature spec from the screenshot

> A screenshot shows one state, not a spec. Get the contract on paper first.

```
Here is a Figma screenshot of the <feature_name> screen: <screenshot>

Read it and draft docs/features/<feature_name>.md following the template in
docs/00_WORKFLOW.md (Phase 2). Infer from the image:
- Entities and their fields (with types) visible or implied
- The screen(s) and the reusable widget pieces
- The REST endpoints implied (list/detail/create/update/delete as relevant)
- ALL async states to handle: initial, loading, loaded-empty,
  loaded-populated, error — not just the populated state shown

Don't write any code yet. Show me the spec so I can confirm/correct it.
```

---

## Prompt 3 — Build the feature end-to-end (mock → BDD → all layers → screen)

> The main prompt. Produces a fully working, tested screen.

```
@feature-developer

Build the <feature_name> feature from this design: <screenshot>
Spec: docs/features/<feature_name>.md. Follow CLAUDE.md exactly.

1. MOCK (Phase 3): seed mock/db.json (+ db.seed.json) with realistic data so the
   screen renders every state via the existing switches — filled (default),
   empty (?_state=empty), error (?_state=error), loading (?_delay=1500).

2. BEHAVIOR SPECS FIRST (Phase 4): write the behavior specification suite under
   test/features/<feature_name>/ mirroring lib/ — model scenarios
   (Given/When/Then), use case behaviors, bloc state flows, widget interactions
   (all four states + retry), and an integration happy path. Confirm all specs
   FAIL. Do not write implementation yet.

3. IMPLEMENT to green (Phase 5), layer by layer:
   - domain/   : entity (Equatable, no Flutter/Dio), repository interface,
                 use case(s) (@injectable)
   - data/     : model (@freezed + JsonParseUtils converters + toEntity()),
                 datasource, repository impl extending BaseApiRepository with
                 safeApiCall → ApiResult<T>. Run ./scripts/codegen.sh after the model.
   - presentation/
       bloc/   : events/states; handler switches exhaustively on ApiResult;
                 bloc_concurrency transformers
       pages/  : <feature_name>_screen.dart — ONLY composes sections + wires
                 BlocBuilder, rendering all states (initial, loading, empty,
                 populated, error). The page is a thin assembler — it must NOT
                 contain hundreds of lines of inline widget tree.
       widgets/: every section of the screen is its own widget file here
                 (header, list item, filter bar, empty-state, ... — one concept
                 per file). If a chunk of the page has a name, it's a widget.
   - routing  : register the route in lib/core/router/

Hard rules (stop and fix if any is at risk):
- Constructor injection only — never sl<T>() in bloc/usecase/repo/datasource.
- Every UI value is a design token (AppSpacing.*, context.colors.*,
  context.textTheme.*, AppDimensions.*). NO raw px/hex/strings.
- Snap design values to the nearest token; if one is missing, tell me — don't
  hardcode to match the screenshot.
- All user-facing text via context.loc.<key> (add ARB keys).
- Accessibility: tooltip on every IconButton, Semantics labels, ≥48×48 targets,
  survives 200% text scale.
- Responsive via flutter_screenutil; long lists use ListView.builder + itemExtent.

After each layer run: flutter analyze --fatal-infos --fatal-warnings and the
layer's tests. Don't advance until the previous layer is green.
```

---

## Prompt 4 — Match the design + polish (Phase 6)

```
@ui-polish-specialist

Polish the <feature_name> screen to match the design: <screenshot>

- Bring it to visual fidelity using ONLY design tokens (snap, don't hardcode).
- Give empty / loading / error states intentional treatment derived from the
  design system (the screenshot only shows the populated state).
- Add purposeful motion using app_motion.dart tokens (entrance, tap-to-detail,
  press feedback, skeleton on load).
- Performance: const, ListView.builder + itemExtent, RepaintBoundary,
  BlocSelector/buildWhen for narrow rebuilds.
- Verify against the mock and in lib/main_preview.dart across phone/tablet, and
  in profile mode target 60fps (frame build < 8ms, raster < 8ms).
```

---

## Run the mock while testing the screen

From the **project root** (see [../mock/README.md](../mock/README.md)):

```bash
npm install        # first time only
npm run mock       # http://localhost:3000
flutter run -t lib/flavors/main_development.dart   # BASE_URL=http://localhost:3000/
```

## Done checklist (the quality gates from CLAUDE.md)

- [ ] `flutter analyze --fatal-infos --fatal-warnings` → zero issues
- [ ] `flutter test` + `flutter test integration_test` → green
- [ ] All four async states render (asserted in widget tests)
- [ ] No raw color / spacing / string literals; no `sl<T>()` in bloc/usecase/repo
- [ ] Accessibility (tooltips, 48×48, 200% text) and responsive (preview) verified
- [ ] Screen matches the Figma design
