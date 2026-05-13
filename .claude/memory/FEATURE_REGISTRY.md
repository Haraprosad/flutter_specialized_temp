# Feature Registry

> **Updated by**: All agents after completing their phase.
> **Read by**: `@agent feature` and `@agent json-server` before starting.

---

## Feature Status Table

| Feature Name | Route Path        | Mock API | Tests | Implementation | UI Polish | Notes       |
|--------------|-------------------|----------|-------|----------------|-----------|-------------|
| `dlt_auth`   | `/login`, `/register` | n/a (reference) | ✅ | ✅ | ✅ | Template reference |
| `dlt_home`   | `/home`           | n/a      | ✅   | ✅             | ✅        | Template ref |

> Add new features below as they are started.

---

## Status Key

| Symbol | Meaning                            |
|--------|------------------------------------|
| ✅     | Complete, tests passing            |
| 🔄     | In progress                        |
| ❌     | Not started                        |
| ⚠️     | Complete with known issues (note)  |

---

## Route Registry

> Prevent duplicate routes. Every feature's routes are registered here.

| Route Name        | Path                      | Feature       |
|-------------------|---------------------------|---------------|
| `login`           | `/login`                  | `dlt_auth`    |
| `register`        | `/register`               | `dlt_auth`    |
| `home`            | `/home`                   | `dlt_home`    |

> Add new routes below as features are built.

---

## Mock API Status

| Feature  | Port  | db.json path         | Status       | Notes         |
|----------|-------|----------------------|--------------|---------------|
| *(none)* |       |                      |              |               |

---

## Dependency Map

> Features that depend on other features (for ordering work).

```
dlt_auth
  └── (must complete before any feature with auth-guarded routes)

dlt_home
  └── depends on dlt_auth (redirects if unauthenticated)
```

---

## Localization Keys Added

> Track all ARB keys to prevent duplicates.

| Key                     | English Value          | Bengali Value | Feature   |
|-------------------------|------------------------|---------------|-----------|
| `app_name`              | `_FILL_IN_`            | `_FILL_IN_`   | core      |
| `login_button`          | `Login`                | `লগইন`        | dlt_auth  |
| `register_button`       | `Register`             | `নিবন্ধন করুন` | dlt_auth  |

> Agents must add their keys here when introducing new `context.loc.<key>` calls.
