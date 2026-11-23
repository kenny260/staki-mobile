# Staki Fund (Credit Passport)

Staki Fund is the product; the Credit Passport is the 300 to 1000 score it issues.
Flutter mobile app on Firebase, built screen-for-screen from the approved Figma.

- Figma prototype: https://www.figma.com/design/xggLWgTvOM5EErLe6kJGDt
- Design specs and tokens: https://www.figma.com/design/JksKsdPrH82niGSvQT3U0K

## Repository layout

```
frontend/   Flutter app (Clean Architecture: core / data / domain / presentation)
backend/    Firebase: Firestore and Storage rules, indexes, Cloud Functions, seed data
.github/    CI, PR template, CODEOWNERS
```

- Frontend work happens in `frontend/lib/presentation` and `frontend/lib/core`.
- Backend work happens in `backend/` and in `frontend/lib/data` and
  `frontend/lib/domain` (the code the app uses to talk to Firebase).

See `frontend/README.md` and `backend/README.md` for how to run each part.

## How to run

### Frontend (Flutter app)

Needs Flutter 3 and an Android emulator or a phone (Android Studio).

```bash
cd frontend
flutter pub get
flutter run
```

`flutter run` starts the dev version (`lib/main.dart`). To pick a version:

```bash
flutter run -t lib/main_dev.dart       # dev
flutter run -t lib/main_staging.dart   # staging
flutter run -t lib/main_prod.dart      # prod
```

Checks to run before every PR:

```bash
dart format .
flutter analyze
flutter test
```

### Backend (Firebase)

Needs Node.js, the Firebase CLI and Java 21 or newer (the emulators need it).

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

## Branching and PRs

- `main` and `staging` are protected. Nobody pushes to them directly.
- Branch off `staging`, open a PR into `staging`, request a review from
  Abdull-Kudus or Binthia, with Uche (@EucTech) as backup. One approval is
  needed, and nobody merges their own PR. CI must be green.
- `main` only receives `staging` at release.
- Branch names: `<type>/<ticket>-<short-description>` (feature, fix, chore,
  docs, test, refactor). Example: `feature/STK-12-login-email-password`.
- Commits: conventional commits, small and often. Example:
  `feat(auth): add email/password login form`.

## Team

Frontend: Binthia (lead, repo, design system), Chris.
Backend: Uche (Firestore, rules), Tolu (auth, notifications),
Abdull-Kudus (credit scoring engine, report lead).
