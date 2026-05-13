# Development Workflow

How to use Claude Code, the agents, and the skills to build features on this template.

---

## The mental model

You have **four tools** working together:

1. **`CLAUDE.md`** — Always-loaded project memory. Sets the rules.
2. **Skills** (`.claude/skills/<name>/SKILL.md`) — Specialized rule sets that load **only when relevant**. Examples: `design-system-setup`, `tdd-workflow`, `json-server-mocking`.
3. **Subagents** (`.claude/agents/<name>.md`) — Personas you explicitly invoke for a phase of work. Each one has a focused job.
4. **`docs/`** — Static reference material (the template guides + per-feature spec docs).

Skills auto-trigger based on what you're doing. Agents you summon by name (`@design-system-architect`, etc.).

---

## Phase 0 — One-time template setup

**Goal**: Get the template running with your app's identity.

1. Follow `docs/01_GETTING_STARTED.md` step-by-step:
   - Copy `.env.*` files, fill in `BASE_URL` (use `http://localhost:3000` for now — points at json-server)
   - Change app name (Android `AndroidManifest.xml`, iOS `Info.plist`)
   - Change package name / bundle ID
   - Generate app icon (`flutter_launcher_icons`)
   - Generate splash (`flutter_native_splash`)
2. Verify clean state:
   ```bash
   ./scripts/clean.sh
   flutter analyze --fatal-infos --fatal-warnings
   flutter test
   flutter run -t lib/flavors/main_development.dart
   ```

You should see the template's reference auth flow working.

---

## Phase 1 — Customize the Design System

**Goal**: Define this app's brand identity — colors, typography, spacing, motion. **Do this once, at the start, before any feature work.**

Invoke the design system architect:

```
@design-system-architect

I want to set up the design system for my app.

Brand:
- Primary color: <hex>
- Secondary color: <hex>
- Accent color: <hex>
- Brand tone: <minimal/playful/corporate/luxe>

Typography:
- Display font: <e.g., Poppins>
- Body font: <e.g., Inter>
- Font files location: <path or "needs download">

Sizing density:
- <compact / standard / comfortable>

Motion:
- <subtle / standard / expressive>
```

The agent will:
1. Update `lib/core/design_management_system/tokens/app_colors.dart` with your color tokens (light + dark variants).
2. Update `tokens/app_typography.dart` and `pubspec.yaml` fonts section.
3. Update `tokens/app_spacing.dart` and `app_dimensions.dart` if density differs from default.
4. Update `tokens/app_motion.dart` if motion preference differs.
5. Update `themes/app_color_scheme.dart` and `themes/app_theme.dart` accordingly.
6. Verify all changes compile and render correctly with the template's reference screens.

**Verify** by running and clicking through the reference auth + home screens — your new brand should be visible everywhere.

**Don't proceed until you're happy with the design system.** Every screen built later will use these tokens, so changing tokens later means visual review of everything.

---

## Phase 2 — Write the feature requirements

**Goal**: Before writing code, define what the feature *is*. One markdown file per feature in `docs/features/`.

Create `docs/features/<feature-name>.md` with:

```markdown
# Feature: Orders

## User stories
- As a user, I can see a paginated list of my past orders.
- As a user, I can tap an order to see details.
- As a user, I can cancel a pending order.

## Entities
- Order: id (String), customerName (String), totalAmount (double), status (enum), createdAt (DateTime), items (List<OrderItem>)
- OrderItem: id, productName, quantity (int), unitPrice (double)

## Endpoints (to be mocked, then real)
- GET /orders?page=1&limit=20 → paginated list
- GET /orders/:id → one order
- POST /orders → create
- PATCH /orders/:id { status: "cancelled" } → cancel
- DELETE /orders/:id → delete

## Screens
- OrdersListScreen — list with pull-to-refresh, infinite scroll
- OrderDetailScreen — view + cancel button
- (Optional) CreateOrderScreen — form

## Edge cases
- Empty list → "No orders yet" with CTA
- Network error → retry button
- Cancellation while offline → queue mutation
```

Keep it terse. This doc is the **contract** that the next phases build against.

---

## Phase 3 — Mock the backend with json-server

**Goal**: A working HTTP API you can hit from your Flutter dev build, with zero backend dependency.

Invoke the mock-backend-builder:

```
@mock-backend-builder

Build a json-server mock for the Orders feature.
Spec is in docs/features/orders.md.
```

The agent will:
1. Update `mock_server/db.json` with realistic seed data matching the entities.
2. Update `mock_server/routes.json` to match the REST conventions used by `DioClient`.
3. Add custom middleware if the spec needs auth headers, pagination wrapping, or error simulation.
4. Update the npm scripts in `mock_server/package.json` so you can run `npm run mock` from there.
5. Verify the endpoints with `curl` and update `.env.development` so `BASE_URL=http://localhost:3000`.

Run the mock server:
```bash
cd mock_server
npm install   # first time only
npm run mock
```

Now your dev Flutter app can hit a working API. Test endpoints with curl or Postman before proceeding.

---

## Phase 4 — TDD: write the tests first

**Goal**: Before any implementation, write the test suite that defines correct behavior. Tests fail at first; that's the point.

The `tdd-workflow` skill auto-activates when Claude detects test files. Just ask:

```
Build tests for the Orders feature following TDD.
Use docs/features/orders.md as the spec.
Don't write implementation yet — only tests that should fail right now.
```

