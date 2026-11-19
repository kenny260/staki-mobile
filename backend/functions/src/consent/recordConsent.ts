import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

if (admin.apps.length === 0) admin.initializeApp();

// Agree this list with the team; add types as the product needs them.
const TYPES = ["data_processing", "credit_scoring", "marketing", "notifications"];
const ACTIONS = ["granted", "revoked"];

/**
 * Append-only consent ledger. Clients cannot write consents directly
 * (see firestore.rules); only this function can, so timestamps are trusted.
 */
export const recordConsent = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Sign in first.");
  }
  const { type, action, version, source } = request.data ?? {};

  if (!TYPES.includes(type)) {
    throw new HttpsError("invalid-argument", "Unknown consent type.");
  }
  if (!ACTIONS.includes(action)) {
    throw new HttpsError("invalid-argument", "Action must be granted or revoked.");
  }
  if (typeof version !== "string" || version.length === 0 || version.length > 20) {
    throw new HttpsError("invalid-argument", "A consent version is required.");
  }

  const db = admin.firestore();
  const userRef = db.doc(`users/${request.auth.uid}`);
  const ledgerRef = userRef.collection("consents").doc();
  const now = admin.firestore.FieldValue.serverTimestamp();

  await db.runTransaction(async (tx) => {
    tx.set(ledgerRef, {
      type,
      action,
      version,
      source: typeof source === "string" ? source.slice(0, 40) : "app",
      timestamp: now,
    });
    // Denormalised "current status" for quick reads.
    tx.set(
      userRef,
      {
        consentState: {
          [type]: { granted: action === "granted", version, updatedAt: now },
        },
      },
      { merge: true }
    );
  });

  return { id: ledgerRef.id };
});
