# Step-by-Step Development Guide

A precise, ordered guide for using Claude Code with this file structure.

---

## Part 1 — One-Time Project Setup

### Step 1 — Copy `.claude/` into your project root

```
your_flutter_project/
├── CLAUDE.md                  ← copy here
├── .claude/
│   ├── agents/
│   │   ├── DESIGN_SYSTEM_AGENT.md
│   │   ├── FEATURE_AGENT.md
│   │   ├── JSON_SERVER_AGENT.md
│   │   └── TDD_AGENT.md
│   ├── memory/
│   │   ├── PROJECT_STATE.md
│   │   ├── DESIGN_DECISIONS.md
│   │   └── FEATURE_REGISTRY.md
│   ├── context/
│   │   ├── ARCHITECTURE.md
│   │   └── CONVENTIONS.md
│   └── skills/
│       ├── FLUTTER_TEMPLATE.md   ← paste your existing skill.md here
│       ├── DESIGN_SYSTEM.md
│       ├── JSON_SERVER.md
│       └── TDD.md
└── lib/  ...
```

### Step 2 — Fill in `CLAUDE.md` fields

Open `CLAUDE.md` and fill:
- App Name
- Package Name
- Current Phase: `DESIGN_SYSTEM_SETUP`

### Step 3 — Open Claude Code

```bash
cd your_flutter_project
claude   # or however you start Claude Code
```

Claude Code will automatically read `CLAUDE.md` on startup. You will see it acknowledge the project.

---

## Part 2 — Design System (do this ONCE, first)

### Step 4 — Invoke the Design System Agent

In Claude Code, type:

```
@agent design-system
```

Claude will read `.claude/agents/DESIGN_SYSTEM_AGENT.md` and ask you:

```
Please provide:
1. Primary color (hex)
2. Secondary color (hex)
3. Font family name
4. Base spacing unit (default: 4)
5. Border radius style: sharp / rounded / pill
6. Dark mode: yes / no / system
...
```

### Step 5 — Answer the questions

Example response:
```
1. #6366F1
2. #EC4899
3. Inter (Google Fonts)
4. 4
5. rounded
6. yes (dark mode supported)
```

### Step 6 — Review and approve

Claude will show you computed token values (light/dark colors, spacing scale) before writing files. Review and say:

```
Looks good, proceed.
```

Or:
```
Make primary slightly lighter — try #818CF8 instead.
```

### Step 7 — Let Claude write the token files

Claude writes:
- `tokens/app_colors.dart`
- `tokens/app_typography.dart`
- `tokens/app_spacing.dart`
- `tokens/app_dimensions.dart`
- `tokens/app_motion.dart`
- `themes/app_color_scheme.dart`
- `themes/app_theme.dart`
- Updates `pubspec.yaml` fonts section

Then Claude runs:
```bash
flutter analyze
flutter run -t lib/main_preview.dart
```

### Step 8 — Visual check in preview mode

Look at the running app in preview mode across device sizes. If anything looks wrong, tell Claude:

```
The body text is too small on phone. Increase bodyMedium to 15sp.
```

### Step 9 — Confirm completion

Once happy, say:
```
Design system looks good. Mark it complete.
```

Claude updates `.claude/memory/DESIGN_DECISIONS.md` and `CLAUDE.md` phase to `FEATURE_DEV`.

---

## Part 3 — Building a Feature (repeat for each feature)

The sequence is always: **Mock API → Tests → Implementation → UI Polish**

### Step 10 — Define your feature requirements

Write a requirements note. Example:

```
Feature: Orders
- User can view a paginated list of orders
- Each order shows: customer name, total amount, status badge
- User can pull to refresh
- User can delete an order (with confirmation dialog)
- User can tap an order to see detail screen
- Error state with retry button
- Empty state with illustration
```

Keep this in a scratch note. You'll paste it to Claude in the next step.

---

### Step 11 — Create the Mock API

In Claude Code:

```
@agent json-server orders

Requirements:
- GET /api/v1/orders (paginated: page, limit params)
- GET /api/v1/orders/:id
- POST /api/v1/orders
- DELETE /api/v1/orders/:id
- Auth required on all endpoints
- Response envelope: { "success": true, "data": ... }
- Fields: id, customer_name, total_amount, status, order_status, is_paid, created_at, tags, discount_percent
```

Claude creates:
- `mock/db.json` (with 25 realistic seed records)
- `mock/routes.json`
- `mock/middleware.js`
- `mock/README.md`
- `package.json` with `npm run mock` script

### Step 12 — Start the mock server

In a separate terminal:
```bash
npm run mock
```

Verify it works:
```bash
curl http://localhost:3000/api/v1/orders \
  -H "Authorization: Bearer mock_jwt_token_karim"
```

---

### Step 13 — Write all tests first (TDD)

In Claude Code:

