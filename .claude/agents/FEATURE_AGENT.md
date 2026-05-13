# Agent: Feature Development

**Invoked by**: `@agent feature <feature-name>`

**Purpose**: Implement a production-ready feature end-to-end following Clean Architecture. Makes TDD tests pass in order. Finishes with polished, performant UI.

**Reads first (mandatory)**:
1. `.claude/skills/FLUTTER_TEMPLATE.md`
2. `.claude/skills/DESIGN_SYSTEM.md`
3. `.claude/memory/DESIGN_DECISIONS.md`
4. `.claude/memory/FEATURE_REGISTRY.md`
5. `test/features/dlt_<name>/` — read ALL existing test files before writing a single line of implementation

**Updates after**: `.claude/memory/FEATURE_REGISTRY.md`

---

## Prerequisite Checks

Before starting, verify:
- [ ] `@agent design-system` has completed (check `DESIGN_DECISIONS.md` is filled)
- [ ] `@agent json-server <name>` has completed and mock server is running on port 3000
- [ ] `@agent tdd <name>` has completed and tests exist and are RED

If any prerequisite is missing, stop and run the missing agent first.

---

## Implementation Phases (follow strictly in order)

### Phase 1 — Domain Layer

Implement entities and use cases to make Round 1–3 tests GREEN.

**Order**:
1. `domain/entities/<name>_entity.dart` — make entity equality tests pass
2. `domain/repositories/<name>_repository.dart` — abstract interface
3. `domain/usecases/get_<name>s_usecase.dart` — make use case tests pass
4. Additional use cases (create, update, delete) as needed

**Run after each file**: `flutter test test/features/dlt_<name>/domain/`

**Rules**:
- `extends Equatable` with ALL fields in `props`
- Repository interface returns `ApiResult<T>` — never raw entities
- Use cases are `@injectable`, one `call()` method, thin — no business logic beyond delegating to repository

---

### Phase 2 — Data Layer: Models

Make Round 1 model tests GREEN.

1. `data/models/<name>_model.dart`
   - `@freezed` with `_$<Name>Model`
   - `const <Name>Model._()` private constructor for `toEntity()`
   - Every `@JsonKey` uses `JsonParseUtils`
   - Every non-nullable field has `@Default`
   - `toEntity()` method

2. Run `./scripts/codegen.sh` to generate `.freezed.dart` and `.g.dart`

3. Run tests: `flutter test test/features/dlt_<name>/data/models/`

**All 10 model test scenarios must be GREEN before moving on.**

---

### Phase 3 — Data Layer: DataSources

1. `data/datasources/<name>_remote_datasource.dart`
   - `@lazySingleton`
   - Constructor injects `DioClient`
   - Returns models, never entities
   - Handles both `{"data": [...]}` and bare `[...]` responses
   - Handles both `{"data": {...}}` and bare `{...}` responses
   - Never catches exceptions — let them propagate to repository

2. Optional: `data/datasources/<name>_local_datasource.dart` for offline support

---

### Phase 4 — Data Layer: Repository Implementation

Make Round 4 repository tests GREEN.

```dart
@LazySingleton(as: <Name>Repository)
class <Name>RepositoryImpl extends BaseApiRepository implements <Name>Repository {
  // or ScalableBaseRepository if caching/circuit-breaker needed
}
```

**Run `./scripts/codegen.sh` after annotation changes.**

Run tests: `flutter test test/features/dlt_<name>/data/repositories/`

---

### Phase 5 — Presentation Layer: BLoC

Make Round 5 BLoC tests GREEN.

```dart
@injectable
class <Name>Bloc extends Bloc<<Name>Event, <Name>State> {
  // depends on use cases ONLY
  // every handler switches on ApiResult exhaustively
  // uses bloc_concurrency transformers
}
```

**Transformers to use**:
- `FetchEvent` → `droppable()` (ignore concurrent fetches)
- `RefreshEvent` → `restartable()` (cancel ongoing, restart)
- `SearchEvent` (if any) → `restartable()` + debounce
- `DeleteEvent`, `CreateEvent`, `UpdateEvent` → `sequential()` (serialize mutations)

Run tests: `flutter test test/features/dlt_<name>/presentation/bloc/`

---

### Phase 6 — Presentation Layer: UI

Make Round 6 widget tests GREEN, then polish.

#### 6A — Functional UI (make tests pass)

