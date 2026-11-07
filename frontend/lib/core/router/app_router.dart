import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/presentation/features/consent/pages/consent_intro_page.dart';
import 'package:staki_mobile/presentation/features/consent/pages/momo_connect_page.dart';
import 'package:staki_mobile/presentation/features/consent/pages/momo_connected_page.dart';
import 'package:staki_mobile/presentation/features/consent/pages/momo_connecting_page.dart';
import 'package:staki_mobile/presentation/features/consent/pages/momo_consent_page.dart';
import 'package:staki_mobile/presentation/features/consent/pages/momo_eligible_page.dart';
import 'package:staki_mobile/presentation/features/consent/pages/momo_error_page.dart';
import 'package:staki_mobile/presentation/features/consent/pages/momo_not_eligible_page.dart';
import 'package:staki_mobile/presentation/features/credit_passport/pages/assessment_page.dart';
import 'package:staki_mobile/presentation/features/credit_passport/pages/breakdown_page.dart';
import 'package:staki_mobile/presentation/features/credit_passport/pages/score_page.dart';
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
        builder: (_, __) => const ConsentIntroPage(), // O01_Consent
        routes: [
          GoRoute(
            path: 'momo',
            builder: (_, __) => const MomoConsentPage(), // O02 / O02b
            routes: [
              GoRoute(
                path: 'connect',
                builder: (_, __) => const MomoConnectPage(), // M01
              ),
              GoRoute(
                path: 'connecting',
                builder: (_, __) => const MomoConnectingPage(), // M02
              ),
              GoRoute(
                path: 'connected',
                builder: (_, __) => const MomoConnectedPage(), // M03
              ),
              GoRoute(
                path: 'error',
                builder: (_, __) => const MomoErrorPage(), // M04
              ),
              GoRoute(
                path: 'not-eligible',
                builder: (_, __) => const MomoNotEligiblePage(), // M05
              ),
              GoRoute(
                path: 'eligible',
                builder: (_, __) => const MomoEligiblePage(), // M06
              ),
            ],
          ),
        ],
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
        builder: (_, __) => const ScorePage(), // C02_Score
        routes: [
          GoRoute(
            path: 'breakdown', // /credit-passport/breakdown
            builder: (_, __) => const BreakdownPage(), // C03_Breakdown
          ),
          GoRoute(
            path: 'assessment', // /credit-passport/assessment
            builder: (_, __) => const AssessmentPage(), // C01 states
          ),
        ],
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
    errorBuilder: (_, state) =>
        Scaffold(body: Center(child: Text('Route not found: ${state.uri}'))),
  );
}
