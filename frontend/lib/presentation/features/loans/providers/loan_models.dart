// TEMP: replace with domain entities once the backend team publishes them.

const minLoanAmount = 50000;
const amountStep = 10000;
const termOptions = [3, 6, 9, 12];

enum EligibilityStatus { eligible, partiallyEligible, notEligible, underReview }

enum LoanPurpose {
  workingCapital('Working capital'),
  inventory('Inventory'),
  equipment('Equipment'),
  education('Education'),
  emergency('Emergency'),
  other('Other');

  const LoanPurpose(this.label);

  final String label;
}

/// 1200000 becomes "RWF 1,200,000".
String formatRwf(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return 'RWF $buffer';
}

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// DateTime(2023, 10, 24) becomes "Oct 24, 2023".
String formatDate(DateTime date) =>
    '${_months[date.month - 1]} ${date.day}, ${date.year}';

/// The loan cost rule lives only here. Figma values are sample data, so
/// change the two rates below when the lending partner gives real ones.
class LoanEstimate {
  const LoanEstimate({required this.principal, required this.termMonths});

  static const monthlyInterestRate = 0.015;
  static const originationFeeRate = 0.02;

  final int principal;
  final int termMonths;

  int get interest => (principal * monthlyInterestRate * termMonths).round();
  int get fee => (principal * originationFeeRate).round();
  int get total => principal + interest + fee;
  int get monthly => (total / termMonths).round();
}

class LoanOffer {
  const LoanOffer({
    required this.partner,
    required this.maxAmount,
    required this.termMonths,
    required this.monthlyRepayment,
    required this.interestLabel,
    required this.pendingVerification,
  });

  final String partner;
  final int maxAmount;
  final int termMonths;
  final int monthlyRepayment;
  final String interestLabel;
  final bool pendingVerification;
}

class EligibilityResult {
  const EligibilityResult({required this.status, this.offer});

  final EligibilityStatus status;
  final LoanOffer? offer;
}

/// The application the user is still filling in.
class LoanDraft {
  const LoanDraft({this.amount = 500000, this.termMonths = 6, this.purpose});

  final int amount;
  final int termMonths;
  final LoanPurpose? purpose;

  LoanDraft copyWith({int? amount, int? termMonths, LoanPurpose? purpose}) {
    return LoanDraft(
      amount: amount ?? this.amount,
      termMonths: termMonths ?? this.termMonths,
      purpose: purpose ?? this.purpose,
    );
  }
}

/// A submitted application (pending review).
class LoanApplication {
  const LoanApplication({
    required this.partner,
    required this.amount,
    required this.termMonths,
    required this.purpose,
    required this.submittedOn,
  });

  final String partner;
  final int amount;
  final int termMonths;
  final LoanPurpose purpose;
  final DateTime submittedOn;
}

class LoanException implements Exception {
  const LoanException(this.message);

  final String message;
}
