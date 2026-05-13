# Design Decisions

> **Written by**: `@agent design-system` after completion.
> **Read by**: Every agent before any UI or widget work.
> **Do not edit manually** unless you are intentionally rebranding.

---

## Color Palette

| Token                    | Hex       | Usage                              |
|--------------------------|-----------|------------------------------------|
| `AppColors.primary`      | `#______` | Primary actions, active states     |
| `AppColors.primaryLight` | `#______` | Backgrounds, chips, tags           |
| `AppColors.primaryDark`  | `#______` | Pressed states, dark mode accents  |
| `AppColors.secondary`    | `#______` | Secondary actions, highlights      |
| `AppColors.error`        | `#______` | Error states, destructive actions  |
| `AppColors.success`      | `#______` | Success states, confirmations      |
| `AppColors.warning`      | `#______` | Warning states, cautions           |

### Light Mode Neutrals
| Token                           | Hex       |
|---------------------------------|-----------|
| `AppColors.backgroundLight`     | `#______` |
| `AppColors.surfaceLight`        | `#______` |
| `AppColors.textPrimaryLight`    | `#______` |
| `AppColors.textSecondaryLight`  | `#______` |

### Dark Mode Neutrals
| Token                          | Hex       |
|--------------------------------|-----------|
| `AppColors.backgroundDark`     | `#______` |
| `AppColors.surfaceDark`        | `#______` |
| `AppColors.textPrimaryDark`    | `#______` |
| `AppColors.textSecondaryDark`  | `#______` |

---

## Typography

| Setting            | Value                  |
|--------------------|------------------------|
| Primary Font       | `_FILL_IN_`            |
| Secondary Font     | `_FILL_IN_` or same    |
| Font Source        | assets/fonts / Google Fonts package |
| Font Weights Used  | 400, 500, 600, 700     |
| Design Frame Size  | 375×812 (ScreenUtil base) |

### Scale Preview (at base size)
| Style             | Size  | Weight |
|-------------------|-------|--------|
| displayLarge      | 57sp  | 700    |
| headlineMedium    | 28sp  | 600    |
| titleMedium       | 16sp  | 500    |
| bodyLarge         | 16sp  | 400    |
| bodyMedium        | 14sp  | 400    |
| labelSmall        | 11sp  | 500    |

---

## Spacing & Layout

| Setting            | Value        |
|--------------------|--------------|
| Base Spacing Unit  | `_FILL_IN_`dp |
| xs                 | base × 1     |
| sm                 | base × 2     |
| md                 | base × 4     |
| lg                 | base × 6     |
| xl                 | base × 8     |
| Screen H. Padding  | md (16dp)    |

---

## Shape / Radius

| Setting            | Value         |
|--------------------|---------------|
| Style              | sharp / rounded / pill |
| radiusSm           | `_`dp         |
| radiusMd           | `_`dp         |
| radiusLg           | `_`dp         |
| Button radius      | radiusMd      |
| Card radius        | radiusLg      |
| Input radius       | radiusMd      |

---

## Motion

| Setting         | Value    |
|-----------------|----------|
| Fast duration   | 150ms    |
| Medium duration | 300ms    |
| Slow duration   | 500ms    |
| Standard curve  | easeInOut |

---

## Accessibility Commitments

| Standard         | Target     |
|------------------|------------|
| Color contrast   | WCAG 2.2 AA (4.5:1 body, 3:1 large) |
| Min tap target   | 48×48 px   |
| Max text scale   | 200% (layout must hold) |
| Dark mode        | Full support |
| Screen reader    | All interactive elements labelled |

---

## Dark Mode

```
Enabled: yes / no / system-default
Strategy: ColorScheme-based (ThemeBloc + PreferencesManager)
```

---

## Approved By / Date

```
Approved by : _FILL_IN_
Date        : _FILL_IN_
Changes log : none
```
