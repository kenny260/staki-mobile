# Cloud Functions

TypeScript, Firebase Functions v2.

| Function | Trigger | Owner |
|---|---|---|
| `computeCreditPassport` | Callable from the app (C01) | Abdull-Kudus |

## Run

```bash
cd backend/functions
npm install
npm test          # scoring unit tests + synthetic calibration
npm run build
npm run serve     # emulators (needs Java 21+)
```

Generate the calibration dataset first so the distribution checks run:

```bash
cd backend/scoring-research
python generate_synthetic.py
```

Deploying needs the Firebase project on the Blaze plan.

The scoring model is documented in `backend/scoring-research/MODEL_CARD.md`.
