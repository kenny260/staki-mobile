# Staki Fund - Frontend (Flutter app)

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

## How to run

Needs Flutter 3 and an Android emulator or a phone (Android Studio).
Run everything from the `frontend/` folder.

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

Android build flavours are not configured yet, so do not pass `--flavor`.

In Android Studio, open the `frontend` folder as the project (not the repo root).

## Firebase setup (Uche / Tolu)

1. Create dev, staging, prod Firebase projects.
2. Run `flutterfire configure` for each flavour to generate `firebase_options`.
3. Place `google-services.json` / `GoogleService-Info.plist` locally - they are
   gitignored and must never be committed.

## Checks before every PR

```bash
cd frontend
flutter analyze
dart format .
flutter test --coverage
```
