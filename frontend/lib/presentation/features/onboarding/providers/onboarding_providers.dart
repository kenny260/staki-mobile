import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staki_mobile/domain/entities/user_role.dart';
import 'package:staki_mobile/presentation/shared_providers/preferences_providers.dart';

class SelectedRoleNotifier extends Notifier<UserRole?> {
  @override
  UserRole? build() => null;

  /// Selects a role and remembers it as the "last role" in SharedPreferences.
  Future<void> select(UserRole role) async {
    state = role;
    await ref.read(preferencesProvider).setLastRole(role.name);
  }
}

final selectedRoleProvider =
    NotifierProvider<SelectedRoleNotifier, UserRole?>(SelectedRoleNotifier.new);

class PhoneNumberNotifier extends Notifier<String> {
  @override
  String build() => '';

  // ignore: use_setters_to_change_properties
  void set(String value) => state = value;
}

/// First PIN entry, kept in memory only until it is confirmed.
// TODO(Tolu): store the confirmed PIN hash with flutter_secure_storage.
class PinDraftNotifier extends Notifier<String> {
  @override
  String build() => '';

  // ignore: use_setters_to_change_properties
  void set(String value) => state = value;
  void clear() => state = '';
}

final pinDraftProvider =
    NotifierProvider<PinDraftNotifier, String>(PinDraftNotifier.new);

final phoneNumberProvider =
    NotifierProvider<PhoneNumberNotifier, String>(PhoneNumberNotifier.new);
