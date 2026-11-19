'use strict';

// Database boundary: the caller MUST authenticate the request and supply its
// verified account UUID. Never take accountId from request JSON or query params.
const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

function validateAccountId(accountId) {
  if (typeof accountId !== 'string' || !UUID.test(accountId)) {
    throw new TypeError('Verified account UUID required');
  }
}
function validateName(name) {
  if (typeof name !== 'string') throw new TypeError('Medication name must be a string');
  const normalized = name.trim();
  if (!normalized || [...normalized].length > 160) {
    throw new RangeError('Medication name must contain 1 to 160 characters');
  }
  return normalized;
}
async function withAccount(pool, accountId, work) {
  validateAccountId(accountId);
  const client = await pool.connect();
  let began = false;
  try {
    await client.query('BEGIN');
    began = true;
    await client.query("SELECT set_config('app.user_id', $1, true)", [accountId]);
    const result = await work(client);
    await client.query('COMMIT');
    began = false;
    return result;
  } catch (error) {
    if (began) {
      try { await client.query('ROLLBACK'); } catch { /* retain original error */ }
    }
    throw error;
  } finally {
    client.release();
  }
}
async function listMedications(pool, accountId) {
  return withAccount(pool, accountId, async client => {
    const result = await client.query(
      'SELECT id, name, active, created_at, updated_at FROM medications WHERE user_id = $1 ORDER BY created_at DESC, id DESC LIMIT 100',
      [accountId]
    );
    return result.rows;
  });
}
async function createMedication(pool, accountId, id, name) {
  validateAccountId(id);
  const normalized = validateName(name);
  return withAccount(pool, accountId, async client => {
    const result = await client.query(
      'INSERT INTO medications (id, user_id, name) VALUES ($1, $2, $3) RETURNING id, name, active, created_at, updated_at',
      [id, accountId, normalized]
    );
    return result.rows[0];
  });
}
async function renameMedication(pool, accountId, id, name) {
  validateAccountId(id);
  const normalized = validateName(name);
  return withAccount(pool, accountId, async client => {
    const result = await client.query(
      'UPDATE medications SET name=$3, updated_at=now() WHERE id=$1 AND user_id=$2 RETURNING id, name, active, created_at, updated_at',
      [id, accountId, normalized]
    );
    return result.rows[0] ?? null;
  });
}
module.exports = { validateName, withAccount, listMedications, createMedication, renameMedication };
