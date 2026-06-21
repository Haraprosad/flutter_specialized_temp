# Guide 9 — Localization

Complete guide to the localization (l10n) management system in `lib/core/localization/`. **Every user-facing string in this app must come from localization** — never a hardcoded literal in a widget. This is what makes adding a new language a config change, not a rewrite.

The template ships with two languages out of the box: **English (`en`)** and **Bengali (`bn`)**.

---

## Architecture Overview

The system is split into a **UI path** (translate inside widgets, the common case) and a **non-UI path** (translate outside a `BuildContext`, e.g. in the network layer).

```
lib/core/localization/
├── l10n/
│   ├── app_en.arb                 # English source strings (template ARB — the key registry)
│   ├── app_bn.arb                 # Bengali source strings
│   ├── app_localizations.dart     # GENERATED — do not edit
│   ├── app_localizations_en.dart  # GENERATED — do not edit
│   └── app_localizations_bn.dart  # GENERATED — do not edit
├── extension/
│   └── loc.dart                   # `context.loc` → AppLocalizations.of(context)!
├── bloc/
│   ├── locale_bloc.dart           # Holds current Locale, persists + validates it
│   ├── locale_event.dart          # InitializeLocale, ChangeLocaleEvent
│   └── locale_state.dart          # LocaleState(locale)
├── locale_constants.dart          # LocaleConstants.english / .bengali
└── localization_actions.dart      # LocalizationActions.setLocale / getLocale

lib/core/network/services/localization_service/
├── localization_service.dart        # Abstract: translate(key) for non-UI code
└── global_localization_service.dart # Maps ErrorMessagesKey → localized string
```

Project config:
- `l10n.yaml` (repo root) — points `flutter gen-l10n` at `lib/core/localization/l10n`, template `app_en.arb`, output `app_localizations.dart`.
- `pubspec.yaml` → `flutter: generate: true` — enables generation on build.

### How they connect

```
                ┌────────────────────────────┐
   app_en.arb ──►   flutter gen-l10n         │
   app_bn.arb ──►   (code generation)        │
                └──────────────┬─────────────┘
                               ▼
                      AppLocalizations  ─────────────────────┐
                       (generated)                           │
                               ▲                             ▼
         context.loc ──────────┘                   LocalizationService
         (loc.dart extension)                     (non-UI: error keys)
                               ▲                             ▲
   MaterialApp.router(locale: localeState.locale, …)        │
                               ▲                             │
                        LocaleBloc ◄── LocalizationActions.setLocale
                        (current Locale, persisted to prefs)
```

The `LocaleBloc` is the single source of truth for the current language. `main.dart` wraps `MaterialApp.router` in a `BlocBuilder<LocaleBloc, LocaleState>` and feeds `localeState.locale` into the app, so changing the locale rebuilds the whole tree in the new language.

---

## Using localized strings in widgets (the common case)

**Rule 7-adjacent:** no hardcoded user-facing string in a widget. Pull it from `context.loc`.

```dart
import 'package:flutter_specialized_temp/core/localization/extension/loc.dart';

// ✅ Correct — string comes from the ARB via the generated getter
Text(context.loc.home, style: context.headlineMedium);
AppBar(title: Text(context.loc.flutter_template));

// ❌ Forbidden — hardcoded English literal
Text('Home');
```

Each ARB key becomes a getter on `AppLocalizations` with the **exact same name**. Key `home` → `context.loc.home`. Key `try_again` → `context.loc.try_again`.

---

## Step-by-Step: Adding a new string

Follow these steps **in order** every time you need a new piece of copy.

### Step 1 — Add the key to the template ARB (English)

Open `lib/core/localization/l10n/app_en.arb` and add your key. Use `snake_case`, keep keys **unique**, and group related keys with a shared prefix (`error_`, `auth_`, …):

```json
{
  "home": "Home",
  "orders_title": "My Orders",
  "orders_empty": "You have no orders yet"
}
```

### Step 2 — Add the same key to every other language ARB

Open `lib/core/localization/l10n/app_bn.arb` and add the **same keys** with translated values. A key present in the template but missing here falls back to the template (English) value.

```json
{
  "orders_title": "আমার অর্ডার",
  "orders_empty": "আপনার এখনও কোনো অর্ডার নেই"
}
```

### Step 3 — Regenerate `AppLocalizations`

l10n generation is **separate from `./scripts/codegen.sh`** (that script runs `build_runner`, which does **not** touch ARB files). Run:

