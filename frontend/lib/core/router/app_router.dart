import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/router/app_routes.dart';
import 'package:staki_mobile/presentation/features/credit_passport/pages/assessment_page.dart';
import 'package:staki_mobile/presentation/features/credit_passport/pages/breakdown_page.dart';
import 'package:staki_mobile/presentation/features/credit_passport/pages/score_page.dart';
import 'package:staki_mobile/presentation/features/edge_cases/pages/edge_case_gallery_page.dart';
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
      route(
        AppRoutes.documents,
        () => const PlaceholderPage(
          screenCode: 'D01_Documents',
          title: 'Document Upload',
          owner: 'Chris',
        ),
      ),
      route(
        AppRoutes.lenderOnboarding,
        () => const PlaceholderPage(
          screenCode: 'LO01_Welcome',
          title: 'Lender Onboarding',
          owner: 'Chris',
        ),
      ),
      route(
        '/loans',
        () => const PlaceholderPage(
          screenCode: 'L01_Eligibility',
          title: 'Funding Eligibility & Loan Application',
          owner: 'Chris',
        ),
      ),
      route(
        '/loan-active',
        () => const PlaceholderPage(
          screenCode: 'L07_LoanActive',
          title: 'Loan Lifecycle & Repayment',
          owner: 'Chris',
        ),
      ),
      route(
        '/marketplace',
        () => const PlaceholderPage(
          screenCode: 'LE01_Opportunities',
          title: 'Lender Marketplace & Portfolio',
          owner: 'Chris',
        ),
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
