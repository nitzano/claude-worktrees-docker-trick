// רץ בתוך הקונטיינר: docker compose exec app npm test
// (על המארח אין DATABASE_URL ואין רשת אל db — וזאת בדיוק הנקודה.)
const { test } = require('node:test');
const assert = require('node:assert');
const { Client } = require('pg');

test('הסידינג רץ ויש notes ב-DB של הסביבה הזאת', async () => {
  const client = new Client({ connectionString: process.env.DATABASE_URL });
  await client.connect();
  try {
    const { rows } = await client.query('SELECT count(*)::int AS n FROM notes');
    assert.ok(rows[0].n >= 2, `expected seeded rows, got ${rows[0].n}`);
  } finally {
    await client.end();
  }
});
