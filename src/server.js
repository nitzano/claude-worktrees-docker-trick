const http = require('node:http');
const os = require('node:os');
const { Client } = require('pg');

const PORT = 3000; // הפורט *בתוך* הקונטיינר — תמיד קבוע. רק המיפוי החיצוני משתנה.
const DATABASE_URL = process.env.DATABASE_URL;
const ENV_NAME = process.env.ENV_NAME || 'unknown';

async function queryDb(sql) {
  const client = new Client({ connectionString: DATABASE_URL });
  await client.connect();
  try {
    return await client.query(sql);
  } finally {
    await client.end();
  }
}

const routes = {
  '/health': async () => ({ status: 'ok' }),

  '/': async () => {
    const { rows } = await queryDb('SELECT id, title FROM notes ORDER BY id');
    return {
      env: ENV_NAME,
      container: os.hostname(),
      greeting: process.env.APP_GREETING || '(no .env loaded)',
      notes: rows,
    };
  },
};

http
  .createServer(async (req, res) => {
    const path = new URL(req.url, 'http://localhost').pathname;
    const handler = routes[path];
    res.setHeader('content-type', 'application/json; charset=utf-8');

    if (!handler) {
      res.writeHead(404).end(JSON.stringify({ error: 'not found' }));
      return;
    }

    try {
      res.writeHead(200).end(JSON.stringify(await handler(), null, 2));
    } catch (err) {
      res.writeHead(500).end(JSON.stringify({ error: err.message }));
    }
  })
  .listen(PORT, () => console.log(`[${ENV_NAME}] listening on :${PORT}`));
