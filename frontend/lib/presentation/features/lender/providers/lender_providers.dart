import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staki_mobile/presentation/features/lender/providers/lender_models.dart';
import 'package:staki_mobile/presentation/features/lender/providers/lender_picker.dart';
import 'package:staki_mobile/presentation/features/lender/providers/lender_repository.dart';

// TEMP mock. To preview the submit error, use:
// MockLenderRepository(failSubmit: true)
final lenderRepositoryProvider = Provider<LenderRepository>(
  (ref) => MockLenderRepository(),
);

final kycPickerProvider = Provider<KycPicker>((ref) => pickKycPhoto);

/// The digits typed so far on the PIN screen (cleared when done).
final pinEntryProvider = StateProvider.autoDispose<String>((ref) => '');

/// Seconds left before the OTP can be resent (45 down to 0).
final resendCountdownProvider = StreamProvider.autoDispose<int>(
  (ref) => Stream<int>.periodic(
    const Duration(seconds: 1),
    (i) => 44 - i,
  ).take(45),
);

class LenderState {
  const LenderState({
    this.draft = const LenderDraft(),
    this.otpVerified = false,
    this.pinSet = false,
    this.profile,
  });

  final LenderDraft draft;
  final bool otpVerified;
  final bool pinSet;
  final LenderProfile? profile;

  LenderState copyWith({
    LenderDraft? draft,
    bool? otpVerified,
    bool? pinSet,
    LenderProfile? profile,
  }) {
    return LenderState(
      draft: draft ?? this.draft,
      otpVerified: otpVerified ?? this.otpVerified,
      pinSet: pinSet ?? this.pinSet,
      profile: profile ?? this.profile,
    );
  }
}

class LenderController extends Notifier<LenderState> {
  LenderRepository get _repository => ref.read(lenderRepositoryProvider);

  @override
  LenderState build() => const LenderState();

  /// READ: loads a saved draft, if there is one.
  Future<void> start() async {
    LenderDraft? saved;
    try {
      saved = await _repository.loadDraft();
    } on Exception {
      saved = null;
    }
    if (saved != null) state = state.copyWith(draft: saved);
  }

  Future<bool> sendOtp(String phone) async {
    try {
      await _repository.sendOtp(phone);
      state = state.copyWith(draft: state.draft.copyWith(phone: phone));
      return true;
    } on Exception {
      return false;
    }
  }

  Future<bool> verifyOtp(String code) async {
    try {
      final ok = await _repository.verifyOtp(state.draft.phone, code);
      if (ok) state = state.copyWith(otpVerified: true);
      return ok;
    } on Exception {
      return false;
    }
  }

  Future<bool> createPin(String pin) async {
    try {
      await _repository.setPin(pin);
      state = state.copyWith(pinSet: true);
      return true;
    } on Exception {
      return false;
    }
  }

  void chooseType(InvestorType type) {
    state = state.copyWith(draft: state.draft.copyWith(profileType: type));
  }

  void attach(KycFile which, KycPhoto photo) {
    final draft = state.draft;
    state = state.copyWith(
      draft: which == KycFile.governmentId
          ? draft.copyWith(idFileName: photo.name)
          : draft.copyWith(selfieFileName: photo.name),
    );
  }

  /// DELETE an uploaded KYC file.
  Future<bool> removeFile(KycFile which) async {
    try {
      await _repository.deleteKycFile(which);
      state = state.copyWith(draft: state.draft.withoutFile(which));
      return true;
    } on Exception {
      return false;
    }
  }

  void toggleRisk() {
    final draft = state.draft;
    state = state.copyWith(
      draft: draft.copyWith(riskAcknowledged: !draft.riskAcknowledged),
    );
  }

  void toggleStructure() {
    final draft = state.draft;
    state = state.copyWith(
      draft: draft.copyWith(structureAccepted: !draft.structureAccepted),
    );
  }

  /// CREATE / UPDATE the draft.
  Future<bool> saveDraft() async {
    try {
      await _repository.saveDraft(state.draft);
      return true;
    } on Exception {
      return false;
    }
  }

  /// CREATE the registration. Returns null if it failed.
  Future<LenderProfile?> submit() async {
    try {
      final profile = await _repository.submit(state.draft);
      state = state.copyWith(profile: profile);
      return profile;
    } on Exception {
      return null;
    }
  }
}

final lenderControllerProvider =
    NotifierProvider<LenderController, LenderState>(LenderController.new);
