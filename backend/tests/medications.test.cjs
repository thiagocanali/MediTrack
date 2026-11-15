'use strict';
const test = require('node:test');
const assert = require('node:assert/strict');
const { validateName, withAccount, listMedications, createMedication, renameMedication } = require('../src/medications.cjs');
const alice = '11111111-1111-4111-8111-111111111111';
const med = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';

function fakePool({ failAt } = {}) {
  const calls = [];
  let released = 0;
  const client = {
    async query(sql, params) {
      calls.push({ sql, params });
      if (failAt && sql.startsWith(failAt)) throw new Error('db unavailable');
      return { rows: [{ id: med, name: 'Test' }] };
    },
    release() { released++; },
  };
  return { connect: async () => client, calls, get released() { return released; } };
}
test('name validation rejects invalid and oversized values', () => {
  assert.equal(validateName('  Test  '), 'Test');
  for (const name of ['', '  ', 123, 'x'.repeat(161)]) {
    assert.throws(() => validateName(name));
  }
});
test('transaction sets LOCAL identity before data query and releases connection', async () => {
  const pool = fakePool();
  const result = await listMedications(pool, alice);
  assert.equal(result.length, 1);
  assert.deepEqual(pool.calls.map(c => c.sql.split(' ')[0]), ['BEGIN', 'SELECT', 'SELECT', 'COMMIT']);
  assert.deepEqual(pool.calls[1].params, [alice]);
  assert.deepEqual(pool.calls[2].params, [alice]);
  assert.equal(pool.released, 1);
});
test('rollback on failure and release', async () => {
  const pool = fakePool({ failAt: 'INSERT' });
  await assert.rejects(createMedication(pool, alice, med, 'Test'), /db unavailable/);
  assert.equal(pool.calls.at(-1).sql, 'ROLLBACK');
  assert.equal(pool.released, 1);
});
test('rejects unverified identity before borrowing a connection', async () => {
  const pool = fakePool();
  await assert.rejects(listMedications(pool, 'attacker'), /Verified account UUID/);
  assert.equal(pool.calls.length, 0);
});
test('create and rename queries scope account and use parameters', async () => {
  const pool = fakePool();
  await createMedication(pool, alice, med, ' Medicine ');
  await renameMedication(pool, alice, med, ' Updated ');
  const writes = pool.calls.filter(c => /^(INSERT|UPDATE)/.test(c.sql));
  assert.equal(writes.length, 2);
  assert.deepEqual(writes[0].params, [med, alice, 'Medicine']);
  assert.deepEqual(writes[1].params, [med, alice, 'Updated']);
  assert.match(writes[1].sql, /user_id=\$2/);
});
