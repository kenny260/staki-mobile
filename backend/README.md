# Staki Fund - Backend (Firebase)

```
firebase.json            Firebase config for this folder
firestore.rules          owner-scoped Firestore security rules
firestore.indexes.json   composite indexes
storage.rules            rules for uploaded documents
functions/               Cloud Functions (scoring, auth bootstrap, notifications)
seed/                    demo and staging data scripts
```

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

Start Cloud Functions (first time only, from `backend/`):

```bash
firebase init functions         # choose TypeScript or Python, folder: functions
```

Service-account keys stay on your machine and are gitignored. `.firebaserc`
(the project alias) is safe to commit.

## Owners

- Uche: Firestore data model, ERD, rules, indexes, seed data.
- Tolu: authentication, profile bootstrap, consent ledger, push notifications.
- Abdull-Kudus: credit scoring engine, eligibility, repayment and matching logic.
