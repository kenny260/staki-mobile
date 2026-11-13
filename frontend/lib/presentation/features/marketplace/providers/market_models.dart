// TEMP: replace with domain entities once the backend team publishes them.

const minAllocation = 100000;
const allocationStep = 100000;
const defaultAllocation = 500000;
const _feeRate = 0.01;
const _defaultPoints = [
  'Identity (KYC)',
  'Business registration',
  'MoMo transaction history',
];

int clampInt(int value, int low, int high) {
  if (value < low) return low;
  if (value > high) return high;
  return value;
}

int minAllocationFor(int maxAmount) =>
    maxAmount < minAllocation ? maxAmount : minAllocation;

int allocationFee(int amount) => (amount * _feeRate).round();

/// 5000000 becomes "RWF 5,000,000".
String moneyRwf(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return 'RWF $buffer';
}

/// 500000 becomes "+RWF 500,000", -500000 becomes "-RWF 500,000".
String signedRwf(int value) => '${value < 0 ? '-' : '+'}${moneyRwf(value)}';

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

/// DateTime(2026, 11, 15) becomes "Nov 15, 2026".
String dateLabel(DateTime date) =>
    '${_months[date.month - 1]} ${date.day}, ${date.year}';

enum AmountFilter {
  under5m('< 5M RWF'),
  mid('5M - 20M RWF'),
  over20m('> 20M RWF');

  const AmountFilter(this.label);

  final String label;

  bool matches(int amount) => switch (this) {
        AmountFilter.under5m => amount < 5000000,
        AmountFilter.mid => amount >= 5000000 && amount <= 20000000,
        AmountFilter.over20m => amount > 20000000,
      };
}

enum TermFilter {
  short('Short (<6m)'),
  medium('Medium (6-12m)'),
  long('Long (>12m)');

  const TermFilter(this.label);

  final String label;

  bool matches(int months) => switch (this) {
        TermFilter.short => months < 6,
        TermFilter.medium => months >= 6 && months <= 12,
        TermFilter.long => months > 12,
      };
}

enum RiskFilter {
  lower('750+ (Lower Risk)'),
  moderate('600-750 (Moderate)');

  const RiskFilter(this.label);

  final String label;

  bool matches(int score) => switch (this) {
        RiskFilter.lower => score >= 750,
        RiskFilter.moderate => score >= 600 && score < 750,
      };
}

class OpportunityFilter {
  const OpportunityFilter({this.amount, this.term, this.risk});

  final AmountFilter? amount;
  final TermFilter? term;
  final RiskFilter? risk;

  bool get isActive => amount != null || term != null || risk != null;

  bool matches(Opportunity o) =>
      (amount?.matches(o.requested) ?? true) &&
      (term?.matches(o.termMonths) ?? true) &&
      (risk?.matches(o.score) ?? true);

  /// Choosing the same chip again clears it.
  OpportunityFilter toggleAmount(AmountFilter value) => OpportunityFilter(
        amount: amount == value ? null : value,
        term: term,
        risk: risk,
      );

  OpportunityFilter toggleTerm(TermFilter value) => OpportunityFilter(
        amount: amount,
        term: term == value ? null : value,
        risk: risk,
      );

  OpportunityFilter toggleRisk(RiskFilter value) => OpportunityFilter(
        amount: amount,
        term: term,
        risk: risk == value ? null : value,
      );
}

class Opportunity {
  const Opportunity({
    required this.id,
    required this.sector,
    required this.title,
    required this.requested,
    required this.funded,
    required this.termMonths,
    required this.annualReturn,
    required this.score,
    required this.verification,
    required this.cashFlow,
    required this.affordability,
    required this.repaymentHistory,
    this.repaymentStructure = 'Monthly Principal + Interest',
    this.verifiedPoints = _defaultPoints,
  });

  final String id;
  final String sector;
  final String title;
  final int requested;
  final int funded;
  final int termMonths;
  final double annualReturn;
  final int score;
  final String verification;
  final String cashFlow;
  final String affordability;
  final String repaymentHistory;
  final String repaymentStructure;
  final List<String> verifiedPoints;

  int get remaining => requested - funded;

  double get fundedFraction =>
      requested == 0 ? 0 : (funded / requested).clamp(0.0, 1.0);

  int get fundedPercent => (fundedFraction * 100).round();

  bool get isFullyFunded => remaining <= 0;

  String get rateLabel {
    final whole = annualReturn == annualReturn.roundToDouble();
    return whole ? '${annualReturn.round()}% p.a.' : '$annualReturn% p.a.';
  }

  Opportunity withFunded(int newFunded) {
    return Opportunity(
      id: id,
      sector: sector,
      title: title,
      requested: requested,
      funded: newFunded,
      termMonths: termMonths,
      annualReturn: annualReturn,
      score: score,
      verification: verification,
      cashFlow: cashFlow,
      affordability: affordability,
      repaymentHistory: repaymentHistory,
      repaymentStructure: repaymentStructure,
      verifiedPoints: verifiedPoints,
    );
  }
}

/// The most the lender can put in: what is left, or what they have.
int maxFundable(Opportunity opportunity, int balance) =>
    opportunity.remaining < balance ? opportunity.remaining : balance;

enum LedgerKind { repayment, deposit, allocation, disbursed }

class LedgerEntry {
  const LedgerEntry({
    required this.title,
    required this.date,
    required this.amount,
    required this.kind,
    this.note,
  });

  final String title;
  final DateTime date;

  /// Positive for money in, negative for money out.
  final int amount;
  final LedgerKind kind;
  final String? note;
}

enum AllocationStatus { performing, late }

class Allocation {
  const Allocation({
    required this.id,
    required this.opportunityId,
    required this.sector,
    required this.amount,
    required this.outstanding,
    required this.nextRepayment,
    required this.status,
    required this.daysLate,
    required this.disbursedOn,
    required this.schedule,
    required this.history,
  });

  final String id;
  final String opportunityId;
  final String sector;
  final int amount;
  final int outstanding;
  final DateTime nextRepayment;
  final AllocationStatus status;
  final int daysLate;
  final DateTime disbursedOn;
  final String schedule;
  final List<LedgerEntry> history;

  int get received => amount - outstanding;

  double get progress => amount == 0 ? 0 : (received / amount).clamp(0.0, 1.0);
}

class Portfolio {
  const Portfolio({
    required this.allocations,
    required this.pendingRepayments,
  });

  final List<Allocation> allocations;
  final int pendingRepayments;

  int get totalAllocated =>
      allocations.fold<int>(0, (sum, a) => sum + a.amount);

  int get activeFunding =>
      allocations.fold<int>(0, (sum, a) => sum + a.outstanding);

  int get repaidPrincipal => totalAllocated - activeFunding;
}

enum NotificationKind { success, info, warning, neutral, kyc }

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timeLabel,
    required this.kind,
    this.read = false,
  });

  final String id;
  final String title;
  final String body;
  final String timeLabel;
  final NotificationKind kind;
  final bool read;

  NotificationItem markedRead() => NotificationItem(
        id: id,
        title: title,
        body: body,
        timeLabel: timeLabel,
        kind: kind,
        read: true,
      );
}

class AllocationReceipt {
  const AllocationReceipt({
    required this.reference,
    required this.opportunityId,
    required this.amount,
  });

  final String reference;
  final String opportunityId;
  final int amount;
}

class MarketException implements Exception {
  const MarketException(this.message);

  final String message;
}
