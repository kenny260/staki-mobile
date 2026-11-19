# Scoring API (Vercel)

Serverless API that computes the Credit Passport. Runs free on Vercel
(Hobby plan, no card). Firestore stays the database and Cloudinary stays
the file storage.

We do not use Firebase Cloud Functions: they need the Blaze plan, which has
no spending cap.

| Endpoint | What it does | Owner |
|---|---|---|
| `POST /api/credit-passport` | Scores the signed-in borrower, writes `scores/{uid}` | Abdull-Kudus |

Send the user's Firebase ID token as `Authorization: Bearer <token>`.

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
