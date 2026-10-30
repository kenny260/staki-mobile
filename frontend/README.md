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

## Getting started

Run these from the `frontend/` folder.

```bash
cd frontend
flutter pub get
flutter run -t lib/main_dev.dart
```

Android build flavours are not configured yet, so do not pass `--flavor`.

## Firebase setup (Uche / Tolu)

1. Create dev, staging, prod Firebase projects.
2. Run `flutterfire configure` for each flavour to generate `firebase_options`.
3. Place `google-services.json` / `GoogleService-Info.plist` locally - they are
   gitignored and must never be committed.

## Testing

```bash
cd frontend
flutter analyze
dart format .
flutter test --coverage
```
