'use strict';
const { randomUUID } = require('node:crypto');
const { listMedications, createMedication, renameMedication } = require('./medications.cjs');

function send(res, status, body) {
  res.writeHead(status, { 'content-type': 'application/json; charset=utf-8', 'cache-control': 'no-store' });
  res.end(body === undefined ? '' : JSON.stringify(body));
}
async function readJson(req, limit = 8192) {
  let raw = '';
  for await (const chunk of req) {
    raw += chunk;
    if (Buffer.byteLength(raw) > limit) {
      const error = new Error('Request body too large'); error.status = 413; throw error;
    }
  }
  if (!raw) return {};
  try { return JSON.parse(raw); }
  catch { const error = new Error('Invalid JSON'); error.status = 400; throw error; }
}

// authenticate(req) must validate a real server-side session and return
// { accountId }. It must never trust account IDs from request input.
function createMedicationHandler({ pool, authenticate }) {
  if (!pool || typeof authenticate !== 'function') throw new TypeError('pool and authenticate are required');
  return async function handler(req, res) {
    try {
      const url = new URL(req.url, 'http://localhost');
      if (url.pathname !== '/api/v1/medications' && !/^\/api\/v1\/medications\/[0-9a-f-]{36}$/i.test(url.pathname)) return send(res, 404, { error: { code: 'NOT_FOUND' } });
      const session = await authenticate(req);
      if (!session || typeof session.accountId !== 'string') return send(res, 401, { error: { code: 'UNAUTHENTICATED' } });
      if (url.pathname === '/api/v1/medications' && req.method === 'GET') {
        return send(res, 200, { items: await listMedications(pool, session.accountId) });
      }
      if (url.pathname === '/api/v1/medications' && req.method === 'POST') {
        const body = await readJson(req);
        const item = await createMedication(pool, session.accountId, randomUUID(), body.name);
        return send(res, 201, item);
      }
      const match = url.pathname.match(/^\/api\/v1\/medications\/([0-9a-f-]{36})$/i);
      if (match && req.method === 'PATCH') {
        const body = await readJson(req);
        const item = await renameMedication(pool, session.accountId, match[1], body.name);
        return item ? send(res, 200, item) : send(res, 404, { error: { code: 'NOT_FOUND' } });
      }
      return send(res, 405, { error: { code: 'METHOD_NOT_ALLOWED' } });
    } catch (error) {
      if (error.status) return send(res, error.status, { error: { code: error.status === 413 ? 'BODY_TOO_LARGE' : 'INVALID_REQUEST' } });
      if (error instanceof TypeError || error instanceof RangeError) return send(res, 422, { error: { code: 'VALIDATION_ERROR', message: error.message } });
      if (error.code === '23505') return send(res, 409, { error: { code: 'CONFLICT' } });
      // Do not leak database or authentication internals.
      return send(res, 500, { error: { code: 'INTERNAL_ERROR' } });
    }
  };
}
module.exports = { createMedicationHandler };
