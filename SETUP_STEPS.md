# Staki Fund mobile: initialization steps

Run these on a machine with Flutter installed (`flutter --version` should work).
This folder holds the Dart code, architecture, theme, CI, and templates. You
generate the native Android/iOS shell locally, then drop these files on top.

## 1. Generate the Flutter shell into the repo

```bash
# clone the empty repo
git clone https://github.com/kenny260/staki-mobile.git
cd staki-mobile

# generate the Flutter project in place (org = your reverse-domain id)
flutter create . \
  --org rw.staki \
  --project-name staki_mobile \
  --platforms=android,ios
```

## 2. Overlay this scaffold

Copy everything from this `staki-mobile-init` folder into the cloned repo,
replacing the default `lib/`, `pubspec.yaml`, `analysis_options.yaml`,
`README.md`, and adding the `.github/` folder, `.gitignore`, and the extra
`lib` files (app.dart, bootstrap.dart, the flavour mains).

```bash
cp -r staki-mobile-init/. staki-mobile/
cd staki-mobile
flutter pub get
```

Delete the default `test/widget_test.dart` that `flutter create` made (we ship
our own tests).

## 3. Confirm it runs and passes checks

```bash
flutter analyze        # should be clean
dart format .          # formats everything
flutter test           # the two starter tests should pass
flutter run            # launches on a device/emulator (dev flavour)
```

## 4. Set up the branches

```bash
git add .
git commit -m "chore: initialise Flutter app with Clean Architecture scaffold"
git branch -M main
git push -u origin main

# create the shared integration branch
git checkout -b staging
git push -u origin staging
```

## 5. Protect the branches on GitHub (Binthia)

In the repo settings > Branches, add protection rules for `main` and `staging`:

- Require a pull request before merging, with at least 1 approval.
- Require the CI status check to pass.
- Do not allow direct pushes.

## 6. Everyone creates their branch off staging

```bash
git checkout staging && git pull
git checkout -b feature/STK-1-my-first-task
```

## 7. Firebase (Uche / Tolu, next)

```bash
# once, globally
dart pub global activate flutterfire_cli

# per flavour, generates lib/firebase_options_*.dart (gitignored)
flutterfire configure
```

Add `firebase_core` init inside `bootstrap.dart` where the TODO is.

## What is already wired for you

- Clean Architecture folders (core / data / domain / presentation).
- Colour + text tokens in `core/theme` (Binthia fills the real hex from Figma).
- go_router with one route per Figma section, each on a placeholder page.
- Riverpod ProviderScope at the root; three flavours (dev/staging/prod).
- CI (format + analyze + test), PR template, CODEOWNERS, .gitignore with
  Firebase secrets excluded.
- Two starter tests (one unit, one widget) so the test bar starts green.
