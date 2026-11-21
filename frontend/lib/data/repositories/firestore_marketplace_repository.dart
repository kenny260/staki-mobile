import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:staki_mobile/presentation/features/marketplace/providers/market_models.dart';
import 'package:staki_mobile/presentation/features/marketplace/providers/market_repository.dart';

/// The lender's marketplace and portfolio on Firestore.
///
/// Reads `opportunities`, the lender's `fundings`, `lenders/{uid}` (wallet
/// balance) and its `ledger`, and `users/{uid}/notifications`. Funding a
/// loan saves a 'pending' request in `fundings`; the server moves the money,
/// so the balance and listing update after it confirms.
class FirestoreMarketplaceRepository implements MarketplaceRepository {
  FirestoreMarketplaceRepository({
    required FirebaseFirestore firestore,
    required String uid,
  })  : _db = firestore,
        _uid = uid;

  final FirebaseFirestore _db;
  final String _uid;

  static int _int(Object? v) => (v as num?)?.toInt() ?? 0;
  static DateTime _date(Object? v) =>
      (v as Timestamp?)?.toDate() ?? DateTime.now();

  static Opportunity opportunityFrom(String id, Map<String, dynamic> d) =>
      Opportunity(
        id: id,
        sector: d['sector'] as String? ?? '',
        title: d['title'] as String? ?? '',
        requested: _int(d['requested']),
        funded: _int(d['funded']),
        termMonths: _int(d['termMonths']),
        annualReturn: (d['annualReturn'] as num?)?.toDouble() ?? 0,
        score: _int(d['score']),
        verification: d['verification'] as String? ?? '',
        cashFlow: d['cashFlow'] as String? ?? '',
        affordability: d['affordability'] as String? ?? '',
        repaymentHistory: d['repaymentHistory'] as String? ?? '',
        repaymentStructure: d['repaymentStructure'] as String? ?? '',
        verifiedPoints: List<String>.from(
          d['verifiedPoints'] as List? ?? const [],
        ),
      );

  static LedgerEntry ledgerFrom(Map<String, dynamic> d) => LedgerEntry(
        title: d['title'] as String? ?? '',
        date: _date(d['date']),
        amount: _int(d['amount']),
        kind: LedgerKind.values.firstWhere(
          (k) => k.name == d['kind'],
          orElse: () => LedgerKind.deposit,
        ),
        note: d['note'] as String?,
      );

  static String timeLabel(DateTime at, DateTime now) {
    final diff = now.difference(at);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }

  @override
  Future<List<Opportunity>> fetchOpportunities() async {
    final snap = await _db
        .collection('opportunities')
        .where('status', isEqualTo: 'open')
        .get();
    return snap.docs.map((d) => opportunityFrom(d.id, d.data())).toList();
  }

  @override
  Future<int> fetchBalance() async {
    final doc = await _db.collection('lenders').doc(_uid).get();
    return _int(doc.data()?['walletBalance']);
  }

  @override
  Future<AllocationReceipt> allocate(String opportunityId, int amount) async {
    final doc = await _db.collection('opportunities').doc(opportunityId).get();
    if (!doc.exists) {
      throw const MarketException('That opportunity is no longer available.');
    }
    final opportunity = opportunityFrom(doc.id, doc.data()!);
    final remaining = opportunity.remaining;
    if (amount < minAllocationFor(remaining) || amount > remaining) {
      throw const MarketException('That amount is not available to fund.');
    }
    if (amount > await fetchBalance()) {
      throw const MarketException('Your balance is too low for this amount.');
    }
    final suffix = DateTime.now().millisecondsSinceEpoch % 100000;
    final reference = 'ALLOC-${suffix.toString().padLeft(5, '0')}';
    try {
      await _db.collection('fundings').add({
        'lenderId': _uid,
        'opportunityId': opportunityId,
        'loanId': doc.data()!['loanId'],
        'sector': opportunity.sector,
        'amount': amount,
        'outstanding': amount,
        'status': 'pending',
        'schedule': 'Monthly (${opportunity.termMonths}m)',
        'reference': reference,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException {
      throw const MarketException(
        "We couldn't allocate your funds. Please try again.",
      );
    }
    return AllocationReceipt(
      reference: reference,
      opportunityId: opportunityId,
      amount: amount,
    );
  }

  @override
  Future<Portfolio> fetchPortfolio() async {
    final snap = await _db
        .collection('fundings')
        .where('lenderId', isEqualTo: _uid)
        .get();
    final allocations = snap.docs.map((doc) {
      final d = doc.data();
      return Allocation(
        id: doc.id,
        opportunityId: d['opportunityId'] as String? ?? '',
        sector: d['sector'] as String? ?? '',
        amount: _int(d['amount']),
        outstanding: _int(d['outstanding']),
        nextRepayment: _date(d['nextRepayment']),
        status: d['status'] == 'late'
            ? AllocationStatus.late
            : AllocationStatus.performing,
        daysLate: _int(d['daysLate']),
        disbursedOn: _date(d['disbursedOn'] ?? d['createdAt']),
        schedule: d['schedule'] as String? ?? '',
        history: const [],
      );
    }).toList()
      ..sort((a, b) => b.disbursedOn.compareTo(a.disbursedOn));
    final overdue = allocations
        .where((a) => a.status == AllocationStatus.late)
        .fold<int>(0, (total, a) => total + a.outstanding);
    return Portfolio(allocations: allocations, pendingRepayments: overdue);
  }

  @override
  Future<List<LedgerEntry>> fetchLedger() async {
    final snap = await _db
        .collection('lenders')
        .doc(_uid)
        .collection('ledger')
        .orderBy('date', descending: true)
        .get();
    return snap.docs.map((d) => ledgerFrom(d.data())).toList();
  }

  CollectionReference<Map<String, dynamic>> get _notifications =>
      _db.collection('users').doc(_uid).collection('notifications');

  @override
  Future<List<NotificationItem>> fetchNotifications() async {
    final snap =
        await _notifications.orderBy('createdAt', descending: true).get();
    final now = DateTime.now();
    return snap.docs.map((doc) {
      final d = doc.data();
      return NotificationItem(
        id: doc.id,
        title: d['title'] as String? ?? '',
        body: d['body'] as String? ?? '',
        timeLabel: timeLabel(_date(d['createdAt']), now),
        kind: NotificationKind.values.firstWhere(
          (k) => k.name == d['kind'],
          orElse: () => NotificationKind.neutral,
        ),
        read: d['read'] == true,
      );
    }).toList();
  }

  /// UPDATE: the rules only let the owner change `read` to true.
  @override
  Future<void> markNotificationsRead() async {
    final unread = await _notifications.where('read', isEqualTo: false).get();
    if (unread.docs.isEmpty) return;
    final batch = _db.batch();
    for (final doc in unread.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }
}
