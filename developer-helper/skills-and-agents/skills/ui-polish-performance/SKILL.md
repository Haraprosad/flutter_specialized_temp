---
name: ui-polish-performance
description: >
  Rules for Phase 6 — taking a working feature from "passes tests" to
  "delightful and fast." Activates when adding animations/micro-interactions,
  tuning scroll/build performance, or auditing accessibility. Keywords: polish,
  animation, micro-interaction, performance, 60fps, RepaintBoundary, const,
  ListView.builder, itemExtent, BlocSelector, profile mode, accessibility,
  semantics, contrast, text scale.
---

# UI Polish & Performance

Make it work (Phase 5), then make it nice and fast (Phase 6). Never polish
around buggy logic.

## Performance checklist

- `const` constructors everywhere the widget is immutable.
- Lists > 10 items: `ListView.builder` (never `ListView(children: [...])`).
  Provide `itemExtent` (or `prototypeItem`) when row height is fixed — it skips
  layout passes.
- Wrap expensive, independently-repainting subtrees in `RepaintBoundary`
  (list items, animations, charts).
- Narrow rebuilds: `BlocSelector` / `context.select` instead of rebuilding the
  whole subtree on every state change. Use `buildWhen` on `BlocBuilder`.
- Defer/precache images; use the template's `app_image_cache_manager.dart`.

## Motion

Use `tokens/app_motion.dart` durations & curves (no magic `Duration`s):
- list item entrance (staggered), hero transition on tap-to-detail, button
  press scale, skeleton/shimmer while loading.
- Purposeful, subtle by default. Respect the brand's motion personality set in
  Phase 1.

## Empty / error states

Give empty and error states real treatment — illustration + message + CTA
("No orders yet" + create button; error + retry). These are first-class
states, not afterthoughts.

## Accessibility (must pass)

- `tooltip` on every `IconButton`; `Semantics` labels on custom interactive
  widgets.
- Tap targets ≥ 48×48.
- Layout survives 200% text scale (test with `MediaQuery` textScaler override).
- Sufficient color contrast (verify against `context.colors` tokens in both
  light and dark).

## Verify in profile mode (physical mid-range device)

```bash
flutter run --profile -t lib/flavors/main_production.dart
flutter build appbundle --analyze-size      # flag oversized dependencies
```

Open DevTools → Performance, scroll the new screens. Target sustained 60fps:
frame build < 8 ms, raster < 8 ms. No jank on entrance animations.

See `docs/04_DESIGN_SYSTEM.md` (motion/tokens) and the quality gates in
`PROJECT_RULES.md`.
