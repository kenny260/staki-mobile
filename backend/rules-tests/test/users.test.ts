import { readFileSync } from 'node:fs';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
  type RulesTestEnvironment,
} from '@firebase/rules-unit-testing';
import { deleteDoc, doc, getDoc, setDoc, updateDoc } from 'firebase/firestore';
import { afterAll, beforeAll, beforeEach, describe, it } from 'vitest';

let testEnv: RulesTestEnvironment;

beforeAll(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: 'demo-staki',
    firestore: { rules: readFileSync('../firestore.rules', 'utf8') },
  });
});

beforeEach(async () => {
  await testEnv.clearFirestore();
});

afterAll(async () => {
  await testEnv.cleanup();
});

const borrower = { role: 'borrower', email: 'u1@staki.test', displayName: 'U One' };

async function seedUser() {
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(doc(ctx.firestore(), 'users/u1'), borrower);
  });
}

describe('users/{uid}', () => {
  it('owner can create their user doc with role borrower', async () => {
    const db = testEnv.authenticatedContext('u1').firestore();
    await assertSucceeds(setDoc(doc(db, 'users/u1'), borrower));
  });

  it('owner can create their user doc with role lender', async () => {
    const db = testEnv.authenticatedContext('u1').firestore();
    await assertSucceeds(setDoc(doc(db, 'users/u1'), { ...borrower, role: 'lender' }));
  });

  it('owner cannot create their user doc with role admin', async () => {
    const db = testEnv.authenticatedContext('u1').firestore();
    await assertFails(setDoc(doc(db, 'users/u1'), { ...borrower, role: 'admin' }));
  });

  it("a user cannot create someone else's user doc", async () => {
    const db = testEnv.authenticatedContext('u2').firestore();
    await assertFails(setDoc(doc(db, 'users/u1'), borrower));
  });

  it('signed-out users cannot create a user doc', async () => {
    const db = testEnv.unauthenticatedContext().firestore();
    await assertFails(setDoc(doc(db, 'users/u1'), borrower));
  });

  it('owner can update displayName', async () => {
    await seedUser();
    const db = testEnv.authenticatedContext('u1').firestore();
    await assertSucceeds(updateDoc(doc(db, 'users/u1'), { displayName: 'New Name' }));
  });

  it('owner cannot change role', async () => {
    await seedUser();
    const db = testEnv.authenticatedContext('u1').firestore();
    await assertFails(updateDoc(doc(db, 'users/u1'), { role: 'lender' }));
  });

  it('owner can read their user doc', async () => {
    await seedUser();
    const db = testEnv.authenticatedContext('u1').firestore();
    await assertSucceeds(getDoc(doc(db, 'users/u1')));
  });

  it('another user cannot read users/u1', async () => {
    await seedUser();
    const db = testEnv.authenticatedContext('u2').firestore();
    await assertFails(getDoc(doc(db, 'users/u1')));
  });

  it('signed-out users cannot read users/u1', async () => {
    await seedUser();
    const db = testEnv.unauthenticatedContext().firestore();
    await assertFails(getDoc(doc(db, 'users/u1')));
  });

  it('nobody can delete users/u1, not even the owner', async () => {
    await seedUser();
    await assertFails(deleteDoc(doc(testEnv.authenticatedContext('u1').firestore(), 'users/u1')));
    await assertFails(deleteDoc(doc(testEnv.authenticatedContext('u2').firestore(), 'users/u1')));
  });
});
