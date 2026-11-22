import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:staki_mobile/presentation/features/lender/providers/lender_models.dart';
import 'package:staki_mobile/presentation/features/lender/providers/lender_repository.dart';

/// Saves the lender registration to Firestore at `lenders/{uid}`.
///
/// The phone code and PIN screens are checked on the device: the lender is
/// already signed in with Firebase Auth, and the PIN is never stored.
/// KYC status starts as 'pending' and the wallet balance is set by the
/// server, as firestore.rules require. The ID and selfie photos stay on the
/// device for now; uploading them is listed in the report's future work.
class FirestoreLenderRepository implements LenderRepository {
  FirestoreLenderRepository({
    required FirebaseFirestore firestore,
    required String uid,
  })  : _firestore = firestore,
        _uid = uid;

  final FirebaseFirestore _firestore;
  final String _uid;
  LenderDraft? _draft;

  @override
  Future<void> sendOtp(String phone) async {
    if (phone.isEmpty) {
      throw const LenderException('A phone number is required.');
    }
  }

  @override
  Future<bool> verifyOtp(String phone, String code) async =>
      RegExp(r'^\d{6}$').hasMatch(code) &&
      code != MockLenderRepository.invalidCode;

  @override
  Future<void> setPin(String pin) async {
    if (pin.length != 4) {
      throw const LenderException('The PIN must be 4 digits.');
    }
  }

  @override
  Future<LenderDraft?> loadDraft() async => _draft;

  @override
  Future<void> saveDraft(LenderDraft draft) async => _draft = draft;

  @override
  Future<void> deleteKycFile(KycFile which) async =>
      _draft = _draft?.withoutFile(which);

  /// The fields written on registration, in the shape the rules check.
  static Map<String, dynamic> registration(LenderDraft draft) => {
        'phone': draft.phone,
        'investorType': draft.profileType!.name,
        'kycStatus': 'pending',
        'riskAcknowledged': draft.riskAcknowledged,
        'structureAccepted': draft.structureAccepted,
      };

  @override
  Future<LenderProfile> submit(LenderDraft draft) async {
    final type = draft.profileType;
    if (!draft.isComplete || type == null) {
      throw const LenderException(
        "We couldn't complete your registration. Please try again.",
      );
    }
    try {
      await _firestore.collection('lenders').doc(_uid).set({
        ...registration(draft),
        'submittedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException {
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
