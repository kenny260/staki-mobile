# Staki Fund - Backend (Firebase)

```
firebase.json            Firebase config for this folder
firestore.rules          owner-scoped Firestore security rules
firestore.indexes.json   composite indexes
storage.rules            rules for uploaded documents
functions/               Cloud Functions (scoring, auth bootstrap, notifications)
seed/                    demo and staging data scripts
```

## Getting started

Run these from the `backend/` folder.

```bash
cd backend
npm install -g firebase-tools   # once
firebase login
firebase use --add              # pick the Firebase project (Uche creates it)
firebase emulators:start        # run Firestore, Auth, Storage locally
firebase deploy --only firestore:rules,firestore:indexes,storage
```

Service-account keys stay on your machine and are gitignored. `.firebaserc`
(the project alias) is safe to commit.

## Owners

- Uche: Firestore data model, ERD, rules, indexes, seed data.
- Tolu: authentication, profile bootstrap, consent ledger, push notifications.
- Abdull-Kudus: credit scoring engine, eligibility, repayment and matching logic.
