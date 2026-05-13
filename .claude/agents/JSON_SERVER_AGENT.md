# Agent: JSON Server Mock API

**Invoked by**: `@agent json-server <feature-name>`

**Purpose**: Create a fully-functional local REST mock API using `json-server` for a feature before its real backend exists. Follows the exact same URL structure the real backend will use so swapping is a one-line change.

**Reads first**: `.claude/memory/FEATURE_REGISTRY.md` (check if API already exists)

**Updates after**: `.claude/memory/FEATURE_REGISTRY.md` (mock API status)

---

## Principle: Zero Coupling to Mock

The real backend swap must require changing **only `BASE_URL` in `.env.development`**. Nothing in app code knows it is talking to a mock.

```
Development  →  BASE_URL=http://localhost:3000
Production   →  BASE_URL=https://api.yourapp.com
```

---

## Step 1 — Gather API Contract from User

Before creating any files, ask:

```
1. Feature name (e.g. "orders")
2. List of endpoints needed:
   - Method + path (e.g. GET /orders, POST /orders, GET /orders/:id)
3. For each endpoint, what fields does the response have?
4. Pagination needed? (page/limit query params)
5. Auth required? (will json-server simulate a 401?)
6. Any relationship between resources? (e.g. orders belong to users)
```

---

## Step 2 — Create Mock Directory Structure

```
mock/
├── db.json           ← All resource data
├── routes.json       ← URL rewriting rules
├── middleware.js     ← Auth simulation, delays, error injection
└── README.md         ← How to start, available endpoints, swap instructions
```

---

## Step 3 — Generate `mock/db.json`

Seed with realistic, locale-appropriate data. Use Bengali names if the app targets BD audience. Include at least 10 records per list resource. Use consistent IDs (string UUIDs, not auto-increment integers, to match real backends).

Template pattern:

```json
{
  "orders": [
    {
      "id": "ord_01HXYZ",
      "customer_name": "Rahim Uddin",
      "total_amount": 1250.50,
      "status": "processing",
      "order_status": "processing",
      "is_paid": false,
      "created_at": "2025-01-15T10:30:00Z",
      "tags": ["express", "fragile"],
      "discount_percent": 10,
      "metadata": { "channel": "mobile" }
    }
  ],
  "users": [
    {
      "id": "usr_01HABC",
      "name": "Karim Ahmed",
      "email": "karim@example.com",
      "token": "mock_jwt_token_karim"
    }
  ]
}
```

Rules for seed data:
- Include at least one record with null/missing optional fields (tests the `JsonParseUtils` path)
- Include at least one record with edge-case values (empty string, zero amount, far-future date)
- Pagination: seed 25+ records for any paginated endpoint

---

## Step 4 — Generate `mock/routes.json`

Map real API paths to json-server's flat resource format:

```json
{
  "/api/v1/orders": "/orders",
  "/api/v1/orders/:id": "/orders/:id",
  "/api/v1/users/me": "/users/1",
  "/api/v1/auth/login": "/auth_login",
  "/api/v1/auth/register": "/auth_register"
}
```

---

## Step 5 — Generate `mock/middleware.js`

Simulate auth, artificial delay, and optional error injection:

```javascript
// mock/middleware.js
module.exports = (req, res, next) => {
  // ── Artificial latency (simulates real network) ──────────
  const delay = process.env.MOCK_DELAY || 300; // ms
  setTimeout(() => {
    
    // ── Auth simulation ───────────────────────────────────
    const publicPaths = ['/api/v1/auth/login', '/api/v1/auth/register'];
    const isPublic = publicPaths.some(p => req.path.startsWith(p));
    
    if (!isPublic) {
      const auth = req.headers['authorization'];
      if (!auth || !auth.startsWith('Bearer ')) {
        return res.status(401).json({
          success: false,
          message: 'Unauthorized',
          code: 'UNAUTHORIZED'
        });
      }
    }

    // ── Standardized response wrapper ─────────────────────
    // Wrap json-server's output in {"success": true, "data": ...}
    // only for GET requests to match your backend's envelope format
    const originalJson = res.json.bind(res);
    res.json = (body) => {
      if (req.method === 'GET' && res.statusCode === 200) {
        return originalJson({ success: true, data: body });
      }
      return originalJson(body);
    };
    
    next();
  }, delay);
};
```

> Adjust the response envelope (`{"success": true, "data": ...}`) to match your actual backend's format. Tell the Agent what envelope your backend uses.

---

## Step 6 — Generate `mock/README.md`

```markdown
# Mock API — <FeatureName>

## Start
```bash
npx json-server --watch mock/db.json --port 3000 \
  --routes mock/routes.json \
  --middlewares mock/middleware.js
```

## Available Endpoints

| Method | Path                    | Description           |
|--------|-------------------------|-----------------------|
| GET    | /api/v1/orders          | List orders (paged)   |
| GET    | /api/v1/orders/:id      | Single order          |
| POST   | /api/v1/orders          | Create order          |
| PATCH  | /api/v1/orders/:id      | Update order          |
| DELETE | /api/v1/orders/:id      | Delete order          |

## Pagination
`GET /api/v1/orders?_page=1&_limit=20`

## Auth Header
`Authorization: Bearer mock_jwt_token_karim`

## Swap to Real Backend
Change only `.env.development`:
```
BASE_URL=http://localhost:3000    ← mock
BASE_URL=https://api.yourapp.com  ← real
```

No app code changes needed.
```

---

## Step 7 — Add npm script to `package.json` (create if absent)

```json
{
  "scripts": {
    "mock": "npx json-server --watch mock/db.json --port 3000 --routes mock/routes.json --middlewares mock/middleware.js",
    "mock:reset": "cp mock/db.seed.json mock/db.json"
  }
}
```

Copy `db.json` to `db.seed.json` as a backup before any test run that mutates data.

---

## Step 8 — Verify the Mock Works

```bash
# Start mock
npm run mock

# Test from terminal
curl http://localhost:3000/api/v1/orders \
  -H "Authorization: Bearer mock_jwt_token_karim"

# Should return { "success": true, "data": [...] }
```

If the response envelope does not match the `DataSource` parsing logic, fix `middleware.js` first — not the app code.

---

## Checklist Before Handing Off to TDD Agent

- [ ] `mock/db.json` has 10+ records per resource
- [ ] `mock/db.json` includes one null-field record and one edge-case record
- [ ] `mock/routes.json` covers all endpoints the feature needs
- [ ] `mock/middleware.js` enforces auth on non-public paths
- [ ] Response envelope matches what `DataSource.fromJson` expects
- [ ] `mock/README.md` documents start command, endpoints, auth header, swap instructions
- [ ] `npm run mock` starts without errors
- [ ] `curl` test returns 200 for a GET and 401 for unauthorized request
- [ ] `.env.development` points to `http://localhost:3000`
- [ ] `FEATURE_REGISTRY.md` updated with mock API status: ✅ ready
