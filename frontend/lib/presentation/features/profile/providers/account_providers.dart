import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staki_mobile/presentation/features/auth/providers/auth_providers.dart';

/// What the Home and Profile tabs show about the signed-in user.
/// Read from users/{uid} and, for borrowers, profiles/{uid}.
class AccountProfile {
  const AccountProfile({
    required this.uid,
    required this.role,
    this.displayName,
    this.email,
    this.phone,
    this.borrowerType,
    this.answers = const {},
  });

  final String uid;

  /// 'borrower' or 'lender'.
  final String role;
  final String? displayName;
  final String? email;
  final String? phone;

  /// business, startup, student, salaried or other. Null until the
  /// borrower finishes profile setup.
  final String? borrowerType;
  final Map<String, dynamic> answers;

  bool get isLender => role == 'lender';

  /// "Demo Borrower" -> "Demo". Falls back to the email name.
  String get firstName {
    final name = displayName?.trim() ?? '';
    if (name.isNotEmpty) return name.split(' ').first;
    final mail = email ?? '';
    return mail.contains('@') ? mail.split('@').first : 'there';
  }

  /// "Demo Borrower" -> "DB".
  String get initials {
    final parts = (displayName ?? email ?? '?')
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    final first = parts.first[0];
    final second = parts.length > 1 ? parts[1][0] : '';
    return (first + second).toUpperCase();
  }

  String get borrowerTypeLabel => switch (borrowerType) {
        'business' => 'Business owner',
        'startup' => 'Startup founder',
        'student' => 'Student',
        'salaried' => 'Salaried employee',
        'other' => 'Other income',
        _ => 'Profile not completed',
      };
}

/// The signed-in user's account. Null when signed out.
final accountProfileProvider =
    FutureProvider.autoDispose<AccountProfile?>((ref) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return null;
  final db = ref.watch(firestoreProvider);

  final userDoc = await db.collection('users').doc(user.uid).get();
  final data = userDoc.data() ?? const <String, dynamic>{};
  final role = data['role'] as String? ?? 'borrower';

  Map<String, dynamic>? profile;
  if (role == 'borrower') {
    profile = (await db.collection('profiles').doc(user.uid).get()).data();
  }

  return AccountProfile(
    uid: user.uid,
    role: role,
    displayName: data['displayName'] as String? ?? user.displayName,
    email: data['email'] as String? ?? user.email,
    phone: data['phone'] as String?,
    borrowerType: profile?['borrowerType'] as String?,
    answers: (profile?['answers'] as Map?)?.cast<String, dynamic>() ?? const {},
  );
});
