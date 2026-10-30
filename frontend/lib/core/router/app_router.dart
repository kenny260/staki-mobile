import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:staki_mobile/presentation/shared_widgets/placeholder_page.dart';

/// Central navigation. One route per Figma section for now, each pointing at a
/// PlaceholderPage. As a screen is built, swap its builder for the real page.
///
/// Route naming mirrors the Figma code names so the Trello card, the branch,
/// the file and the route all match.
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      // 01 Welcome & Account Creation (owner: Binthia)
      GoRoute(
        path: '/splash',
        builder: (_, __) => const PlaceholderPage(
          screenCode: 'A01_Splash',
          title: 'Welcome & Account Creation',
          owner: 'Binthia',
        ),
      ),
      // 02 Borrower Profile Setup (owner: Binthia)
      GoRoute(
        path: '/profile',
        builder: (_, __) => const PlaceholderPage(
          screenCode: 'P01_ProfileRole',
          title: 'Borrower Profile Setup',
          owner: 'Binthia',
        ),
      ),
      // 03 Data Consent & MoMo (owner: Chris)
      GoRoute(
        path: '/consent',
        builder: (_, __) => const PlaceholderPage(
          screenCode: 'O01_Consent',
          title: 'Data Consent & MoMo',
          owner: 'Chris',
        ),
      ),
      // 04 Document Upload (owner: Chris)
      GoRoute(
        path: '/documents',
        builder: (_, __) => const PlaceholderPage(
          screenCode: 'D01_Documents',
          title: 'Document Upload',
          owner: 'Chris',
        ),
      ),
      // 05 Credit Passport (owner: Chris)
      GoRoute(
        path: '/credit-passport',
        builder: (_, __) => const PlaceholderPage(
          screenCode: 'C02_Score',
          title: 'Credit Passport',
          owner: 'Chris',
        ),
      ),
      // 06 Loan Application (owner: Chris)
      GoRoute(
        path: '/loans',
        builder: (_, __) => const PlaceholderPage(
          screenCode: 'L01_Eligibility',
          title: 'Funding Eligibility & Loan Application',
          owner: 'Chris',
        ),
      ),
      // 07 Loan Lifecycle & Repayment (owner: Chris)
      GoRoute(
        path: '/loan-active',
        builder: (_, __) => const PlaceholderPage(
          screenCode: 'L07_LoanActive',
          title: 'Loan Lifecycle & Repayment',
          owner: 'Chris',
        ),
      ),
      // 08 Lender Onboarding (owner: Chris)
      GoRoute(
        path: '/lender-onboarding',
        builder: (_, __) => const PlaceholderPage(
          screenCode: 'LO01_Welcome',
          title: 'Lender Onboarding',
          owner: 'Chris',
        ),
      ),
      // 09 Lender Marketplace & Portfolio (owner: Chris)
      GoRoute(
        path: '/marketplace',
        builder: (_, __) => const PlaceholderPage(
          screenCode: 'LE01_Opportunities',
          title: 'Lender Marketplace & Portfolio',
          owner: 'Chris',
        ),
      ),
      // 10 Profile & Settings (owner: Binthia)
      GoRoute(
        path: '/settings',
        builder: (_, __) => const PlaceholderPage(
          screenCode: 'S01_Settings',
          title: 'Profile & Settings',
          owner: 'Binthia',
        ),
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(child: Text('Route not found: ${state.uri}')),
    ),
  );
}
