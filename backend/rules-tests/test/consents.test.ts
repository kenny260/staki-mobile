import { readFileSync } from 'node:fs';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
  type RulesTestEnvironment,
} from '@firebase/rules-unit-testing';
import { deleteDoc, doc, getDoc, serverTimestamp, setDoc, updateDoc } from 'firebase/firestore';
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

const grant = { userId: 'u1', type: 'momo', granted: true, revokedAt: null };

async function seedGrant() {
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(doc(ctx.firestore(), 'consents/c1'), { ...grant, grantedAt: new Date() });
  });
}

describe('consents/{id}: create', () => {
  it('owner can grant MoMo consent for themselves', async () => {
    const db = testEnv.authenticatedContext('u1').firestore();
    await assertSucceeds(setDoc(doc(db, 'consents/c1'), { ...grant, grantedAt: serverTimestamp() }));
  });

  it('a type other than momo is refused', async () => {
    const db = testEnv.authenticatedContext('u1').firestore();
    await assertFails(setDoc(doc(db, 'consents/c1'), { ...grant, type: 'bank' }));
  });

  it('creating a consent that is not granted is refused', async () => {
    const db = testEnv.authenticatedContext('u1').firestore();
    await assertFails(setDoc(doc(db, 'consents/c1'), { ...grant, granted: false }));
  });

  it('creating a consent that is already revoked is refused', async () => {
    const db = testEnv.authenticatedContext('u1').firestore();
    await assertFails(setDoc(doc(db, 'consents/c1'), { ...grant, revokedAt: serverTimestamp() }));
  });

  it('creating a consent for another user is refused', async () => {
    const db = testEnv.authenticatedContext('u1').firestore();
    await assertFails(setDoc(doc(db, 'consents/c1'), { ...grant, userId: 'u2' }));
  });

  it('signed-out users cannot create a consent', async () => {
    const db = testEnv.unauthenticatedContext().firestore();
    await assertFails(setDoc(doc(db, 'consents/c1'), grant));
  });
});

describe('consents/{id}: read, update, delete', () => {
  it("owner can read their consent; another user can't", async () => {
    await seedGrant();
    await assertSucceeds(getDoc(doc(testEnv.authenticatedContext('u1').firestore(), 'consents/c1')));
    await assertFails(getDoc(doc(testEnv.authenticatedContext('u2').firestore(), 'consents/c1')));
  });

  it('owner can revoke with granted false and a timestamp', async () => {
    await seedGrant();
    const db = testEnv.authenticatedContext('u1').firestore();
    await assertSucceeds(updateDoc(doc(db, 'consents/c1'), { granted: false, revokedAt: serverTimestamp() }));
  });

  it('revoking without a timestamp is refused', async () => {
    await seedGrant();
    const db = testEnv.authenticatedContext('u1').firestore();
    await assertFails(updateDoc(doc(db, 'consents/c1'), { granted: false }));
  });

  it('revoking with revokedAt that is not a timestamp is refused', async () => {
    await seedGrant();
    const db = testEnv.authenticatedContext('u1').firestore();
    await assertFails(updateDoc(doc(db, 'consents/c1'), { granted: false, revokedAt: 'yesterday' }));
  });

  it('changing any other field during a revoke is refused', async () => {
    await seedGrant();
    const db = testEnv.authenticatedContext('u1').firestore();
    await assertFails(updateDoc(doc(db, 'consents/c1'), { granted: false, revokedAt: serverTimestamp(), type: 'bank' }));
  });

  it('re-granting a revoked consent is refused', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), 'consents/c1'), { ...grant, granted: false, revokedAt: new Date() });
    });
    const db = testEnv.authenticatedContext('u1').firestore();
    await assertFails(updateDoc(doc(db, 'consents/c1'), { granted: true, revokedAt: null }));
  });

  it("another user cannot revoke the owner's consent", async () => {
    await seedGrant();
    const db = testEnv.authenticatedContext('u2').firestore();
    await assertFails(updateDoc(doc(db, 'consents/c1'), { granted: false, revokedAt: serverTimestamp() }));
  });

  it('deleting a consent is refused, even for the owner', async () => {
    await seedGrant();
    await assertFails(deleteDoc(doc(testEnv.authenticatedContext('u1').firestore(), 'consents/c1')));
  });
});
