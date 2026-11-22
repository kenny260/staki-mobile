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

const loan = {
  borrowerId: 'u1',
  stage: 'submitted',
  amount: 500000,
  termMonths: 6,
  purpose: 'inventory',
  paidAmount: 0,
};

async function seedLoan(id: string, data: object) {
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(doc(ctx.firestore(), `loans/${id}`), data);
  });
}

describe('loans/{loanId}: create', () => {
  it('borrower can submit a valid loan application', async () => {
    const db = testEnv.authenticatedContext('u1').firestore();
    await assertSucceeds(setDoc(doc(db, 'loans/L1'), loan));
  });

  it('the minimum amount of 50,000 is accepted', async () => {
    const db = testEnv.authenticatedContext('u1').firestore();
    await assertSucceeds(setDoc(doc(db, 'loans/L1'), { ...loan, amount: 50000 }));
  });

  it('an amount below 50,000 is refused', async () => {
    const db = testEnv.authenticatedContext('u1').firestore();
    await assertFails(setDoc(doc(db, 'loans/L1'), { ...loan, amount: 49999 }));
  });

  it('a decimal amount is refused', async () => {
    const db = testEnv.authenticatedContext('u1').firestore();
    await assertFails(setDoc(doc(db, 'loans/L1'), { ...loan, amount: 50000.5 }));
  });

  it('terms of 3, 6, 9 and 12 months are accepted', async () => {
    const db = testEnv.authenticatedContext('u1').firestore();
    for (const termMonths of [3, 6, 9, 12]) {
      await assertSucceeds(setDoc(doc(db, `loans/L${termMonths}`), { ...loan, termMonths }));
    }
  });

  it('any other term is refused', async () => {
    const db = testEnv.authenticatedContext('u1').firestore();
    await assertFails(setDoc(doc(db, 'loans/L1'), { ...loan, termMonths: 24 }));
  });

  it('an unknown purpose is refused', async () => {
    const db = testEnv.authenticatedContext('u1').firestore();
    await assertFails(setDoc(doc(db, 'loans/L1'), { ...loan, purpose: 'holiday' }));
  });

  it('a paidAmount other than 0 is refused', async () => {
    const db = testEnv.authenticatedContext('u1').firestore();
    await assertFails(setDoc(doc(db, 'loans/L1'), { ...loan, paidAmount: 1000 }));
  });

  for (const stage of ['underReview', 'approved', 'active', 'fullyRepaid', 'declined']) {
    it(`creating a loan with stage ${stage} is refused`, async () => {
      const db = testEnv.authenticatedContext('u1').firestore();
      await assertFails(setDoc(doc(db, 'loans/L1'), { ...loan, stage }));
    });
  }

  it('creating a loan for another borrower is refused', async () => {
    const db = testEnv.authenticatedContext('u2').firestore();
    await assertFails(setDoc(doc(db, 'loans/L1'), loan));
  });
});

describe('loans/{loanId}: read, update, delete', () => {
  it("borrower can read their loan; another user can't", async () => {
    await seedLoan('L1', loan);
    await assertSucceeds(getDoc(doc(testEnv.authenticatedContext('u1').firestore(), 'loans/L1')));
    await assertFails(getDoc(doc(testEnv.authenticatedContext('u2').firestore(), 'loans/L1')));
  });

  it('borrower cannot change their loan, e.g. move it to approved', async () => {
    await seedLoan('L1', loan);
    const db = testEnv.authenticatedContext('u1').firestore();
    await assertFails(updateDoc(doc(db, 'loans/L1'), { stage: 'approved' }));
  });

  it('borrower can withdraw their loan while it is submitted', async () => {
    await seedLoan('L1', loan);
    const db = testEnv.authenticatedContext('u1').firestore();
    await assertSucceeds(deleteDoc(doc(db, 'loans/L1')));
  });

  it('borrower cannot delete their loan once it is active', async () => {
    await seedLoan('L1', { ...loan, stage: 'active' });
    const db = testEnv.authenticatedContext('u1').firestore();
    await assertFails(deleteDoc(doc(db, 'loans/L1')));
  });

  it("another user cannot delete the borrower's submitted loan", async () => {
    await seedLoan('L1', loan);
    const db = testEnv.authenticatedContext('u2').firestore();
    await assertFails(deleteDoc(doc(db, 'loans/L1')));
  });
});

const repayment = {
  loanId: 'L1',
  borrowerId: 'u1',
  amount: 90000,
  method: 'momo',
  status: 'pending',
};

describe('repayments/{id}', () => {
  beforeEach(async () => {
    await seedLoan('L1', { ...loan, stage: 'active' });
    await seedLoan('L2', { ...loan, borrowerId: 'u2', stage: 'active' });
  });

  it('borrower can create a pending MoMo repayment on their own loan', async () => {
    const db = testEnv.authenticatedContext('u1').firestore();
    await assertSucceeds(setDoc(doc(db, 'repayments/R1'), repayment));
  });

  it('a pending bank repayment is accepted', async () => {
    const db = testEnv.authenticatedContext('u1').firestore();
    await assertSucceeds(setDoc(doc(db, 'repayments/R1'), { ...repayment, method: 'bank' }));
  });

  it('a repayment created as confirmed is refused', async () => {
    const db = testEnv.authenticatedContext('u1').firestore();
    await assertFails(setDoc(doc(db, 'repayments/R1'), { ...repayment, status: 'confirmed' }));
  });

  it('a method other than momo or bank is refused', async () => {
    const db = testEnv.authenticatedContext('u1').firestore();
    await assertFails(setDoc(doc(db, 'repayments/R1'), { ...repayment, method: 'cash' }));
  });

  it('a zero amount is refused', async () => {
    const db = testEnv.authenticatedContext('u1').firestore();
    await assertFails(setDoc(doc(db, 'repayments/R1'), { ...repayment, amount: 0 }));
  });

  it("a repayment pointing at another borrower's loan is refused", async () => {
    const db = testEnv.authenticatedContext('u1').firestore();
    await assertFails(setDoc(doc(db, 'repayments/R1'), { ...repayment, loanId: 'L2' }));
  });

  it('a repayment pointing at a loan that does not exist is refused', async () => {
    const db = testEnv.authenticatedContext('u1').firestore();
    await assertFails(setDoc(doc(db, 'repayments/R1'), { ...repayment, loanId: 'NOPE' }));
  });

  it('borrower cannot confirm or delete a repayment', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), 'repayments/R1'), repayment);
    });
    const db = testEnv.authenticatedContext('u1').firestore();
    await assertFails(updateDoc(doc(db, 'repayments/R1'), { status: 'confirmed' }));
    await assertFails(deleteDoc(doc(db, 'repayments/R1')));
  });
});
