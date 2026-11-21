import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staki_mobile/data/repositories/firestore_lender_repository.dart';
import 'package:staki_mobile/data/repositories/firestore_marketplace_repository.dart';
import 'package:staki_mobile/presentation/features/lender/providers/lender_models.dart';
import 'package:staki_mobile/presentation/features/marketplace/providers/market_models.dart';

void main() {
  test('lender registration matches what the rules accept', () {
    final data = FirestoreLenderRepository.registration(
      const LenderDraft(
        phone: '788123456',
        profileType: InvestorType.diaspora,
        idFileName: 'id.jpg',
        selfieFileName: 'me.jpg',
        riskAcknowledged: true,
        structureAccepted: true,
      ),
    );
    expect(data['kycStatus'], 'pending');
    expect(data['investorType'], 'diaspora');
    expect(data['riskAcknowledged'], isTrue);
    expect(data['structureAccepted'], isTrue);
    expect(data.containsKey('walletBalance'), isFalse);
  });

  test('an opportunity document becomes a listing', () {
    final o = FirestoreMarketplaceRepository.opportunityFrom('OPP-1042', {
      'sector': 'MSME Retail',
      'title': 'Grocery stock',
      'requested': 2000000,
      'funded': 500000,
      'termMonths': 12,
      'annualReturn': 14,
      'score': 758,
      'verifiedPoints': ['ID verified'],
    });
    expect(o.id, 'OPP-1042');
    expect(o.remaining, 1500000);
    expect(o.annualReturn, 14.0);
    expect(o.verifiedPoints, ['ID verified']);
  });

  test('a ledger entry keeps its sign and kind', () {
    final e = FirestoreMarketplaceRepository.ledgerFrom({
      'title': 'Allocation: OPP-1042',
      'amount': -500000,
      'kind': 'allocation',
      'date': Timestamp.fromDate(DateTime(2026, 11, 2)),
    });
    expect(e.amount, -500000);
    expect(e.kind, LedgerKind.allocation);
    expect(e.date, DateTime(2026, 11, 2));
  });

  test('notification times read like the Figma labels', () {
    final now = DateTime(2026, 11, 21, 12);
    String label(Duration ago) =>
        FirestoreMarketplaceRepository.timeLabel(now.subtract(ago), now);
    expect(label(const Duration(seconds: 20)), 'Just now');
    expect(label(const Duration(minutes: 5)), '5m ago');
    expect(label(const Duration(hours: 3)), '3h ago');
    expect(label(const Duration(days: 1)), 'Yesterday');
    expect(label(const Duration(days: 4)), '4d ago');
  });
}
