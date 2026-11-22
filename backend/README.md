# Staki Fund - Backend (Firebase)

```
firebase.json            Firebase config for this folder
firestore.rules          owner-scoped Firestore security rules
firestore.indexes.json   composite indexes
storage.rules            rules for uploaded documents
api/                     server API on Vercel (scoring, eligibility, repayment, matching)
seed/                    demo and staging data scripts
rules-tests/             unit tests for firestore.rules (emulator)
```

Project: `staki-bc71f` (Firestore in `africa-south1`). Files and images are
stored on Cloudinary, not Firebase Storage, so `storage.rules` is unused.

## How to run

Needs Node.js, the Firebase CLI and Java 21 or newer (the emulators need it). Run everything from the `backend/` folder.

```bash
cd backend
npm install -g firebase-tools   # once
firebase login                  # once
firebase use --add              # once, pick the Staki Firebase project
firebase emulators:start        # run Firestore, Auth and Storage locally
```

The emulator dashboard opens at http://localhost:4000. To try the emulators
before the real Firebase project exists, use a demo project:
`firebase emulators:start --project demo-staki`.

Deploy rules and indexes (Uche):

```bash
firebase deploy --only firestore:rules,firestore:indexes,storage
```

## Testing

`rules-tests/` checks that `firestore.rules` allows and refuses the right
writes: owner-only access, the role that can't change, server-only scores and
MoMo data, the consent ledger, loans and repayments. The tests start a
Firestore emulator on the `demo-staki` project, so they never touch real data.
Java 21 or newer is needed for the emulator.

```bash
cd backend/rules-tests && npm install && npm test
```

Run them before deploying rules. When you change a rule, add or update the
test for it in the matching file under `rules-tests/test/`.

## Server code goes in `api/`, not Cloud Functions

We do not use Firebase Cloud Functions. They need the Blaze plan, which has no
spending cap. Do **not** run `firebase init functions`. Server-only logic
(scoring, eligibility, repayment, matching) goes in `backend/api` and deploys
free to Vercel. Auth (email/password, Google), profile creation on sign-up and
consent writes run in the Flutter app on Firebase Auth and Firestore, which
are free on Spark. See `api/README.md` for how to add an endpoint.

Service-account keys stay on your machine and are gitignored. `.firebaserc`
(the project alias) is safe to commit.

## Owners

- Uche: Firestore data model, ERD, rules, indexes, seed data.
- Tolu: authentication, profile bootstrap, consent ledger, push notifications.
- Abdull-Kudus: credit scoring engine, eligibility, repayment and matching logic.