```
@agent tdd orders

The orders feature needs:
- Entity: id, customerName, totalAmount, status, createdAt
- Enum: OrderStatus (pending, processing, shipped, delivered, cancelled)
- Nullable fields: discountPercent, tags (list)
- Use cases: GetOrdersUseCase, DeleteOrderUseCase
- BLoC events: FetchOrders(page, refresh), RefreshOrders, DeleteOrder(id)
- BLoC states: Initial, Loading, Loaded(orders, hasMore, currentPage), Error(message)
- UI states: loading spinner, empty state, list with pull-to-refresh, error + retry
```

Claude writes all test files (Rounds 1–7) without writing implementation.

After each round, Claude runs:
```bash
flutter test test/features/dlt_orders/<round_file>
```

You see RED failures for all rounds. That is correct and expected.

Say:
```
All tests are RED. Good. Tests complete.
```

---

### Step 14 — Implement the feature (make tests GREEN)

In Claude Code:

```
@agent feature orders

Tests are written and RED in test/features/dlt_orders/. 
Make them pass one round at a time, starting from Round 1 (model tests).
Do NOT modify any test files.
```

Claude implements in order:
1. Entity → model tests GREEN
2. Model → model tests GREEN
3. DataSource → (test structure ready)
4. Repository impl → repository tests GREEN
5. Use cases → use case tests GREEN
6. BLoC → BLoC tests GREEN
7. UI (functional) → widget tests GREEN
8. Design tokens applied → UI polished
9. Performance pass → `ListView.builder + itemExtent + RepaintBoundary`
10. Accessibility pass → tooltips, semantics
11. Routing added

After each layer, Claude runs `flutter test` for that layer and shows you the GREEN results.

After full implementation:
```bash
flutter analyze --fatal-infos --fatal-warnings   # zero issues
flutter test --coverage                           # all green, coverage met
flutter run -t lib/main_preview.dart              # visual check
```

---

### Step 15 — Visual review

Run the app against the mock server:
```bash
npm run mock &
flutter run -t lib/flavors/main_development.dart
```

Navigate to the feature. Verify:
- Loading spinner appears on first load
- List renders correctly
- Pull to refresh works
- Delete works (and removes item from list immediately)
- Error state appears if you stop the mock server
- Retry reloads

If anything needs polish, tell Claude:
```
The order cards need more breathing room. Add lg vertical padding.
The status badge should use AppColors.successLight background when status is 'delivered'.
```

---

### Step 16 — Swap to real backend (when available)

When your real backend is ready:

```bash
# Edit .env.development
BASE_URL=https://api.yourapp.com/api/v1

# Run the app — no code changes
flutter run -t lib/flavors/main_development.dart
```

If the real backend returns a different response format, only the `DataSource` needs changing — not the BLoC, not the UI. This is why the architecture matters.

---

## Part 4 — Multiple Features

Repeat Steps 10–16 for each feature.

### Recommended feature order

```
1. dlt_auth     (already in template — customize to your auth flow)
2. dlt_home     (landing screen after login)
3. <first_core_feature>
4. <second_core_feature>
...
N. dlt_profile  (user settings, logout)
```

Register each feature in `.claude/memory/FEATURE_REGISTRY.md` as you build it.

---

## Part 5 — Session Continuity

### Starting a new Claude Code session

Claude Code re-reads `CLAUDE.md` automatically. To restore full context:

```
Continue working on the orders feature.
Read .claude/memory/PROJECT_STATE.md and .claude/memory/FEATURE_REGISTRY.md first.
```

Claude will restore exactly where you left off.

### Ending a session

Ask Claude to update memory:

```
Update .claude/memory/PROJECT_STATE.md with today's progress.
Mark orders feature: implementation=✅, UI=🔄 (in progress)
```

---

## Common Commands Quick Reference

```bash
# New session
claude   # Claude Code reads CLAUDE.md automatically

# Design system
# (in Claude Code) @agent design-system

# New feature pipeline
# Terminal 1:
npm run mock    # start mock API

# Claude Code:
@agent json-server <feature>
@agent tdd <feature>
@agent feature <feature>

# Verification
./scripts/codegen.sh
flutter analyze --fatal-infos
flutter test
flutter test --coverage
flutter run -t lib/main_preview.dart

# Reset mock data (before test run that mutates)
cp mock/db.seed.json mock/db.json
```

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Claude doesn't know about the template | Say "Read CLAUDE.md and .claude/skills/FLUTTER_TEMPLATE.md first" |
| Generated code doesn't use design tokens | Say "@agent feature — you skipped Phase 6B (design token pass), please redo" |
| Tests are GREEN but Claude wrote them after implementation | Delete both, redo `@agent tdd` then `@agent feature` in order |
| Mock server and real backend have different envelopes | Only fix `DataSource` parsing — don't touch BLoC or UI |
| `flutter analyze` fails after codegen | Run `./scripts/clean.sh` then `./scripts/codegen.sh` |
| Coverage drops below threshold | Tell Claude "coverage is below threshold in <layer>, add the missing tests" |
