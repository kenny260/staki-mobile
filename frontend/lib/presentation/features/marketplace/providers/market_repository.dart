import 'package:staki_mobile/presentation/features/marketplace/providers/market_models.dart';

// TEMP: swap the implementation when the Firestore repository exists.
abstract class MarketplaceRepository {
  /// READ the open opportunities.
  Future<List<Opportunity>> fetchOpportunities();

  /// READ the lender's available balance.
  Future<int> fetchBalance();

  /// CREATE an allocation, UPDATE the funded amount and the balance.
  Future<AllocationReceipt> allocate(String opportunityId, int amount);

  Future<Portfolio> fetchPortfolio();

  Future<List<LedgerEntry>> fetchLedger();

  Future<List<NotificationItem>> fetchNotifications();

  /// UPDATE: mark every notification as read.
  Future<void> markNotificationsRead();
}

class MockMarketplaceRepository implements MarketplaceRepository {
  MockMarketplaceRepository({
    this.delay = const Duration(milliseconds: 400),
    this.failAllocate = false,
  });

  final Duration delay;

  /// Set to true to preview the allocation error.
  final bool failAllocate;

  int _balance = 5000000;
  int _counter = 0;

  final List<Opportunity> _opportunities = [
    const Opportunity(
      id: 'OPP-1042',
      sector: 'MSME Retail',
      title: 'Inventory Expansion',
      requested: 5000000,
      funded: 3500000,
      termMonths: 12,
      annualReturn: 18,
      score: 780,
      verification: 'KYC + 2 more',
      cashFlow: 'Strong',
      affordability: 'Moderate',
      repaymentHistory: 'Excellent',
    ),
    const Opportunity(
      id: 'OPP-0891',
      sector: 'Transport/Logistics',
      title: 'Equipment Purchase',
      requested: 12000000,
      funded: 12000000,
      termMonths: 24,
      annualReturn: 16.5,
      score: 810,
      verification: 'KYC + 3 more',
      cashFlow: 'Excellent',
      affordability: 'Strong',
      repaymentHistory: 'Excellent',
    ),
    const Opportunity(
      id: 'OPP-1095',
      sector: 'Tech Startup',
      title: 'Working Capital',
      requested: 3000000,
      funded: 900000,
      termMonths: 6,
      annualReturn: 20,
      score: 640,
      verification: 'KYC + 1 more',
      cashFlow: 'Moderate',
      affordability: 'Moderate',
      repaymentHistory: 'Good',
    ),
  ];

  final List<Allocation> _allocations = _seedAllocations();
  final List<LedgerEntry> _ledger = _seedLedger();
  final List<NotificationItem> _notifications =
      List<NotificationItem>.of(_seedNotifications());

  Future<void> _wait() => Future<void>.delayed(delay);

  @override
  Future<List<Opportunity>> fetchOpportunities() async {
    await _wait();
    return List.of(_opportunities);
  }

  @override
  Future<int> fetchBalance() async {
    await _wait();
    return _balance;
  }

  @override
  Future<AllocationReceipt> allocate(String opportunityId, int amount) async {
    await _wait();
    if (failAllocate) {
      throw const MarketException(
        "We couldn't allocate your funds. Please try again.",
      );
    }
    final index = _opportunities.indexWhere((o) => o.id == opportunityId);
    if (index == -1) {
      throw const MarketException('That opportunity is no longer available.');
    }
    final opportunity = _opportunities[index];
    final remaining = opportunity.remaining;
    if (amount < minAllocationFor(remaining) || amount > remaining) {
      throw const MarketException('That amount is not available to fund.');
    }
    if (amount > _balance) {
      throw const MarketException('Your balance is too low for this amount.');
    }

    final now = DateTime.now();
    _counter++;
    _balance -= amount;
    _opportunities[index] = opportunity.withFunded(opportunity.funded + amount);
    _allocations.insert(
      0,
      Allocation(
        id: 'new_$_counter',
        opportunityId: opportunity.id,
        sector: opportunity.sector,
        amount: amount,
        outstanding: amount,
        nextRepayment: DateTime(now.year, now.month + 1, now.day),
        status: AllocationStatus.performing,
        daysLate: 0,
        disbursedOn: now,
        schedule: 'Monthly (${opportunity.termMonths}m)',
        history: [
          LedgerEntry(
            title: 'Funds allocated',
            date: now,
            amount: -amount,
            kind: LedgerKind.allocation,
          ),
        ],
      ),
    );
    _ledger.insert(
      0,
      LedgerEntry(
        title: 'Allocation: ${opportunity.id}',
        date: now,
        amount: -amount,
        kind: LedgerKind.allocation,
      ),
    );
    _notifications.insert(
      0,
      NotificationItem(
        id: 'n_$_counter',
        title: 'Funding allocation confirmed',
        body: 'Your ${moneyRwf(amount)} allocation to ${opportunity.id} '
            'has been initiated.',
        timeLabel: 'Just now',
        kind: NotificationKind.info,
      ),
    );
    return AllocationReceipt(
      reference: 'ALLOC-${99281 + _counter}X',
      opportunityId: opportunity.id,
      amount: amount,
    );
  }

  @override
  Future<Portfolio> fetchPortfolio() async {
    await _wait();
    return Portfolio(
      allocations: List.of(_allocations),
      pendingRepayments: 850000,
    );
  }

