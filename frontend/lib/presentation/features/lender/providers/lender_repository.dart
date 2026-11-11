import 'package:staki_mobile/presentation/features/lender/providers/lender_models.dart';

// TEMP: swap the implementation when the Firestore/Auth repository exists.
abstract class LenderRepository {
  Future<void> sendOtp(String phone);

  Future<bool> verifyOtp(String phone, String code);

  /// The mock never stores the PIN. Keep it out of Firestore in the real one.
  Future<void> setPin(String pin);

  /// READ the saved draft.
  Future<LenderDraft?> loadDraft();

  /// CREATE / UPDATE the draft.
  Future<void> saveDraft(LenderDraft draft);

  /// DELETE an uploaded KYC file.
  Future<void> deleteKycFile(KycFile which);

  /// CREATE the lender registration.
  Future<LenderProfile> submit(LenderDraft draft);
}

class MockLenderRepository implements LenderRepository {
  MockLenderRepository({
    this.delay = const Duration(milliseconds: 500),
    this.failSubmit = false,
  });

  /// The only code the mock accepts.
  static const validCode = '123456';

  final Duration delay;

  /// Set to true to preview the submit error.
  final bool failSubmit;

  LenderDraft? _draft;

  Future<void> _wait() => Future<void>.delayed(delay);

  @override
  Future<void> sendOtp(String phone) async {
    await _wait();
    if (phone.isEmpty) {
      throw const LenderException('A phone number is required.');
    }
  }

  @override
  Future<bool> verifyOtp(String phone, String code) async {
    await _wait();
    return code == validCode;
  }

  @override
  Future<void> setPin(String pin) async {
    await _wait();
    if (pin.length != 4) {
      throw const LenderException('The PIN must be 4 digits.');
    }
  }

  @override
  Future<LenderDraft?> loadDraft() async {
    await _wait();
    return _draft;
  }

  @override
  Future<void> saveDraft(LenderDraft draft) async {
    await _wait();
    _draft = draft;
  }

  @override
  Future<void> deleteKycFile(KycFile which) async {
    await _wait();
    _draft = _draft?.withoutFile(which);
  }

  @override
  Future<LenderProfile> submit(LenderDraft draft) async {
    await _wait();
    final type = draft.profileType;
    if (failSubmit || !draft.isComplete || type == null) {
      throw const LenderException(
        "We couldn't complete your registration. Please try again.",
      );
    }
    _draft = null;
    return LenderProfile(
      phone: draft.phone,
      type: type,
      submittedOn: DateTime.now(),
    );
  }
}
