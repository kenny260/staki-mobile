Staki Fund
A Flutter app that turns mobile money history into a Credit Passport score (300–1000) that regulated lenders can use.

Overview

Small businesses in Rwanda earn and transact through mobile money but have no collateral or credit history that formal lenders recognise. Staki Fund bridges that gap by analysing a borrower's MoMo transaction history and generating a Credit Passport score that BNR-regulated lenders can use to make lending decisions. Borrowers build a profile, connect their MoMo data with revocable consent, and receive a scored passport they can share with any lender on the platform. Lenders access a marketplace of pre-scored borrowers and manage their loan portfolio in one place. The app does not lend money itself.

Screenshots

Features
Onboarding flow with borrower and lender role selection
Email/password and Google sign-in with email verification
Borrower profile supporting five borrower types (salaried, self-employed, trader, farmer, student)
Data consent screen and MoMo connection with revocable access
Document upload for PDFs and images, stored via Cloudinary
Credit Passport score (300–1000) with factor breakdown
Loan eligibility check, application flow, and repayment tracking
Lender onboarding, borrower marketplace, and portfolio management
Push notifications via Firebase Cloud Messaging
Device settings for theme, language, and last-used role (SharedPreferences)

Tech stack
Layer	Tools
UI	Flutter 3 / Dart 3
State management	Riverpod
Navigation	go_router
Auth & database	Firebase Auth, Cloud Firestore, Cloud Messaging
File storage	Cloudinary
Scoring API	Vercel serverless functions
Local storage	SharedPreferences
Testing	mocktail, flutter_test

Architecture

The app follows Clean Architecture with a strict one-way dependency rule: presentation calls domain, domain defines interfaces, and data implements them. This keeps business logic independent of Flutter and Firebase, making each layer testable in isolation.

frontend/lib/
├── core/          # Router, theme, constants, shared providers
├── data/          # Repository implementations, remote and local data sources
├── domain/        # Entities, repository interfaces, use cases
└── presentation/  # Pages, widgets, Riverpod notifiers

Architecture diagram 
Getting started
Prerequisites
Flutter 3.x (stable channel)
Android Studio with an Android emulator, or a physical Android device
Node.js 22 — only needed for backend scripts
Firebase CLI — only needed for backend deployment
Steps
bash
git clone https://github.com/your-org/staki-mobile.git
cd staki-mobile/frontend
flutter pub get
flutter run -t lib/main_dev.dart
Demo accounts
Role	Email
Borrower	borrower@staki.demo
Lender	lender@staki.demo

Passwords are in backend/seed/data.js.

Backend

The backend has three parts. Firestore security rules and indexes live in backend/firestore.rules; deploy them with:

bash
firebase deploy --only firestore:rules,firestore:indexes

Demo seed data is in backend/seed/; run it with:

bash
node seed.js

The Credit Passport scoring API is in backend/api/ and is live at https://staki-api.vercel.app/api/credit-passport (POST with a Firebase ID token in the Authorization header). See backend/README.md for integration details and backend/scoring-research/MODEL_CARD.md for the scoring model documentation.

Testing
bash
# Static analysis
flutter analyze

# Formatting check
dart format --set-exit-if-changed lib test

# Widget and unit tests
flutter test

# Test coverage
flutter test --coverage

# Scoring engine (Node)
cd backend/api && npm test
