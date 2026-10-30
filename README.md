# Staki Fund (Credit Passport) - Mobile

Production-grade Flutter app on Firebase, built screen-for-screen from the approved Figma.
Staki Fund is the product; the Credit Passport is the 300 to 1000 score it issues.

- Figma prototype: https://www.figma.com/design/xggLWgTvOM5EErLe6kJGDt
- Design specs and tokens: https://www.figma.com/design/JksKsdPrH82niGSvQT3U0K

## Tech stack

Flutter 3 / Dart 3, Riverpod (state), go_router (navigation), freezed (models),
Firebase (Auth, Firestore, Storage, Messaging), shared_preferences, local_auth.

## Project structure (Clean Architecture)

```
lib/
  core/            theme/tokens, router, constants, errors, utils
  data/            datasources (Firebase), models, repositories
  domain/          entities, repository contracts, usecases
  presentation/    features/* (pages, widgets, providers), shared_widgets
  app.dart         root widget
  bootstrap.dart   shared startup
  main.dart        default entry (dev)
  main_dev.dart / main_staging.dart / main_prod.dart   flavour entries
```

Rules: no raw hex in screens (use the tokens in `core/theme`), no `setState` as
the state approach (use Riverpod), no business logic in UI files.

## Getting started

```bash
flutter pub get
flutter run                 # default dev flavour
# or a specific flavour:
flutter run --flavor dev -t lib/main_dev.dart
```

## Branching and PRs

Branch off `staging`, open a PR into `staging`, request a review from
Abdull-Kudus or Binthia, with Uche (@EucTech) as backup (one approval
needed, never your own PR). `main` is
protected and only receives `staging` at release.

Branch names: `<type>/<ticket>-<short-description>` (feature, fix, chore, docs,
test, refactor). Example: `feature/STK-12-login-email-password`.

## Firebase setup (Uche / Tolu)

1. Create dev, staging, prod Firebase projects.
2. Run `flutterfire configure` for each flavour to generate `firebase_options`.
3. Place `google-services.json` / `GoogleService-Info.plist` locally - they are
   gitignored and must never be committed.

## Testing

```bash
flutter analyze
dart format .
flutter test --coverage
```

## Team

Frontend: Binthia (lead, repo, design system), Chris.
Backend: Uche (Firestore, rules), Tolu (auth, notifications),
Abdull-Kudus (credit scoring engine, report lead).
