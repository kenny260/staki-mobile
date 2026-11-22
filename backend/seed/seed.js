#!/usr/bin/env node
// Loads the demo data in data.js into Firestore and creates the demo
// login accounts in Firebase Auth. Safe to run again: fixed IDs are
// overwritten, nothing else is touched.
//
//   npm run seed            -> real project (needs serviceAccount.json)
//   npm run seed:emulator   -> local emulators (firebase emulators:start)
//   npm run seed:dry        -> print what would be written, no connection

const path = require('path');
const fs = require('fs');
const data = require('./data');

const PROJECT_ID = 'staki-bc71f';
const args = new Set(process.argv.slice(2));
const dryRun = args.has('--dry-run');
const useEmulator = args.has('--emulator');

function plan() {
  const writes = [];
  for (const [collection, docs] of Object.entries(data.collections)) {
    for (const [id, doc] of Object.entries(docs)) {
      writes.push({ path: `${collection}/${id}`, doc });
    }
  }
  for (const [parent, subs] of Object.entries(data.subcollections)) {
    for (const [sub, byParent] of Object.entries(subs)) {
      for (const [parentId, docs] of Object.entries(byParent)) {
        for (const [id, doc] of Object.entries(docs)) {
          writes.push({ path: `${parent}/${parentId}/${sub}/${id}`, doc });
        }
      }
    }
  }
  return writes;
}

async function seedAuth(auth) {
  for (const user of data.authUsers) {
    const { uid, ...fields } = user;
    try {
      await auth.updateUser(uid, fields);
      console.log(`  auth  updated ${user.email}`);
    } catch (e) {
      if (e.code !== 'auth/user-not-found') throw e;
      await auth.createUser(user);
      console.log(`  auth  created ${user.email}`);
    }
  }
}

async function main() {
  const writes = plan();

  if (dryRun) {
    for (const w of writes) console.log(`  set   ${w.path}`);
    for (const u of data.authUsers) console.log(`  auth  ${u.email}`);
    console.log(`\nDry run: ${writes.length} documents, ` +
      `${data.authUsers.length} auth users. Nothing was written.`);
    return;
  }

  const admin = require('firebase-admin');

  if (useEmulator) {
    process.env.FIRESTORE_EMULATOR_HOST ||= '127.0.0.1:8080';
    process.env.FIREBASE_AUTH_EMULATOR_HOST ||= '127.0.0.1:9099';
    admin.initializeApp({ projectId: PROJECT_ID });
    console.log('Seeding the local emulators...');
  } else {
    const keyPath = process.env.GOOGLE_APPLICATION_CREDENTIALS ||
      path.join(__dirname, 'serviceAccount.json');
    if (!fs.existsSync(keyPath)) {
      console.error(
        `No service account key at ${keyPath}.\n` +
        'Download it from Firebase console > Project settings > ' +
        'Service accounts > Generate new private key, save it as ' +
        'backend/seed/serviceAccount.json (gitignored), then rerun.');
      process.exit(1);
    }
    admin.initializeApp({
      credential: admin.credential.cert(require(keyPath)),
      projectId: PROJECT_ID,
    });
    console.log(`Seeding project ${PROJECT_ID}...`);
  }

  await seedAuth(admin.auth());

  const db = admin.firestore();
  // Firestore batches hold at most 500 writes.
  for (let i = 0; i < writes.length; i += 400) {
    const batch = db.batch();
    for (const w of writes.slice(i, i + 400)) batch.set(db.doc(w.path), w.doc);
    await batch.commit();
  }
  for (const w of writes) console.log(`  set   ${w.path}`);
  console.log(`\nDone: ${writes.length} documents, ` +
    `${data.authUsers.length} auth users.`);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
