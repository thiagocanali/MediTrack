'use strict';
const test = require('node:test');
const assert = require('node:assert/strict');
const http = require('node:http');
const { createMedicationHandler } = require('../src/http.cjs');

function poolStub() {
  const calls = [];
  return {
    calls,
    async connect() {
      return { async query(sql, params) {
        calls.push({ sql, params });
        return { rows: sql.startsWith('SELECT id') ? [{ id: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', name: 'Meds' }] : sql.startsWith('INSERT') ? [{ id: params[0], name: params[2] }] : [] };
      }, release() {} };
    },
  };
}
async function withServer(handler, run) {
  const server = http.createServer(handler);
  await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
  try { await run('http://127.0.0.1:' + server.address().port); }
  finally { await new Promise((resolve, reject) => server.close(e => e ? reject(e) : resolve())); }
}
test('rejects unauthenticated requests before database access', async () => {
  const pool = poolStub();
  await withServer(createMedicationHandler({ pool, authenticate: async () => null }), async base => {
    const response = await fetch(base + '/api/v1/medications');
    assert.equal(response.status, 401);
  });
  assert.equal(pool.calls.length, 0);
});
test('GET uses account identity returned by authenticator', async () => {
  const pool = poolStub();
  const account = '11111111-1111-4111-8111-111111111111';
  await withServer(createMedicationHandler({ pool, authenticate: async () => ({ accountId: account }) }), async base => {
    const response = await fetch(base + '/api/v1/medications');
    assert.equal(response.status, 200);
    assert.equal((await response.json()).items.length, 1);
  });
  assert.deepEqual(pool.calls[1].params, [account]);
});
test('POST rejects invalid names and never accepts account ID from body', async () => {
  const pool = poolStub();
  const account = '11111111-1111-4111-8111-111111111111';
  await withServer(createMedicationHandler({ pool, authenticate: async () => ({ accountId: account }) }), async base => {
    const bad = await fetch(base + '/api/v1/medications', { method: 'POST', headers: { 'content-type': 'application/json' }, body: JSON.stringify({ name: ' ', accountId: '22222222-2222-4222-8222-222222222222' }) });
    assert.equal(bad.status, 422);
    const good = await fetch(base + '/api/v1/medications', { method: 'POST', headers: { 'content-type': 'application/json' }, body: JSON.stringify({ name: ' My medication ', accountId: '22222222-2222-4222-8222-222222222222' }) });
    assert.equal(good.status, 201);
  });
  const insert = pool.calls.find(c => c.sql.startsWith('INSERT'));
  assert.equal(insert.params[1], account);
});
