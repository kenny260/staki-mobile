import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staki_mobile/domain/entities/borrower_type.dart';

/// Keys for the answers collected in Section 02.
abstract final class ProfileFields {
  static const businessName = 'businessName';
  static const businessType = 'businessType';
  static const yearsOperating = 'yearsOperating';
  static const monthlyRevenue = 'monthlyRevenue';
  static const location = 'location';

  static const startupName = 'startupName';
  static const startupStage = 'startupStage';
  static const startupActivity = 'startupActivity';
  static const operatingHistory = 'operatingHistory';
  static const startupRevenue = 'startupRevenue';

  static const institution = 'institution';
  static const studyLevel = 'studyLevel';
  static const enrollment = 'enrollment';
  static const incomeSource = 'incomeSource';
  static const studentIncome = 'studentIncome';

  static const employmentType = 'employmentType';
  static const employerName = 'employerName';
  static const salaryRange = 'salaryRange';
  static const tenure = 'tenure';

  static const occupation = 'occupation';
  static const otherIncome = 'otherIncome';
}

class ProfileSetupState {
  const ProfileSetupState({this.type, this.answers = const {}});

  final BorrowerType? type;
  final Map<String, String> answers;

  String value(String key) => answers[key] ?? '';
  String? optionOrNull(String key) => answers[key];
  bool has(String key, {int min = 1}) => value(key).trim().length >= min;
}

class ProfileSetupNotifier extends Notifier<ProfileSetupState> {
  @override
  ProfileSetupState build() => const ProfileSetupState();

  /// Changing the borrower type clears answers that belonged to another type.
  void setType(BorrowerType type) {
    state = ProfileSetupState(
      type: type,
      answers: state.type == type ? state.answers : const {},
    );
  }

  void setAnswer(String key, String value) {
    state = ProfileSetupState(
      type: state.type,
      answers: {...state.answers, key: value},
    );
  }

  void reset() => state = const ProfileSetupState();
}

final profileSetupProvider =
    NotifierProvider<ProfileSetupNotifier, ProfileSetupState>(
  ProfileSetupNotifier.new,
);
