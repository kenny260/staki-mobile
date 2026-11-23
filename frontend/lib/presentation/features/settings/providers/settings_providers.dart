import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staki_mobile/presentation/features/consent/providers/consent_models.dart';
import 'package:staki_mobile/presentation/features/consent/providers/consent_providers.dart';

/// Which data sources the user has authorised (S02_DataPermissions).
class DataPermissions {
  const DataPermissions({
    this.momoConnected = false,
    this.bankConnected = false,
    this.documentsUploaded = 0,
  });

  final bool momoConnected;
  final bool bankConnected;
  final int documentsUploaded;

  DataPermissions copyWith({bool? momoConnected, bool? bankConnected}) =>
      DataPermissions(
        momoConnected: momoConnected ?? this.momoConnected,
        bankConnected: bankConnected ?? this.bankConnected,
        documentsUploaded: documentsUploaded,
      );
}

/// MoMo status comes from the consent ledger in Firestore (consents).
/// Bank stays in memory until a bank connection exists.
class DataPermissionsNotifier extends Notifier<DataPermissions> {
  @override
  DataPermissions build() => const DataPermissions();

  /// Reads the latest MoMo consent. Called when S02 opens, so it is
  /// always current for whoever is signed in. Keeps the current value
  /// if Firestore cannot be reached.
  Future<void> refreshMomo() async {
    try {
      final record =
          await ref.read(consentRepositoryProvider).getConsent(momoConsentType);
      state = state.copyWith(momoConnected: record?.granted ?? false);
    } on Object {
      return;
    }
  }

  void setMomo({required bool connected}) =>
      state = state.copyWith(momoConnected: connected);

  void setBank({required bool connected}) =>
      state = state.copyWith(bankConnected: connected);
}

final dataPermissionsProvider =
    NotifierProvider<DataPermissionsNotifier, DataPermissions>(
  DataPermissionsNotifier.new,
);

/// Language codes the app will support (localization is Sprint 3).
const supportedLanguages = {
  'en': 'English',
  'rw': 'Kinyarwanda',
  'fr': 'Français',
};
