# Mock API — Design Phase (Option A: json-server)

A zero-backend mock so the designer can build and screenshot every screen state
(**filled · empty · error · loading**) against the **same response contract** the
real backend will use. The Flutter app only needs its `BASE_URL` pointed here —
nothing above the `DataSource` changes when you later swap in the real backend.

## Response contract

Every response is wrapped to match `DioClient` + `ApiResult<T>`:

```jsonc
// success
{ "success": true,  "message": "OK",            "data": <payload> }
// error
{ "success": false, "message": "<reason>",       "data": null }
```

## Setup (once)

Run from the **project root** (the `package.json` with the `mock` scripts lives
there, not in this folder):

```bash
npm install        # installs json-server (pinned to 0.17.4)
```

## Run

```bash
npm run mock       # node mock/server.js → http://localhost:3000
```

Point the app at it — edit `.env.development`:

```env
BASE_URL=http://localhost:3000/
```

> **Android emulator:** use `http://10.0.2.2:3000/` instead of `localhost`.
> **iOS simulator:** `http://localhost:3000/` works as-is.
> **Physical device:** use your machine's LAN IP, e.g. `http://192.168.1.20:3000/`.

## Switching states (the whole point)

No data edits needed — flip a header or query param per request.

| State    | Query param        | Header                          | Result                          |
|----------|--------------------|---------------------------------|---------------------------------|
| Filled   | _(default)_        | _(none)_                        | seeded `data` array/object      |
| Empty    | `?_state=empty`    | `x-mock-state: empty`           | `data: []`                      |
| Error    | `?_state=error`    | `x-mock-state: error`           | `500` + error envelope          |
| Error N  | `?_state=error&_status=404` | `x-mock-status: 404`   | custom status code              |
| Loading  | `?_delay=1500`     | `x-mock-delay: 1500`            | delays response N ms            |

### Quick checks

```bash
# Filled
curl http://localhost:3000/faqs

# Empty
curl "http://localhost:3000/faqs?_state=empty"

# Error (500)
curl -i "http://localhost:3000/faqs?_state=error"

# Error (404) + slow response
curl -i "http://localhost:3000/faqs?_state=error&_status=404"
curl "http://localhost:3000/faqs?_delay=2000"
```

For the **app** (not curl), the cleanest way to force a state across a whole
screen during design is a header. Add it temporarily in `DioClient` or via an
interceptor, e.g. `x-mock-state: empty`, then remove before real-backend swap.

## Seeded resources

- `GET /faqs`, `GET /faqs/:id` — matches `NetworkConstants.faqEndpoint`
- `GET /tasks`, `GET /tasks/:id` — mirrors the `dlt_tasks` feature shape

json-server also gives you `POST`/`PUT`/`PATCH`/`DELETE`, filtering
(`/faqs?category=billing`), pagination (`/faqs?_page=1&_limit=10`), and sorting
(`/faqs?_sort=order&_order=asc`) for free.

## Add a new resource

1. Add a top-level array to `mock/db.json` (e.g. `"orders": [ ... ]`).
2. Mirror it into `mock/db.seed.json` (the pristine reset copy).
3. It's instantly available at `GET /orders`.

## Reset data after mutating runs

```bash
npm run mock:reset   # restores db.json from db.seed.json
```

## Files

| File             | Purpose                                            |
|------------------|----------------------------------------------------|
| `server.js`      | json-server + envelope wrapping + state switching  |
| `db.json`        | live seed data (mutated by POST/PUT/DELETE)         |
| `db.seed.json`   | pristine copy used by `npm run mock:reset`          |
