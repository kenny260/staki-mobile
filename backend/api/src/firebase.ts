import { cert, getApps, initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore } from 'firebase-admin/firestore';

/**
 * Firebase Admin, set up once per server instance.
 *
 * FIREBASE_SERVICE_ACCOUNT is the service account JSON from
 * Firebase Console > Project settings > Service accounts, pasted into
 * Vercel as an environment variable. It is never committed.
 */
function app() {
  if (getApps().length > 0) return getApps()[0];
  const raw = process.env.FIREBASE_SERVICE_ACCOUNT;
  if (!raw) throw new Error('FIREBASE_SERVICE_ACCOUNT is not set');
  return initializeApp({ credential: cert(JSON.parse(raw)) });
}

export const db = () => getFirestore(app());
export const auth = () => getAuth(app());