```bash
flutter gen-l10n
```

(With `generate: true` in `pubspec.yaml`, a plain `flutter run` / `flutter build` also regenerates, but run `flutter gen-l10n` explicitly so the new getters exist before you reference them.)

### Step 4 — Use it

```dart
Text(context.loc.orders_title);
```

> Never edit `app_localizations*.dart` by hand — they are generated and listed under the "Forbidden shortcuts" in `CLAUDE.md`.

---

## Switching the language at runtime

Use `LocalizationActions` — never poke `LocaleBloc` or `MaterialApp.locale` directly from a widget.

```dart
import 'package:flutter_specialized_temp/core/localization/localization_actions.dart';
import 'package:flutter_specialized_temp/core/localization/locale_constants.dart';

// Set the language (persists to preferences, validates against supportedLocales,
// falls back to English if unsupported)
LocalizationActions.setLocale(context, LocaleConstants.bengali);

// Read the current language reactively
final current = LocalizationActions.getLocale(context);
```

`LocaleBloc` persists the chosen `languageCode` to `AppStorage.preferences` and only emits a supported locale. The reference language switcher is `lib/core/widgets/app_drawer/app_drawer.dart`.

### Restoring the saved language on launch

`InitializeLocale` reads the persisted `languageCode` and emits it. To restore the user's last choice on startup, dispatch it where the BLoC is provided in `main.dart` — mirroring how `ThemeBloc` restores the saved theme:

```dart
BlocProvider<LocaleBloc>(
  create: (context) => sl<LocaleBloc>()..add(const InitializeLocale()),
),
```

---

## Adding a new language (e.g. Arabic `ar`)

1. Create `lib/core/localization/l10n/app_ar.arb` with **every** key from `app_en.arb`, translated.
2. Add the locale to `lib/core/localization/locale_constants.dart`:
   ```dart
   static const Locale arabic = Locale('ar');
   ```
3. Run `flutter gen-l10n`. `AppLocalizations.supportedLocales` and `localizationsDelegates` pick it up automatically — no change needed in `main.dart`.
4. Surface it in the language switcher (`app_drawer.dart`).

For right-to-left languages, Flutter handles text direction automatically once the locale is supported; verify layouts with `Directionality`.

---

## Non-UI localization (network / error layer)

Some strings must be resolved where there is **no `BuildContext`** — most importantly network error messages produced inside the Dio interceptor chain (see `docs/08_NETWORK.md`). That path uses `LocalizationService`.

- Error keys are constants in `lib/core/network/constants/error_messages_key.dart` (e.g. `ErrorMessagesKey.noInternet`).
- The network layer carries the **key**, not the text.
- `GlobalLocalizationService.translate(key)` maps the key to the localized string via `AppLocalizations`.
- `main.dart` keeps the service's `AppLocalizations` reference in sync on every rebuild:
  ```dart
  if (AppLocalizations.of(context) != null) {
    sl<LocalizationService>().setLocalizations(AppLocalizations.of(context)!);
  }
  ```

To add a new backend/error message: add the key to both ARB files, add a `static const` to `ErrorMessagesKey`, then add a `case` in `GlobalLocalizationService._getLocalizedValue`. Unmapped keys fall back to `error_unknown`.

---

## Testing

- Pump widgets with localization delegates so `context.loc` resolves:
  ```dart
  await tester.pumpWidget(MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: const MyScreen(),
  ));
  ```
- Assert against `context.loc.<key>` / the ARB value, not a hardcoded literal, so tests survive copy changes.
- `LocaleBloc` behavior (persist, validate, fallback) is covered in `test/core/localization/bloc/locale_bloc_test.dart` — follow that pattern.

---

## Do / Don't

**Do**
- Pull every user-facing string from `context.loc.<key>`.
- Add new keys to **all** ARB files, then `flutter gen-l10n`.
- Switch languages only through `LocalizationActions`.
- Use `ErrorMessagesKey` + `LocalizationService` for strings outside a `BuildContext`.

**Don't**
- Hardcode English (or any) literals in widgets.
- Edit `app_localizations*.dart` by hand.
- Read/write the locale via `MaterialApp` or `LocaleBloc` directly from widgets.
- Assume `./scripts/codegen.sh` regenerates l10n — it doesn't; run `flutter gen-l10n`.
- Leave duplicate keys in an ARB file (last value silently wins).
