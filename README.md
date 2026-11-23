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
