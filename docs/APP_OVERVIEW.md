# App Overview — <Your App Name>

> **Write this first**, before Phase 1 (design system) and before any feature
> spec. This is the single source of truth for *what you're building and why*.
> Per-feature detail belongs in `docs/features/<name>.md` (Phase 2) — keep this
> file at the product level. Replace every `<placeholder>` and delete this quote
> block when done.

---

## 1. The idea (one paragraph)

<What is the app? Who is it for? What problem does it solve? Write it as if
explaining to a new teammate in 30 seconds.>

## 2. Target users

| Persona | Need | Primary actions |
|---|---|---|
| `<e.g. shopper>` | `<browse and buy quickly>` | `<search, add to cart, checkout>` |
| `<e.g. admin>` | `<manage inventory>` | `<add product, view orders>` |

## 3. Platforms & flavors

- Platforms: `<iOS / Android / Web / Desktop>`
- Flavors used: development / staging / production (see
  [01_GETTING_STARTED.md](01_GETTING_STARTED.md))

## 4. Brand & design direction (input to Phase 1)

This feeds the `@design-system-architect` in Phase 1. Fill what you know now;
the Figma tokens refine it.

| Token group | Value / source |
|---|---|
| Primary color | `<#hex>` |
| Secondary / accent | `<#hex>` |
| Typography | `<font family / Figma text styles>` |
| Density & spacing | `<compact / comfortable>` |
| Motion feel | `<snappy / smooth / playful>` |
| Figma tokens file | `<design/tokens.json>` (if exported) |

## 5. Feature list (the build order)

List features in the order you'll build them. **One feature flows through
Phases 2 → 6 before the next starts — don't parallelize** (CLAUDE.md). Each row
gets its own spec at `docs/features/<name>.md` when you reach its Phase 2.

| # | Feature | One-line scope | Spec file | Status |
|---|---|---|---|---|
| 1 | `<auth>` | `<login / register / logout>` | `docs/features/auth.md` | ☐ Not started |
| 2 | `<home>` | `<dashboard of …>` | `docs/features/home.md` | ☐ Not started |
| 3 | `<…>` | `<…>` | `docs/features/<…>.md` | ☐ Not started |

## 6. Backend / API

- Real backend status: `<not started / in progress / live at …>`
- Strategy: build against the **json-server mock** first (Phase 3), swap
  `BASE_URL` for the real backend in Phase 7. See [00_WORKFLOW.md](00_WORKFLOW.md).

## 7. Out of scope (for now)

<List what you are deliberately NOT building yet, so it doesn't creep in.>

---

**Next step:** with this filled in, start **Phase 1** — customize the design
system. Follow [00_WORKFLOW.md](00_WORKFLOW.md).
