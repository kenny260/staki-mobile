import { readFileSync } from 'node:fs';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
  type RulesTestEnvironment,
} from '@firebase/rules-unit-testing';
import { deleteDoc, doc, getDoc, setDoc } from 'firebase/firestore';
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

const profile = { borrowerType: 'business', answers: { businessName: 'Kigali Fresh Market' } };

const CLOUDINARY = 'https://res.cloudinary.com/ybzufhwg/image/upload/v1/national_id.jpg';
const document = {
  fileName: 'national_id.jpg',
  url: CLOUDINARY,
  status: 'underReview',
};

describe('profiles/{uid}', () => {
  it('owner can create a profile with a valid borrowerType and an answers map', async () => {
    const db = testEnv.authenticatedContext('u1').firestore();
    await assertSucceeds(setDoc(doc(db, 'profiles/u1'), profile));
  });

  it('profile create is refused with an unknown borrowerType', async () => {
    const db = testEnv.authenticatedContext('u1').firestore();
    await assertFails(setDoc(doc(db, 'profiles/u1'), { ...profile, borrowerType: 'investor' }));
  });

  it('profile create is refused when answers is not a map', async () => {
    const db = testEnv.authenticatedContext('u1').firestore();
    await assertFails(setDoc(doc(db, 'profiles/u1'), { ...profile, answers: 'none' }));
  });

  it('profile create is refused when answers is missing', async () => {
    const db = testEnv.authenticatedContext('u1').firestore();
    await assertFails(setDoc(doc(db, 'profiles/u1'), { borrowerType: 'business' }));
  });

  it("a user cannot create someone else's profile", async () => {
    const db = testEnv.authenticatedContext('u2').firestore();
    await assertFails(setDoc(doc(db, 'profiles/u1'), profile));
  });

  it("another user cannot read the owner's profile", async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), 'profiles/u1'), profile);
    });
    await assertSucceeds(getDoc(doc(testEnv.authenticatedContext('u1').firestore(), 'profiles/u1')));
    await assertFails(getDoc(doc(testEnv.authenticatedContext('u2').firestore(), 'profiles/u1')));
  });
});

describe('users/{uid}/documents/{documentType}', () => {
  it('owner can submit a known document for review with a Cloudinary URL', async () => {
    const db = testEnv.authenticatedContext('u1').firestore();
    await assertSucceeds(setDoc(doc(db, 'users/u1/documents/national_id'), document));
  });

  it('every known document id is accepted', async () => {
    const db = testEnv.authenticatedContext('u1').firestore();
    for (const id of ['national_id', 'momo_statement', 'business_registration', 'bank_statement', 'proof_of_enrollment']) {
      await assertSucceeds(setDoc(doc(db, `users/u1/documents/${id}`), document));
    }
  });

  it('an unknown document id is refused', async () => {
    const db = testEnv.authenticatedContext('u1').firestore();
    await assertFails(setDoc(doc(db, 'users/u1/documents/passport'), document));
  });

  it('status verified from the app is refused', async () => {
    const db = testEnv.authenticatedContext('u1').firestore();
    await assertFails(setDoc(doc(db, 'users/u1/documents/national_id'), { ...document, status: 'verified' }));
  });

  it('status needsAttention from the app is refused', async () => {
    const db = testEnv.authenticatedContext('u1').firestore();
    await assertFails(setDoc(doc(db, 'users/u1/documents/national_id'), { ...document, status: 'needsAttention' }));
  });

  it('a URL from another Cloudinary account is refused', async () => {
    const db = testEnv.authenticatedContext('u1').firestore();
    const url = 'https://res.cloudinary.com/someone-else/image/upload/v1/national_id.jpg';
    await assertFails(setDoc(doc(db, 'users/u1/documents/national_id'), { ...document, url }));
  });

  it('a URL that is not on Cloudinary is refused', async () => {
    const db = testEnv.authenticatedContext('u1').firestore();
    const url = 'https://example.com/ybzufhwg/national_id.jpg';
    await assertFails(setDoc(doc(db, 'users/u1/documents/national_id'), { ...document, url }));
  });

  it("a user cannot submit a document into someone else's folder", async () => {
    const db = testEnv.authenticatedContext('u2').firestore();
    await assertFails(setDoc(doc(db, 'users/u1/documents/national_id'), document));
  });

  it('owner can read and delete their own document', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), 'users/u1/documents/national_id'), document);
    });
    const db = testEnv.authenticatedContext('u1').firestore();
    await assertSucceeds(getDoc(doc(db, 'users/u1/documents/national_id')));
    await assertSucceeds(deleteDoc(doc(db, 'users/u1/documents/national_id')));
  });

  it("another user cannot read or delete the owner's document", async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), 'users/u1/documents/national_id'), document);
    });
    const db = testEnv.authenticatedContext('u2').firestore();
    await assertFails(getDoc(doc(db, 'users/u1/documents/national_id')));
    await assertFails(deleteDoc(doc(db, 'users/u1/documents/national_id')));
  });
});
