import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/router/app_routes.dart';
import 'package:staki_mobile/presentation/features/credit_passport/pages/assessment_page.dart';
import 'package:staki_mobile/presentation/features/credit_passport/pages/breakdown_page.dart';
import 'package:staki_mobile/presentation/features/credit_passport/pages/score_page.dart';
import 'package:staki_mobile/presentation/features/documents/pages/document_preview_page.dart';
import 'package:staki_mobile/presentation/features/documents/pages/documents_page.dart';
import 'package:staki_mobile/presentation/features/edge_cases/pages/edge_case_gallery_page.dart';
import 'package:staki_mobile/presentation/features/lender/pages/lender_kyc_page.dart';
import 'package:staki_mobile/presentation/features/lender/pages/lender_otp_page.dart';
import 'package:staki_mobile/presentation/features/lender/pages/lender_phone_page.dart';
import 'package:staki_mobile/presentation/features/lender/pages/lender_pin_page.dart';
import 'package:staki_mobile/presentation/features/lender/pages/lender_profile_type_page.dart';
import 'package:staki_mobile/presentation/features/lender/pages/lender_risk_page.dart';
import 'package:staki_mobile/presentation/features/lender/pages/lender_structure_page.dart';
import 'package:staki_mobile/presentation/features/lender/pages/lender_success_page.dart';
import 'package:staki_mobile/presentation/features/lender/pages/lender_welcome_page.dart';
import 'package:staki_mobile/presentation/features/loan_lifecycle/pages/loan_details_page.dart';
import 'package:staki_mobile/presentation/features/loan_lifecycle/pages/repay_amount_page.dart';
import 'package:staki_mobile/presentation/features/loan_lifecycle/pages/repay_confirm_page.dart';
import 'package:staki_mobile/presentation/features/loan_lifecycle/pages/repay_success_page.dart';
import 'package:staki_mobile/presentation/features/loans/pages/funding_options_page.dart';
import 'package:staki_mobile/presentation/features/loans/pages/loan_amount_page.dart';
import 'package:staki_mobile/presentation/features/loans/pages/loan_purpose_page.dart';
import 'package:staki_mobile/presentation/features/loans/pages/loan_review_page.dart';
import 'package:staki_mobile/presentation/features/loans/pages/loan_submitted_page.dart';
import 'package:staki_mobile/presentation/features/loans/pages/loan_term_page.dart';
import 'package:staki_mobile/presentation/features/marketplace/pages/allocation_detail_page.dart';
import 'package:staki_mobile/presentation/features/marketplace/pages/fund_amount_page.dart';
import 'package:staki_mobile/presentation/features/marketplace/pages/fund_confirm_page.dart';
import 'package:staki_mobile/presentation/features/marketplace/pages/fund_review_page.dart';
import 'package:staki_mobile/presentation/features/marketplace/pages/fund_success_page.dart';
import 'package:staki_mobile/presentation/features/marketplace/pages/ledger_page.dart';
import 'package:staki_mobile/presentation/features/marketplace/pages/notifications_page.dart';
import 'package:staki_mobile/presentation/features/marketplace/pages/opportunities_page.dart';
import 'package:staki_mobile/presentation/features/marketplace/pages/opportunity_detail_page.dart';
import 'package:staki_mobile/presentation/features/marketplace/pages/portfolio_page.dart';
import 'package:staki_mobile/presentation/features/onboarding/pages/a01_splash_page.dart';
import 'package:staki_mobile/presentation/features/onboarding/pages/a02_welcome_page.dart';
import 'package:staki_mobile/presentation/features/onboarding/pages/a03_role_select_page.dart';
import 'package:staki_mobile/presentation/features/onboarding/pages/a04_borrower_confirmed_page.dart';
import 'package:staki_mobile/presentation/features/onboarding/pages/a04c_lender_confirmed_page.dart';
import 'package:staki_mobile/presentation/features/onboarding/pages/a05_phone_page.dart';
import 'package:staki_mobile/presentation/features/onboarding/pages/a06_otp_page.dart';
import 'package:staki_mobile/presentation/features/onboarding/pages/a07_create_pin_page.dart';
import 'package:staki_mobile/presentation/features/onboarding/pages/a07b_confirm_pin_page.dart';
import 'package:staki_mobile/presentation/features/onboarding/pages/a08_biometric_page.dart';
import 'package:staki_mobile/presentation/features/onboarding/pages/a09_account_created_page.dart';
import 'package:staki_mobile/presentation/features/profile/pages/p01_profile_role_page.dart';
import 'package:staki_mobile/presentation/features/profile/pages/p02_biz_info_page.dart';
import 'package:staki_mobile/presentation/features/profile/pages/p03_biz_financials_page.dart';
import 'package:staki_mobile/presentation/features/profile/pages/p04_biz_location_page.dart';
import 'package:staki_mobile/presentation/features/profile/pages/p05_review_page.dart';
import 'package:staki_mobile/presentation/features/profile/pages/p10_startup_info_page.dart';
import 'package:staki_mobile/presentation/features/profile/pages/p11_startup_activity_page.dart';
import 'package:staki_mobile/presentation/features/profile/pages/p20_student_institution_page.dart';
import 'package:staki_mobile/presentation/features/profile/pages/p21_student_income_page.dart';
import 'package:staki_mobile/presentation/features/profile/pages/p30_salary_employment_page.dart';
import 'package:staki_mobile/presentation/features/profile/pages/p31_salary_income_page.dart';
import 'package:staki_mobile/presentation/features/profile/pages/p40_other_info_page.dart';
import 'package:staki_mobile/presentation/features/settings/pages/s01_settings_page.dart';
import 'package:staki_mobile/presentation/features/settings/pages/s02_data_permissions_page.dart';
import 'package:staki_mobile/presentation/features/settings/pages/s03_privacy_page.dart';
import 'package:staki_mobile/presentation/features/settings/pages/s04_support_page.dart';
import 'package:staki_mobile/presentation/shared_widgets/placeholder_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  GoRoute route(String path, Widget Function() page) => GoRoute(
        path: path,
        builder: (context, state) => page(),
      );

  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      // Section 01
      route(AppRoutes.splash, () => const A01SplashPage()),
      route(AppRoutes.welcome, () => const A02WelcomePage()),
      route(AppRoutes.roleSelect, () => const A03RoleSelectPage()),
      route(
        AppRoutes.borrowerConfirmed,
        () => const A04BorrowerConfirmedPage(),
      ),
      route(AppRoutes.lenderConfirmed, () => const A04cLenderConfirmedPage()),
      route(AppRoutes.phone, () => const A05PhonePage()),
      route(AppRoutes.otp, () => const A06OtpPage()),
      route(AppRoutes.createPin, () => const A07CreatePinPage()),
      route(AppRoutes.confirmPin, () => const A07bConfirmPinPage()),
      route(AppRoutes.biometric, () => const A08BiometricPage()),
      route(AppRoutes.accountCreated, () => const A09AccountCreatedPage()),
      // Section 02
      route(AppRoutes.profileRole, () => const P01ProfileRolePage()),
      route(AppRoutes.bizInfo, () => const P02BizInfoPage()),
      route(AppRoutes.bizFinancials, () => const P03BizFinancialsPage()),
      route(AppRoutes.bizLocation, () => const P04BizLocationPage()),
      route(AppRoutes.review, () => const P05ReviewPage()),
      route(AppRoutes.startupInfo, () => const P10StartupInfoPage()),
      route(AppRoutes.startupActivity, () => const P11StartupActivityPage()),
      route(
        AppRoutes.studentInstitution,
        () => const P20StudentInstitutionPage(),
      ),
      route(AppRoutes.studentIncome, () => const P21StudentIncomePage()),
      // Section 05: Credit Passport (Chris)
      GoRoute(
        path: AppRoutes.creditPassport,
        builder: (context, state) => const ScorePage(), // C02_Score
        routes: [
          GoRoute(
            path: 'breakdown', // C03_Breakdown
            builder: (context, state) => const BreakdownPage(),
          ),
          GoRoute(
            path: 'assessment', // C01 states
            builder: (context, state) => const AssessmentPage(),
          ),
        ],
      ),
      route(AppRoutes.salaried, () => const P30SalaryEmploymentPage()),
      route(AppRoutes.salariedIncome, () => const P31SalaryIncomePage()),
      route(AppRoutes.otherInfo, () => const P40OtherInfoPage()),
      // Placeholders until the owner builds the real screen
      route(
        AppRoutes.login,
        () => const PlaceholderPage(
          screenCode: 'Login',
          title: 'Login (email, password, Google)',
          owner: 'Tolu',
        ),
      ),
      route(
        AppRoutes.consent,
        () => const PlaceholderPage(
          screenCode: 'O01_Consent',
          title: 'Data Consent & MoMo',
          owner: 'Chris',
        ),
      ),
      GoRoute(
        path: AppRoutes.documents,
        builder: (context, state) => const DocumentsPage(), // D01 / D05
        routes: [
          GoRoute(
            path: 'preview', // D04
            builder: (context, state) => const DocumentPreviewPage(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.lenderOnboarding,
        builder: (context, state) => const LenderWelcomePage(), // LO01
        routes: [
          GoRoute(
            path: 'phone', // LO02
            builder: (context, state) => const LenderPhonePage(),
          ),
          GoRoute(
            path: 'otp', // LO03
            builder: (context, state) => const LenderOtpPage(),
          ),
          GoRoute(
            path: 'pin', // LO04
            builder: (context, state) => const LenderPinPage(),
          ),
          GoRoute(
            path: 'profile', // LO05
            builder: (context, state) => const LenderProfileTypePage(),
          ),
          GoRoute(
            path: 'kyc', // LO06
            builder: (context, state) => const LenderKycPage(),
          ),
          GoRoute(
            path: 'risk', // LO07
            builder: (context, state) => const LenderRiskPage(),
          ),
          GoRoute(
            path: 'structure', // LO08
            builder: (context, state) => const LenderStructurePage(),
          ),
          GoRoute(
            path: 'success', // LO09
            builder: (context, state) => const LenderSuccessPage(),
          ),
        ],
      ),
      GoRoute(
        path: '/loans',
        builder: (context, state) => const FundingOptionsPage(), // L01
        routes: [
          GoRoute(
            path: 'amount', // L02
            builder: (context, state) => LoanAmountPage(
              editing: state.uri.queryParameters['edit'] == '1',
            ),
          ),
          GoRoute(
            path: 'term', // L03
            builder: (context, state) => LoanTermPage(
              editing: state.uri.queryParameters['edit'] == '1',
            ),
          ),
          GoRoute(
            path: 'purpose', // L04
            builder: (context, state) => const LoanPurposePage(),
          ),
          GoRoute(
            path: 'review', // L05
            builder: (context, state) => const LoanReviewPage(),
          ),
          GoRoute(
            path: 'submitted', // L06
            builder: (context, state) => const LoanSubmittedPage(),
          ),
        ],
      ),
      GoRoute(
        path: '/loan-active',
        builder: (context, state) => const LoanDetailsPage(), // L07 all stages
        routes: [
          GoRoute(
            path: 'repay', // L08
            builder: (context, state) => const RepayAmountPage(),
          ),
          GoRoute(
            path: 'confirm', // L09
            builder: (context, state) => const RepayConfirmPage(),
          ),
          GoRoute(
            path: 'success', // L10
            builder: (context, state) => const RepaySuccessPage(),
          ),
        ],
      ),
      GoRoute(
        path: '/marketplace',
        builder: (context, state) => const OpportunitiesPage(), // LE01
        routes: [
          GoRoute(
            path: 'opportunity/:id', // LE02
            builder: (context, state) => OpportunityDetailPage(
              opportunityId: state.pathParameters['id'] ?? '',
            ),
          ),
          GoRoute(
            path: 'fund', // LE03
            builder: (context, state) => const FundAmountPage(),
          ),
          GoRoute(
            path: 'review', // LE04
            builder: (context, state) => const FundReviewPage(),
          ),
          GoRoute(
            path: 'confirm', // LE05
            builder: (context, state) => const FundConfirmPage(),
          ),
          GoRoute(
            path: 'success', // LE06
            builder: (context, state) => const FundSuccessPage(),
          ),
          GoRoute(
            path: 'portfolio', // LE07
            builder: (context, state) => const PortfolioPage(),
          ),
          GoRoute(
            path: 'notifications', // LE08
            builder: (context, state) => const NotificationsPage(),
          ),
          GoRoute(
            path: 'ledger', // LE09
            builder: (context, state) => const LedgerPage(),
          ),
          GoRoute(
            path: 'allocation/:id', // LE10
            builder: (context, state) => AllocationDetailPage(
              allocationId: state.pathParameters['id'] ?? '',
            ),
          ),
        ],
      ),
      // Section 10 (Binthia)
      route(AppRoutes.settings, () => const S01SettingsPage()),
      route(AppRoutes.dataPermissions, () => const S02DataPermissionsPage()),
      route(AppRoutes.privacy, () => const S03PrivacyPage()),
      route(AppRoutes.support, () => const S04SupportPage()),
      route(AppRoutes.edgeCases, () => const EdgeCaseGalleryPage()),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Route not found: ${state.uri}'))),
  );
});
