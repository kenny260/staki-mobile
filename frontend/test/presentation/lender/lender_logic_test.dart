import 'package:flutter_test/flutter_test.dart';
import 'package:staki_mobile/presentation/features/lender/providers/lender_models.dart';

void main() {
  group('normalizeRwandaPhone', () {
    test('accepts the common ways of writing a number', () {
      expect(normalizeRwandaPhone('788 555 210'), '788555210');
      expect(normalizeRwandaPhone('0788555210'), '788555210');
      expect(normalizeRwandaPhone('250788555210'), '788555210');
    });

    test('rejects numbers that are too short, too long or not mobile', () {
      expect(normalizeRwandaPhone(''), isNull);
      expect(normalizeRwandaPhone('78855521'), isNull);
      expect(normalizeRwandaPhone('7885552100'), isNull);
      expect(normalizeRwandaPhone('588555210'), isNull);
    });
  });

  test('formatRwandaPhone groups the digits', () {
    expect(formatRwandaPhone('788555210'), '788 555 210');
  });

  test('a draft is complete only when every step is done', () {
    const empty = LenderDraft();
    expect(empty.isComplete, isFalse);

    final done = empty.copyWith(
      phone: '788555210',
      profileType: InvestorType.individual,
      idFileName: 'id.jpg',
      selfieFileName: 'me.jpg',
      riskAcknowledged: true,
      structureAccepted: true,
    );
    expect(done.isComplete, isTrue);
    expect(done.withoutFile(KycFile.selfie).isComplete, isFalse);
  });
}
