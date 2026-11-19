import { initializeApp } from 'firebase-admin/app';
import { FieldValue, getFirestore } from 'firebase-admin/firestore';
import { HttpsError, onCall } from 'firebase-functions/v2/https';

import { scoreBorrower } from './scoring/scorecard';
import { Transaction, Verification } from './scoring/types';

initializeApp();

/**
 * Computes the signed-in borrower's Credit Passport and saves it to
 * scores/{uid}. Called by the app from C01 (assessment) once MoMo is linked.
 *
 * Reads: momoAccounts/{uid}/transactions, profiles/{uid},
 *        users/{uid}/documents, consents (bank).
 * Writes: scores/{uid} (clients cannot write there, see firestore.rules).
 */
export const computeCreditPassport = onCall(
  { region: 'europe-west1' },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError('unauthenticated', 'Sign in to build your Credit Passport.');
    }
    const db = getFirestore();

    const [txSnap, profileSnap, docsSnap, bankSnap] = await Promise.all([
      db.collection('momoAccounts').doc(uid).collection('transactions').get(),
      db.collection('profiles').doc(uid).get(),
      db.collection('users').doc(uid).collection('documents').get(),
      db
        .collection('consents')
        .where('userId', '==', uid)
        .where('type', '==', 'bank')
        .where('revokedAt', '==', null)
        .limit(1)
        .get(),
    ]);

    const txs = txSnap.docs.map((d) => d.data() as Transaction);
    const verification: Verification = {
      idVerified: profileSnap.get('idVerified') === true,
      bankConnected: !bankSnap.empty,
      documentsVerified: docsSnap.docs.some((d) => d.get('status') === 'verified'),
    };

    const result = scoreBorrower(txs, verification);
    await db
      .collection('scores')
      .doc(uid)
      .set({ ...result, updatedAt: FieldValue.serverTimestamp() });

    return result;
  },
);
