import 'package:flutter_riverpod/flutter_riverpod.dart';

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

// TODO(Uche): replace with the consent ledger in Firestore.
/// Until then these flags only live in memory.
class DataPermissionsNotifier extends Notifier<DataPermissions> {
  @override
  DataPermissions build() => const DataPermissions();

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