  @override
  Future<List<LedgerEntry>> fetchLedger() async {
    await _wait();
    return List.of(_ledger);
  }

  @override
  Future<List<NotificationItem>> fetchNotifications() async {
    await _wait();
    return List.of(_notifications);
  }

  @override
  Future<void> markNotificationsRead() async {
    await _wait();
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].markedRead();
    }
  }
}

List<Allocation> _seedAllocations() => [
      Allocation(
        id: 'a1',
        opportunityId: 'OPP-1042',
        sector: 'MSME Retail',
        amount: 5000000,
        outstanding: 3500000,
        nextRepayment: DateTime(2026, 11, 15),
        status: AllocationStatus.performing,
        daysLate: 0,
        disbursedOn: DateTime(2026, 7, 15),
        schedule: 'Monthly (12m)',
        history: [
          LedgerEntry(
            title: 'Repayment received',
            date: DateTime(2026, 10, 15),
            amount: 500000,
            kind: LedgerKind.repayment,
            note: 'Principal + Interest',
          ),
          LedgerEntry(
            title: 'Repayment received',
            date: DateTime(2026, 9, 15),
            amount: 500000,
            kind: LedgerKind.repayment,
            note: 'Principal + Interest',
          ),
          LedgerEntry(
            title: 'Funds disbursed',
            date: DateTime(2026, 7, 15),
            amount: -5000000,
            kind: LedgerKind.disbursed,
          ),
        ],
      ),
      Allocation(
        id: 'a2',
        opportunityId: 'OPP-0891',
        sector: 'Transport/Logistics',
        amount: 2000000,
        outstanding: 1500000,
        nextRepayment: DateTime(2026, 10, 20),
        status: AllocationStatus.late,
        daysLate: 5,
        disbursedOn: DateTime(2026, 7, 20),
        schedule: 'Monthly (24m)',
        history: [
          LedgerEntry(
            title: 'Repayment received',
            date: DateTime(2026, 9, 20),
            amount: 500000,
            kind: LedgerKind.repayment,
            note: 'Principal + Interest',
          ),
          LedgerEntry(
            title: 'Funds disbursed',
            date: DateTime(2026, 7, 20),
            amount: -2000000,
            kind: LedgerKind.disbursed,
          ),
        ],
      ),
      Allocation(
        id: 'a3',
        opportunityId: 'OPP-0777',
        sector: 'Agriculture',
        amount: 7500000,
        outstanding: 7000000,
        nextRepayment: DateTime(2026, 11, 28),
        status: AllocationStatus.performing,
        daysLate: 0,
        disbursedOn: DateTime(2026, 9, 28),
        schedule: 'Monthly (18m)',
        history: [
          LedgerEntry(
            title: 'Repayment received',
            date: DateTime(2026, 10, 28),
            amount: 500000,
            kind: LedgerKind.repayment,
            note: 'Principal + Interest',
          ),
          LedgerEntry(
            title: 'Funds disbursed',
            date: DateTime(2026, 9, 28),
            amount: -7500000,
            kind: LedgerKind.disbursed,
          ),
        ],
      ),
    ];

List<LedgerEntry> _seedLedger() => [
      LedgerEntry(
        title: 'Repayment: OPP-1042',
        date: DateTime(2026, 10, 15),
        amount: 500000,
        kind: LedgerKind.repayment,
      ),
      LedgerEntry(
        title: 'Deposit cleared',
        date: DateTime(2026, 10, 10),
        amount: 2000000,
        kind: LedgerKind.deposit,
      ),
      LedgerEntry(
        title: 'Allocation: OPP-1095',
        date: DateTime(2026, 10, 5),
        amount: -500000,
        kind: LedgerKind.allocation,
      ),
    ];

List<NotificationItem> _seedNotifications() => const [
      NotificationItem(
        id: 'n1',
        title: 'Repayment received',
        body: 'A scheduled repayment of RWF 500,000 for OPP-1042 was '
            'processed successfully.',
        timeLabel: '2 hours ago',
        kind: NotificationKind.success,
      ),
      NotificationItem(
        id: 'n2',
        title: 'Funding allocation confirmed',
        body: 'Your RWF 500,000 allocation to OPP-1095 has been confirmed '
            'by Bank of Kigali.',
        timeLabel: 'Yesterday',
        kind: NotificationKind.info,
      ),
      NotificationItem(
        id: 'n3',
        title: 'Payment delayed',
        body: 'OPP-0891 has missed its scheduled repayment on Oct 20. '
            'Collection processes have been initiated.',
        timeLabel: '5 days ago',
        kind: NotificationKind.warning,
        read: true,
      ),
      NotificationItem(
        id: 'n4',
        title: 'Opportunity fully funded',
        body: 'OPP-0891 has reached its funding goal of RWF 12,000,000.',
        timeLabel: 'Oct 18, 2026',
        kind: NotificationKind.neutral,
        read: true,
      ),
      NotificationItem(
        id: 'n5',
        title: 'KYC update required',
        body: 'Please update your institutional mandate documents to '
            'maintain active lender status.',
        timeLabel: 'Oct 10, 2026',
        kind: NotificationKind.kyc,
        read: true,
      ),
    ];
