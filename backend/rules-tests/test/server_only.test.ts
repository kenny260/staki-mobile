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

const SERVER_ONLY: Record<string, object> = {
  'scores/u1': { value: 720, band: 'good', assessmentStatus: 'complete', factors: [] },
  'momoAccounts/u1': { maskedNumber: '078 *** **67', status: 'connected', eligible: true },
  'momoAccounts/u1/transactions/t1': { date: '2026-06-24', amount: 5000, direction: 'in', category: 'salary', balanceAfter: 12000 },
};

describe('server-only collections: scores, momoAccounts, transactions', () => {
  for (const [path, data] of Object.entries(SERVER_ONLY)) {
    it(`the owner cannot create ${path} from the app`, async () => {
      const db = testEnv.authenticatedContext('u1').firestore();
      await assertFails(setDoc(doc(db, path), data));
    });

    it(`the owner cannot update or delete ${path} from the app`, async () => {
      await testEnv.withSecurityRulesDisabled(async (ctx) => {
        await setDoc(doc(ctx.firestore(), path), data);
      });
      const db = testEnv.authenticatedContext('u1').firestore();
      await assertFails(updateDoc(doc(db, path), { touched: true }));
      await assertFails(deleteDoc(doc(db, path)));
    });

    it(`the owner can read ${path}; another user can't`, async () => {
      await testEnv.withSecurityRulesDisabled(async (ctx) => {
        await setDoc(doc(ctx.firestore(), path), data);
      });
      await assertSucceeds(getDoc(doc(testEnv.authenticatedContext('u1').firestore(), path)));
      await assertFails(getDoc(doc(testEnv.authenticatedContext('u2').firestore(), path)));
    });
  }
});

const lender = {
  phone: '788000222',
  investorType: 'individual',
  kycStatus: 'pending',
  riskAcknowledged: true,
  structureAccepted: true,
};

describe('lenders/{uid}', () => {
  it('owner can create a lender profile with kycStatus pending and no walletBalance', async () => {
    const db = testEnv.authenticatedContext('u1').firestore();
    await assertSucceeds(setDoc(doc(db, 'lenders/u1'), lender));
  });

  it('creating with kycStatus verified is refused', async () => {
    const db = testEnv.authenticatedContext('u1').firestore();
    await assertFails(setDoc(doc(db, 'lenders/u1'), { ...lender, kycStatus: 'verified' }));
  });

  it('creating with a walletBalance is refused', async () => {
    const db = testEnv.authenticatedContext('u1').firestore();
    await assertFails(setDoc(doc(db, 'lenders/u1'), { ...lender, walletBalance: 0 }));
  });

  it('creating without accepting the risk notice is refused', async () => {
    const db = testEnv.authenticatedContext('u1').firestore();
    await assertFails(setDoc(doc(db, 'lenders/u1'), { ...lender, riskAcknowledged: false }));
  });

  it("a user cannot create someone else's lender profile", async () => {
    const db = testEnv.authenticatedContext('u2').firestore();
    await assertFails(setDoc(doc(db, 'lenders/u1'), lender));
  });

  it('owner can edit their phone but not kycStatus or walletBalance', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), 'lenders/u1'), { ...lender, walletBalance: 0 });
    });
    const db = testEnv.authenticatedContext('u1').firestore();
    await assertSucceeds(updateDoc(doc(db, 'lenders/u1'), { phone: '788000333' }));
    await assertFails(updateDoc(doc(db, 'lenders/u1'), { kycStatus: 'verified' }));
    await assertFails(updateDoc(doc(db, 'lenders/u1'), { walletBalance: 1000000 }));
  });

  it('the wallet ledger is read-only for the owner', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), 'lenders/u1/ledger/l1'), { title: 'Deposit', amount: 500000, kind: 'deposit' });
    });
    const db = testEnv.authenticatedContext('u1').firestore();
    await assertSucceeds(getDoc(doc(db, 'lenders/u1/ledger/l1')));
    await assertFails(setDoc(doc(db, 'lenders/u1/ledger/l2'), { title: 'Fake', amount: 9999999, kind: 'deposit' }));
  });
});
