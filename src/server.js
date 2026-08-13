const http = require('node:http');
const os = require('node:os');
const { Client } = require('pg');

const PORT = 3000; // the port *inside* the container — always fixed. Only the host mapping varies.
const DATABASE_URL = process.env.DATABASE_URL;

async function handle() {
  const client = new Client({ connectionString: DATABASE_URL });
  await client.connect();
  try {
    const { rows } = await client.query('SELECT id, title FROM notes ORDER BY id');
    return {
      // the hostname carries compose's project name, e.g. feature-1-app-1,
      // which is how you tell which environment answered
      container: os.hostname(),
      greeting: process.env.APP_GREETING || '(no .env loaded)',
      notes: rows,
    };
  } finally {
    await client.end();
  }
}

http
  .createServer(async (_req, res) => {
    res.setHeader('content-type', 'application/json; charset=utf-8');
    try {
      res.writeHead(200).end(JSON.stringify(await handle(), null, 2));
    } catch (err) {
      res.writeHead(500).end(JSON.stringify({ error: err.message }));
    }
  })
  .listen(PORT, () => console.log(`[${os.hostname()}] listening on :${PORT}`));
