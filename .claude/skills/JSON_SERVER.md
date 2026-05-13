# Skill: JSON Server

> Read before any mock API work. Covers setup, patterns, and backend swap.

---

## Install

```bash
# No global install needed — use npx
npx json-server --version   # verify available

# Or install globally once:
npm install -g json-server
```

---

## Start Command

```bash
npx json-server \
  --watch mock/db.json \
  --port 3000 \
  --routes mock/routes.json \
  --middlewares mock/middleware.js
```

Add to `package.json` scripts as `npm run mock`.

---

## db.json Structure Rules

1. **Top-level keys become REST endpoints**:
   ```json
   { "orders": [...], "users": [...] }
   ```
   → `GET /orders`, `GET /users`

2. **json-server uses `id` field** for lookup by default. Use string IDs matching real backend format (e.g. `"ord_01HXYZ"` not `1`).

3. **Seed at least 25 records** for paginated endpoints. json-server's `?_page=1&_limit=20` requires 25+ to test page 2.

4. **Include edge cases in seed data**:
   - One record with all optional fields null/missing
   - One record with minimum data
   - One record with maximum data (long strings, large numbers)

5. **Keep `db.seed.json`** as a backup. Before mutating tests: `cp mock/db.seed.json mock/db.json`.

---

## Pagination

json-server supports pagination natively:

```
GET /orders?_page=1&_limit=20
```

Response headers include `X-Total-Count`. Your `DataSource` should read page/limit params matching this convention, OR use `routes.json` to remap your real API's pagination params:

```json
{
  "/api/v1/orders?page=:page&limit=:limit": "/orders?_page=:page&_limit=:limit"
}
```

---

## Auth-Like Endpoints

json-server doesn't natively handle POST /auth/login returning a token. Handle with `db.json` + `routes.json`:

```json
// db.json
{
  "auth_login": {
    "success": true,
    "data": {
      "access_token": "mock_jwt_access",
      "refresh_token": "mock_jwt_refresh",
      "user": { "id": "usr_01", "name": "Test User", "email": "test@example.com" }
    }
  }
}

// routes.json
{ "/api/v1/auth/login": "/auth_login" }
```

POST to `/api/v1/auth/login` returns the static `auth_login` object regardless of body. For tests that need failure simulation, temporarily change `auth_login.success` to `false`.

---

## Response Envelope Matching

Most production backends wrap responses:

```json
{ "success": true, "data": { ... } }
// or
{ "status": "ok", "result": [...] }
```

Your `DataSource` parses this envelope. The middleware must produce the same envelope as the real backend. Edit `mock/middleware.js` to match:

```javascript
// For backend that uses: { "success": true, "data": ... }
res.json = (body) => {
  if (req.method === 'GET' && res.statusCode === 200) {
    return originalJson({ success: true, data: body });
  }
  return originalJson(body);
};
```

**Critical**: the `DataSource` code must parse the same structure. If the mock and real backend envelopes differ, the swap will break.

---

## Switching from Mock to Real Backend

**The only change**: `.env.development`:

```bash
# Mock
BASE_URL=http://localhost:3000

# Real backend
BASE_URL=https://api.yourapp.com/api/v1
```

If you need to switch without recompiling:

```dart
// .env.development already has the right BASE_URL
// flutter run picks it up automatically
flutter run -t lib/flavors/main_development.dart
```

No app code changes are needed when:
- Mock routes match real backend paths exactly (via `routes.json` remapping)
- Mock response envelope matches real backend envelope (via `middleware.js`)
- Mock IDs are in the same format as real backend IDs

---

## Common json-server Issues

| Issue                         | Fix                                                  |
|-------------------------------|------------------------------------------------------|
| POST creates new record instead of returning auth response | Use static object in `db.json` + `routes.json` remap |
| CORS errors from Flutter web  | Add `--no-cors` flag or add CORS headers in middleware |
| 404 for nested paths          | Add to `routes.json`: `"/api/v1/orders/:id": "/orders/:id"` |
| Data mutated between tests    | `cp mock/db.seed.json mock/db.json` before each test run |
| Port 3000 already in use      | `lsof -ti:3000 \| xargs kill` or use `--port 3001`  |

---

## Testing Against Mock

Integration tests should point to `localhost:3000`. Set in `.env.development` before running:

```bash
# Terminal 1 — start mock
npm run mock

# Terminal 2 — run integration tests
flutter test integration_test --dart-define=ENV=development
```
