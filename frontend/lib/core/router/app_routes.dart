/// Route paths. One constant per Figma code name.
abstract final class AppRoutes {
  // Section 01: Welcome and account creation
  static const splash = '/splash'; // A01_Splash
  static const welcome = '/welcome'; // A02_Welcome
  static const roleSelect = '/role'; // A03_RoleSelect
  static const borrowerConfirmed = '/role/borrower'; // A04_BorrowerConfirmed
  static const lenderConfirmed = '/role/lender'; // A04c_LenderConfirmed
  static const phone = '/account/phone'; // A05_Phone
  static const otp = '/account/otp'; // A06_Otp
  static const createPin = '/account/pin'; // A07_CreatePIN
  static const confirmPin = '/account/pin/confirm'; // A07b_ConfirmPIN
  static const biometric = '/account/biometric'; // A08_Biometric
  static const accountCreated = '/account/created'; // A09_AccountCreated

  // Section 02: Borrower profile setup
  static const profileRole = '/profile/role'; // P01_ProfileRole
  static const bizInfo = '/profile/business/info'; // P02
  static const bizFinancials = '/profile/business/financials'; // P03
  static const bizLocation = '/profile/business/location'; // P04
  static const review = '/profile/review'; // P05
  static const startupInfo = '/profile/startup/info'; // P10
  static const startupActivity = '/profile/startup/activity'; // P11
  static const studentInstitution = '/profile/student/institution'; // P20
  static const studentIncome = '/profile/student/income'; // P21
  static const salaried = '/profile/salaried/employment'; // P30
  static const salariedIncome = '/profile/salaried/income'; // P31
  static const otherInfo = '/profile/other'; // P40

  // Section 10: Profile and settings
  static const settings = '/settings'; // S01_Settings
  static const dataPermissions = '/settings/data'; // S02_DataPermissions
  static const privacy = '/settings/privacy'; // S03_Privacy
  static const support = '/settings/support'; // S04_Support

  /// Developer gallery of all 34 edge-case states (E01-E34).
  static const edgeCases = '/dev/edge-cases';

  // Owned by teammates (placeholders until their sections land)
  static const login = '/login'; // Tolu
  static const consent = '/consent'; // Chris, Section 03
  static const lenderOnboarding = '/lender/onboarding'; // Chris, Section 08
  static const documents = '/documents'; // Chris, Section 04

  // Section 05: Credit Passport (Chris)
  static const creditPassport = '/credit-passport'; // C02_Score
  static const creditBreakdown = '/credit-passport/breakdown'; // C03_Breakdown
  static const creditAssessment = '/credit-passport/assessment'; // C01 states
}
