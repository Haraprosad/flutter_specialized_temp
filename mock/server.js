// Mock API server for the design/UX phase (Option A — json-server).
//
// Goal: let a designer exercise every screen state (FILLED / EMPTY / ERROR)
// against the same response contract the real backend will use, without any
// backend code. The Flutter app only needs BASE_URL pointed here.
//
// Contract enforced here (matches DioClient + ApiResult<T> expectations):
//   success -> { "success": true,  "message": "OK",    "data": <payload> }
//   error   -> { "success": false, "message": <reason>, "data": null }
//
// State switching (no data edits needed):
//   Header  x-mock-state: empty   | query ?_state=empty   -> data: []
//   Header  x-mock-state: error   | query ?_state=error   -> 500 error envelope
//   Header  x-mock-delay: 1500    | query ?_delay=1500    -> delay N ms (loading state)

const path = require('path');
const jsonServer = require('json-server');

const server = jsonServer.create();
const router = jsonServer.router(path.join(__dirname, 'db.json'));
const middlewares = jsonServer.defaults({ logger: true });

server.use(middlewares);
server.use(jsonServer.bodyParser);

// 1) Forced states — checked before anything touches the data store.
server.use((req, res, next) => {
  const state = req.headers['x-mock-state'] || req.query._state;

  if (state === 'error') {
    const code = parseInt(req.headers['x-mock-status'] || req.query._status || '500', 10);
    return res.status(code).json({
      success: false,
      message: req.headers['x-mock-message'] || 'Mock error state',
      data: null,
    });
  }

  if (state === 'empty') {
    return res.status(200).json({ success: true, message: 'OK', data: [] });
  }

  next();
});

// 2) Latency simulation — lets the designer see/screenshot the loading state.
server.use((req, res, next) => {
  const delay = parseInt(req.headers['x-mock-delay'] || req.query._delay || '0', 10);
  if (delay > 0) return setTimeout(next, delay);
  next();
});

// 3) Wrap every successful json-server response in the success envelope.
router.render = (req, res) => {
  res.json({ success: true, message: 'OK', data: res.locals.data });
};

server.use(router);

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`\n  Mock API ready at http://localhost:${PORT}`);
  console.log('  Force states:  ?_state=empty | ?_state=error | ?_delay=1500');
  console.log('  Or headers:    x-mock-state / x-mock-delay / x-mock-status\n');
});
