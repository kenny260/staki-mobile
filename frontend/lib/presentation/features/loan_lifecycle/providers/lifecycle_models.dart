// TEMP: replace with domain entities once the backend team publishes them.

enum LoanStage {
  submitted,
  underReview,
  approved,
  disbursementPending,
  disbursed,
  active,
  repaymentDue,
  fullyRepaid,
  declined,
}

enum PayMethod { momo, bank }

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

/// 92500 becomes "RWF 92,500".
String formatMoney(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return 'RWF $buffer';
}

/// DateTime(2026, 11, 15) becomes "Nov 15".
String shortDate(DateTime date) => '${_months[date.month - 1]} ${date.day}';

/// DateTime(2026, 11, 15) becomes "Nov 15, 2026".
String fullDate(DateTime date) => '${shortDate(date)}, ${date.year}';

String methodLabel(PayMethod method) => switch (method) {
      PayMethod.momo => 'MTN MoMo (••67)',
      PayMethod.bank => 'Bank Transfer',
    };

class Payment {
  const Payment({required this.amount, required this.date});

  final int amount;
  final DateTime date;
}

class LoanAccount {
  const LoanAccount({
    required this.partner,
    required this.stage,
    required this.approvedAmount,
    required this.termMonths,
    required this.interestLabel,
    required this.monthlyPayment,
    required this.totalRepayable,
    required this.paidAmount,
    required this.payments,
    this.nextDueDate,
  });

  final String partner;
  final LoanStage stage;
  final int approvedAmount;
  final int termMonths;
  final String interestLabel;
  final int monthlyPayment;
  final int totalRepayable;
  final int paidAmount;

  /// Newest first.
  final List<Payment> payments;
  final DateTime? nextDueDate;

  int get outstanding => totalRepayable - paidAmount;

  /// 0.0 to 1.0, used by the progress bar.
  double get progress =>
      totalRepayable == 0 ? 0 : (paidAmount / totalRepayable).clamp(0.0, 1.0);

  /// The next instalment, never more than what is still owed.
  int get nextPaymentAmount =>
      monthlyPayment < outstanding ? monthlyPayment : outstanding;

  bool get isRepaid => outstanding <= 0;

  LoanAccount copyWith({
    LoanStage? stage,
    int? paidAmount,
    List<Payment>? payments,
    DateTime? nextDueDate,
    bool clearDueDate = false,
  }) {
    return LoanAccount(
      partner: partner,
      stage: stage ?? this.stage,
      approvedAmount: approvedAmount,
      termMonths: termMonths,
      interestLabel: interestLabel,
      monthlyPayment: monthlyPayment,
      totalRepayable: totalRepayable,
      paidAmount: paidAmount ?? this.paidAmount,
      payments: payments ?? this.payments,
      nextDueDate: clearDueDate ? null : (nextDueDate ?? this.nextDueDate),
    );
  }
}

class RepaymentReceipt {
  const RepaymentReceipt({
    required this.reference,
    required this.amount,
    required this.partner,
    required this.date,
  });

  final String reference;
  final int amount;
  final String partner;
  final DateTime date;
}

class LifecycleException implements Exception {
  const LifecycleException(this.message);

  final String message;
}
