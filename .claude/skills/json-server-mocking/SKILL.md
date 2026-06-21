---
name: json-server-mocking
description: >
  Rules for the zero-backend mock API (json-server) used in Phase 3 to build the
  API contract before the real backend exists. Activates when adding/editing
  mock endpoints or seed data. Keywords: mock, json-server, mock API, db.json,
  seed data, endpoint, BASE_URL, response envelope, empty/error/loading states.
---

# JSON-Server Mocking

A zero-backend mock so every screen state (filled · empty · error · loading)
can be built against the **same response contract** the real backend will use.
Only the app's `BASE_URL` points here; nothing above the `DataSource` changes at
swap time.

> Full operator guide (state-switching table, curl checks, Android/iOS host
> notes) lives in `mock/README.md`. Don't duplicate it — link to it.

## Files (all under `mock/`, scripts in the ROOT `package.json`)

| File | Purpose |
|---|---|
| `mock/server.js` | json-server + envelope wrapping + state switching |
| `mock/db.json` | live seed data (mutated by POST/PUT/DELETE) |
| `mock/db.seed.json` | pristine copy used by `npm run mock:reset` |

There is **no** `routes.json` or `middleware.js` — state switching is handled
inside `server.js`. Run from the **project root**:

```bash
npm install            # first time (installs json-server 0.17.4)
npm run mock           # node mock/server.js → http://localhost:3000
npm run mock:reset     # restore db.json from db.seed.json
```

## Response contract (must match DioClient + ApiResult<T>)

```jsonc
// success
{ "success": true,  "message": "OK",      "data": <payload> }
// error
{ "success": false, "message": "<reason>", "data": null }
```

## State switching (no data edits — flip a header or query param)

| State   | Query param                 | Header                | Result                |
|---------|-----------------------------|-----------------------|-----------------------|
| Filled  | _(default)_                 | _(none)_              | seeded `data`         |
| Empty   | `?_state=empty`             | `x-mock-state: empty` | `data: []`            |
| Error   | `?_state=error`             | `x-mock-state: error` | `500` + error envelope|
| Error N | `?_state=error&_status=404` | `x-mock-status: 404`  | custom status         |
| Loading | `?_delay=1500`              | `x-mock-delay: 1500`  | delays response N ms  |

## Adding a resource

1. Add a top-level array to `mock/db.json` (e.g. `"orders": [ ... ]`).
2. Mirror it into `mock/db.seed.json` (the reset copy).
3. It's instantly available at `GET /orders` with filtering
   (`?category=x`), pagination (`?_page=1&_limit=10`), sorting
   (`?_sort=order&_order=asc`), and full CRUD.

## Pointing the app at the mock

Edit `.env.development`:

```env
BASE_URL=http://localhost:3000/
```

- Android emulator → `http://10.0.2.2:3000/`
- iOS simulator → `http://localhost:3000/`
- Physical device → your machine's LAN IP, e.g. `http://192.168.1.20:3000/`

Seed realistic data matching the entities in the feature's
`docs/features/<name>.md` spec.
