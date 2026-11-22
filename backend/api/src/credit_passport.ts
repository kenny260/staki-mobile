import { FieldValue, Firestore } from 'firebase-admin/firestore';

import { scoreBorrower } from './scoring/scorecard';
import { ScoreResult, Transaction, Verification } from './scoring/types';

/**
 * Reads the borrower's data from Firestore, scores it and saves the result
 * to scores/{uid}. Clients cannot write there (see firestore.rules), so only
 * this server can set a score.
 *
 * Reads: momoAccounts/{uid}/transactions, profiles/{uid},
 *        users/{uid}/documents, consents (bank).
 */
export async function computeCreditPassport(db: Firestore, uid: string): Promise<ScoreResult> {
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
}