Build the minimum widget structure that makes all widget tests pass:
- `<Name>Screen` (BlocProvider wrapper)
- `<Name>View` (BlocConsumer with all 4 states)
- `_<Name>Card` (list item)
- `_EmptyState`
- Reuse `ErrorWidgetWithAction` for error state

#### 6B — Design System Integration (after tests are green)

Apply all design tokens. Go through every widget and replace:

| Replace                        | With                                  |
|--------------------------------|---------------------------------------|
| `EdgeInsets.all(16)`           | `AppSpacing.mdPadding`                |
| `Color(0xFF...)`               | `context.colors.X` or `AppColors.X`  |
| `TextStyle(fontSize: 14, ...)` | `context.textTheme.bodyMedium`        |
| `BorderRadius.circular(8)`     | `BorderRadius.circular(AppDimensions.radiusMd)` |
| Hard-coded strings             | `context.loc.<key>` (add to ARB file) |
| `SizedBox(height: 16)`         | `AppSpacing.mdHeight`                 |

#### 6C — Performance Pass

For every `ListView` in the feature:

```dart
ListView.builder(
  itemCount: items.length,
  itemExtent: 88,                    // fixed height = no layout pass per item
  itemBuilder: (_, i) => RepaintBoundary(
    key: ValueKey(items[i].id),      // stable key for efficient diffs
    child: _ItemCard(item: items[i]),
  ),
)
```

For every image:
```dart
CustomImageView(
  imageUrl: item.imageUrl,
  cacheWidth: 200,   // match actual render size
  cacheHeight: 200,
)
```

Use `BlocSelector` to scope rebuilds where only one piece of state drives a widget:

```dart
BlocSelector<<Name>Bloc, <Name>State, bool>(
  selector: (state) => state is <Name>Loading,
  builder: (context, isLoading) => isLoading
      ? const LinearProgressIndicator()
      : const SizedBox.shrink(),
)
```

#### 6D — Overflow-Proof Pass

For every form screen:
```dart
Scaffold(
  resizeToAvoidBottomInset: true,
  body: SafeArea(
    child: SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
      ),
      child: Column(children: [ /* fields */ ]),
    ),
  ),
)
```

For every `Row` with text: wrap text in `Expanded` + `TextOverflow.ellipsis`.

#### 6E — Accessibility Pass

```dart
// IconButtons
IconButton(
  tooltip: context.loc.<action>_tooltip,   // ← required
  onPressed: ...,
  icon: const Icon(Icons.delete),
)

// Custom tap targets
Semantics(
  label: context.loc.<item>_label,
  button: true,
  child: GestureDetector(/* ... */),
)
```

Ensure every interactive element has a minimum 48×48 tap target:
```dart
InkWell(
  onTap: ...,
  child: Padding(
    padding: EdgeInsets.all(AppSpacing.sm),   // minimum 48px total
    child: Icon(Icons.edit, size: AppDimensions.iconMedium),
  ),
)
```

---

### Phase 7 — Routing

Add to `route_paths.dart`, `route_names.dart`, `app_routes.dart`.

Use `CustomTransitionPage` with `AppRouteTransitions` — never default `MaterialPage`.

Update `FEATURE_REGISTRY.md` with new route.

---

### Phase 8 — Final Verification

```bash
./scripts/codegen.sh               # ensure generated files are fresh
flutter analyze --fatal-infos      # zero issues
flutter test                       # all tests green
flutter test --coverage            # verify coverage thresholds
flutter run -t lib/main_preview.dart  # visual check on multiple device sizes
```

Visual checklist (run in preview mode):
- [ ] Phone portrait — no overflow
- [ ] Phone landscape — no overflow
- [ ] Tablet — adaptive layout activates if screen ≥ 600px
- [ ] Dark mode — colors correct, contrast sufficient
- [ ] Text scale 150% — layout holds
- [ ] Text scale 200% — layout holds (may scroll, must not overflow)
- [ ] Keyboard opens — scroll works, fields not hidden
- [ ] Offline banner appears when network disconnected

---

## Completion Checklist

- [ ] All Round 1–6 tests GREEN
- [ ] `flutter analyze` passes
- [ ] Feature accessible via typed route
- [ ] All states handled (loading, loaded-empty, loaded-populated, error)
- [ ] All user strings localized via `context.loc`
- [ ] All UI uses design tokens only (no raw literals)
- [ ] `FEATURE_REGISTRY.md` updated with: status=✅, route, tests=✅, UI=✅
