const { before, after, test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} = require('@firebase/rules-unit-testing');

let env;

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-meditrack-rules',
    firestore: {
      rules: fs.readFileSync('firestore.rules', 'utf8'),
      host: '127.0.0.1',
      port: 8080,
    },
  });
});

after(async () => {
  if (env) await env.cleanup();
});

function medication(uid, id = 'med-1') {
  return env.authenticatedContext(uid).firestore()
    .collection('users').doc(uid).collection('medications').doc(id);
}

test('unauthenticated user cannot read a medication', async () => {
  const ref = env.unauthenticatedContext().firestore()
    .doc('users/alice/medications/med-1');
  await assertFails(ref.get());
});

test('owner can create, read, update and delete own medication', async () => {
  const ref = medication('alice');
  await assertSucceeds(ref.set({
    name: 'Exemplo', active: true, createdAt: new Date(), stock: 4,
  }));
  await assertSucceeds(ref.get());
  await assertSucceeds(ref.update({name: 'Exemplo 2'}));
  await assertSucceeds(ref.delete());
});

test('another user cannot read or write owner medication', async () => {
  const ownerRef = medication('alice', 'med-2');
  await assertSucceeds(ownerRef.set({
    name: 'Exemplo', active: true, createdAt: new Date(),
  }));
  const otherRef = env.authenticatedContext('bob').firestore()
    .doc('users/alice/medications/med-2');
  await assertFails(otherRef.get());
  await assertFails(otherRef.update({name: 'Alterado'}));
  await assertFails(otherRef.delete());
});

test('legacy top-level medication collection is denied', async () => {
  const ref = env.authenticatedContext('alice').firestore()
    .doc('medications/legacy-1');
  await assertFails(ref.get());
  await assertFails(ref.set({name: 'Legado'}));
});

test('malformed medication is rejected', async () => {
  await assertFails(medication('alice', 'invalid').set({
    name: '', active: true, createdAt: new Date(),
  }));
  await assertFails(medication('alice', 'invalid2').set({
    name: 'Exemplo', active: true, createdAt: new Date(), stock: -1,
  }));
});

test('owner can confirm a dose once; logs cannot be changed', async () => {
  const ref = env.authenticatedContext('alice').firestore()
    .doc('users/alice/medications/med-1/doseLogs/20261115T0800');
  const payload = {
    status: 'taken',
    scheduledFor: new Date(Date.now() - 60_000),
    recordedAt: require('firebase/compat/app').default.firestore.FieldValue.serverTimestamp(),
  };
  await assertSucceeds(ref.set(payload));
  await assertSucceeds(ref.get());
  await assertFails(ref.set(payload));
  await assertFails(ref.update({status: 'missed'}));
  await assertFails(ref.delete());
});

test('another user and unauthenticated clients cannot confirm a dose', async () => {
  const path = 'users/alice/medications/med-1/doseLogs/20261115T0900';
  const payload = {
    status: 'taken',
    scheduledFor: new Date(Date.now() - 60_000),
    recordedAt: require('firebase/compat/app').default.firestore.FieldValue.serverTimestamp(),
  };
  await assertFails(env.authenticatedContext('bob').firestore().doc(path).set(payload));
  await assertFails(env.unauthenticatedContext().firestore().doc(path).set(payload));
});

test('dose logs reject invalid occurrence ID and future schedule', async () => {
  const root = env.authenticatedContext('alice').firestore()
    .doc('users/alice/medications/med-1');
  await assertFails(root.collection('doseLogs').doc('invalid-id').set({
    status: 'taken',
    scheduledFor: new Date(Date.now() - 60_000),
    recordedAt: require('firebase/compat/app').default.firestore.FieldValue.serverTimestamp(),
  }));
  await assertFails(root.collection('doseLogs').doc('20261115T1000').set({
    status: 'taken',
    scheduledFor: new Date(Date.now() + 3_600_000),
    recordedAt: require('firebase/compat/app').default.firestore.FieldValue.serverTimestamp(),
  }));
});
