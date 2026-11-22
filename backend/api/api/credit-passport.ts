import type { VercelRequest, VercelResponse } from '@vercel/node';

import { computeCreditPassport } from '../src/credit_passport';
import { auth, db } from '../src/firebase';

/**
 * POST /api/credit-passport
 *
 * Header: Authorization: Bearer <Firebase ID token>
 * Scores the signed-in borrower and returns the Credit Passport. The app
 * calls this from C01 (assessment) once MoMo is linked.
 */
export default async function handler(req: VercelRequest, res: VercelResponse) {
  if (req.method !== 'POST') {
    res.setHeader('Allow', 'POST');
    return res.status(405).json({ error: 'Use POST.' });
  }

  const token = (req.headers.authorization ?? '').replace(/^Bearer /, '');
  if (!token) {
    return res.status(401).json({ error: 'Sign in to build your Credit Passport.' });
  }

  let uid: string;
  try {
    uid = (await auth().verifyIdToken(token)).uid;
  } catch {
    return res.status(401).json({ error: 'Your session has expired. Please sign in again.' });
  }

  try {
    const result = await computeCreditPassport(db(), uid);
    return res.status(200).json(result);
  } catch (e) {
    console.error('credit-passport failed', e);
    return res.status(500).json({ error: 'We could not build your Credit Passport. Try again.' });
  }
}
