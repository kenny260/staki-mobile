// TEMP: replace with domain entities once the backend team publishes them.

enum InvestorType {
  individual('Individual investor', 'Local resident of Rwanda'),
  diaspora('Diaspora investor', 'Investing from abroad'),
  institutional('Institutional lender', 'Bank, MFI, or Fund');

  const InvestorType(this.title, this.subtitle);

  final String title;
  final String subtitle;
}

enum KycFile { governmentId, selfie }

/// Returns the 9 national digits of a Rwandan mobile number, or null if the
/// input is not valid. Accepts "788 555 210", "0788555210" and "250788555210".
String? normalizeRwandaPhone(String input) {
  var digits = input.replaceAll(RegExp('[^0-9]'), '');
  if (digits.startsWith('250') && digits.length == 12) {
    digits = digits.substring(3);
  }
  if (digits.startsWith('0') && digits.length == 10) {
    digits = digits.substring(1);
  }
  if (digits.length != 9 || !digits.startsWith('7')) return null;
  return digits;
}

/// "788555210" becomes "788 555 210".
String formatRwandaPhone(String digits) =>
    '${digits.substring(0, 3)} ${digits.substring(3, 6)} '
    '${digits.substring(6)}';

class KycPhoto {
  const KycPhoto({required this.name, required this.path});

  final String name;
  final String path;
}

/// The registration the lender is still filling in.
class LenderDraft {
  const LenderDraft({
    this.phone = '',
    this.profileType,
    this.idFileName,
    this.selfieFileName,
    this.riskAcknowledged = false,
    this.structureAccepted = false,
  });

  final String phone;
  final InvestorType? profileType;
  final String? idFileName;
  final String? selfieFileName;
  final bool riskAcknowledged;
  final bool structureAccepted;

  bool get hasIdentityDocuments => idFileName != null && selfieFileName != null;

  bool get isComplete =>
      phone.isNotEmpty &&
      profileType != null &&
      hasIdentityDocuments &&
      riskAcknowledged &&
      structureAccepted;

  LenderDraft copyWith({
    String? phone,
    InvestorType? profileType,
    String? idFileName,
    String? selfieFileName,
    bool? riskAcknowledged,
    bool? structureAccepted,
  }) {
    return LenderDraft(
      phone: phone ?? this.phone,
      profileType: profileType ?? this.profileType,
      idFileName: idFileName ?? this.idFileName,
      selfieFileName: selfieFileName ?? this.selfieFileName,
      riskAcknowledged: riskAcknowledged ?? this.riskAcknowledged,
      structureAccepted: structureAccepted ?? this.structureAccepted,
    );
  }

  LenderDraft withoutFile(KycFile which) {
    return LenderDraft(
      phone: phone,
      profileType: profileType,
      idFileName: which == KycFile.governmentId ? null : idFileName,
      selfieFileName: which == KycFile.selfie ? null : selfieFileName,
      riskAcknowledged: riskAcknowledged,
      structureAccepted: structureAccepted,
    );
  }
}

/// A submitted lender registration.
class LenderProfile {
  const LenderProfile({
    required this.phone,
    required this.type,
    required this.submittedOn,
  });

  final String phone;
  final InvestorType type;
  final DateTime submittedOn;
}

class LenderException implements Exception {
  const LenderException(this.message);

  final String message;
}
