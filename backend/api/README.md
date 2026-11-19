# Scoring API (Vercel)

Serverless API that computes the Credit Passport. Runs free on Vercel
(Hobby plan, no card). Firestore stays the database and Cloudinary stays
the file storage.

We do not use Firebase Cloud Functions: they need the Blaze plan, which has
no spending cap.

| Endpoint | What it does | Owner |
|---|---|---|
| `POST /api/credit-passport` | Scores the signed-in borrower, writes `scores/{uid}` | Abdull-Kudus |
| `POST /api/bootstrap-profile` (planned) | Creates `profiles/{uid}` right after sign-up | Tolu |
| Consents and push notifications (planned) | Consent writes, FCM pushes | Tolu |
| Eligibility, repayment, matching (planned) | Loan decision logic | Abdull-Kudus |

Send the user's Firebase ID token as `Authorization: Bearer <token>`.

## Adding an endpoint

1. Every file in `api/` is one endpoint: `api/bootstrap-profile.ts` is served
   at `POST /api/bootstrap-profile`. Copy `api/credit-passport.ts` as a template.
2. Put the logic in `src/` and keep the handler thin. Use `db()` and `auth()`
   from `src/firebase.ts`; the Firebase Admin setup is already done there.
3. Check the caller: read `Authorization: Bearer <ID token>` and call
   `auth().verifyIdToken(token)`. Return `401` if it is missing or invalid.
4. Add tests in `test/` and run `npm run typecheck` and `npm test`.

There are no automatic triggers like Cloud Functions' "on user created".
The app calls the endpoint itself, for example right after sign-up.
Push notifications are sent with `firebase-admin` messaging from an endpoint.

For local runs, put the service account JSON in the `FIREBASE_SERVICE_ACCOUNT`
environment variable. Ask Abdull-Kudus or Uche for it privately; never commit it.

## Run and test

```bash
cd backend/api
npm install
npm test            # scoring unit tests + synthetic calibration
npm run typecheck
```

Generate the calibration dataset first so the distribution checks run:

```bash
cd backend/scoring-research
python generate_synthetic.py
```

## Deploy (once)

1. Sign in at vercel.com with GitHub and import this repo.
2. Set **Root Directory** to `backend/api`.
3. Add the environment variable `FIREBASE_SERVICE_ACCOUNT` with the full JSON
   from Firebase Console > Project settings > Service accounts > Generate new
   private key. Never commit this key.
4. Deploy. The app calls `https://<project>.vercel.app/api/credit-passport`.

The scoring model is documented in `backend/scoring-research/MODEL_CARD.md`.
