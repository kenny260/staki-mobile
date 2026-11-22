import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:staki_mobile/data/repositories/firestore_lender_repository.dart';
import 'package:staki_mobile/presentation/features/lender/providers/lender_models.dart';
import 'package:staki_mobile/presentation/features/lender/providers/lender_repository.dart';

class _MockFirestore extends Mock implements FirebaseFirestore {}

void main() {
  late FirestoreLenderRepository repo;

  setUp(() {
    repo = FirestoreLenderRepository(firestore: _MockFirestore(), uid: 'u1');
  });

  test('a phone number is required for the code', () {
    expect(() => repo.sendOtp(''), throwsA(isA<LenderException>()));
  });

  test('six digits are accepted, except the test reject code', () async {
    expect(await repo.verifyOtp('788123456', '123456'), isTrue);
    expect(await repo.verifyOtp('788123456', '12345'), isFalse);
    expect(
      await repo.verifyOtp('788123456', MockLenderRepository.invalidCode),
      isFalse,
    );
  });

  test('the PIN must be four digits', () async {
    await repo.setPin('1234');
    expect(() => repo.setPin('12'), throwsA(isA<LenderException>()));
  });

  test('the draft is kept and a KYC file can be removed', () async {
    await repo.saveDraft(
      const LenderDraft(
        phone: '788123456',
        idFileName: 'id.jpg',
        selfieFileName: 'me.jpg',
      ),
    );
    await repo.deleteKycFile(KycFile.selfie);
    final draft = await repo.loadDraft();
    expect(draft!.idFileName, 'id.jpg');
    expect(draft.selfieFileName, isNull);
  });

  test('an incomplete registration is refused before anything is saved', () {
    expect(
      () => repo.submit(const LenderDraft(phone: '788123456')),
      throwsA(isA<LenderException>()),
    );
  });
}