Claude will scaffold:
- `test/features/dlt_orders/data/models/order_model_test.dart` — all edge cases (null, wrong types, missing fields, enum fallback, round-trip, toEntity)
- `test/features/dlt_orders/domain/usecases/get_orders_usecase_test.dart` — success + failure paths
- `test/features/dlt_orders/presentation/bloc/orders_bloc_test.dart` — every event → state sequence with `bloc_test`
- `test/features/dlt_orders/presentation/pages/orders_screen_test.dart` — all four widget states (initial, loading, empty, populated, error) + retry interaction
- `integration_test/orders_flow_test.dart` — end-to-end happy path

Run them to confirm they all fail:
```bash
flutter test
```

Red is good. Now you have an executable spec.

---

## Phase 5 — Implementation: make the tests pass

**Goal**: Build the feature layer by layer, watching tests turn green.

Use the **flutter-template-core** skill (auto-activates) and work in this order:

### 5a. Domain layer

```
Implement the Orders domain layer (entity, repository interface, use cases) per docs/features/orders.md.
Tests at test/features/dlt_orders/domain/ should turn green.
```

### 5b. Data layer

```
Implement the Orders data layer (model with JsonParseUtils, remote datasource, repository impl using safeApiCall).
Tests at test/features/dlt_orders/data/ should turn green.
Run ./scripts/codegen.sh after model is in place.
```

### 5c. Presentation layer

```
Implement the Orders BLoC (events, states, handlers with droppable/sequential transformers from bloc_concurrency).
Test at test/features/dlt_orders/presentation/bloc/ should turn green.
```

### 5d. UI

```
Implement OrdersScreen and OrdersView per the test expectations.
Handle all four states. Use design system tokens only.
Test at test/features/dlt_orders/presentation/pages/ should turn green.
```

### 5e. Routing

```
Add the Orders routes to lib/core/router/ (paths, names, GoRoute definitions).
Integration test should turn green.
```

After each layer:
```bash
./scripts/codegen.sh   # if you added annotations
flutter analyze --fatal-infos --fatal-warnings
flutter test
```

**Hard rule**: Don't move to the next layer until all tests in the previous layer pass.

---

## Phase 6 — UI polish & performance

**Goal**: Take the working feature from "passes tests" to "delightful and fast."

Invoke the polish specialist:

```
@ui-polish-specialist

Polish the Orders feature.
Add animations, micro-interactions, and verify 60fps in profile mode.
```

The agent will:
1. Add purposeful animations (list item entrance, hero on tap-to-detail, button press scale).
2. Add empty/error illustrations.
3. Audit for `const` constructors, `ListView.builder` + `itemExtent`, `RepaintBoundary` wraps, `BlocSelector` for narrow rebuilds.
4. Run profile-mode build, instruct you on what to watch in DevTools.
5. Verify accessibility: tooltips, semantics labels, contrast, 200% text scale.
6. Run `flutter build appbundle --analyze-size` and flag any large dependencies.

**Verify** by running in profile mode on a physical mid-range device:
```bash
flutter run --profile -t lib/flavors/main_production.dart
```

Open DevTools Performance tab. Scroll the list. Confirm < 8ms frame build, < 8ms frame raster.

---

## Phase 7 — Swap mock for real backend

When the real backend is ready:

1. Update `.env.development` `BASE_URL` to point at the real backend.
2. Compare response shapes — if any differ from the mock, update the model's `JsonParseUtils` converters or `OrderModel`'s field names. **You shouldn't need to touch domain or presentation layers.**
3. Re-run the test suite. Update fixtures if response wrapping is now different (e.g., real backend wraps in `{ "data": [...] }` but mock didn't).
4. Update integration tests to use the real backend (or keep them pointed at mock for CI determinism — recommended).

If the swap requires more than `.env` + model tweaks, **you violated the architecture**. Trace what leaked through and fix it.

---

## Invoking agents — examples

```
@design-system-architect
Set up the design system. Primary #4A6FFF, secondary #FF6B6B, font Inter, comfortable density.
```

```
@mock-backend-builder
Build endpoints for the Profile feature. Spec in docs/features/profile.md.
```

```
@feature-developer
Build the entire Orders feature TDD-style per docs/features/orders.md.
Don't write a single line of production code until tests are in place.
```

```
@ui-polish-specialist
Polish the Profile feature. Target 60fps on a 2019 mid-range device.
```

---

## Loop the cycle per feature

For each new feature: write the spec (phase 2), mock the endpoints (3), TDD the tests (4), implement (5), polish (6). Repeat.

Once 3–5 features are stable, you'll move much faster — the agents have all the context they need from `CLAUDE.md` + the skills, and patterns are well-grooved.

---

## Common pitfalls

| Pitfall | Fix |
|---|---|
| Skipping TDD because "I know what I want" | Tests are the spec. Without them, you have no way to verify the swap-to-real-backend doesn't break things. |
| Editing the design system mid-feature | Always Phase 1 first. Mid-feature changes mean visual review of every prior screen. |
| Writing implementation before all tests are in place | Defeats the point. Write all failing tests first, then implement. |
| Polishing before tests pass | You'll add animation around buggy logic. Make it work, then make it nice. |
| Using `sl<T>()` "just for this one widget" | It compounds. The lint will catch it eventually; the architecture won't survive. |

---

## When something feels wrong

If you find yourself wanting to write code that contradicts CLAUDE.md or a SKILL.md, **stop**. One of these is true:
1. The rules are wrong for this situation → discuss and update the relevant skill.
2. The situation isn't what you think → re-read the rule and look for the existing pattern.

Don't silently break the architecture. The whole point of this setup is consistency.
