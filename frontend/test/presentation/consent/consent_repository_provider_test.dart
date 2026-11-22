import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:staki_mobile/data/repositories/firestore_consent_repository.dart';
import 'package:staki_mobile/domain/entities/app_user.dart';
import 'package:staki_mobile/presentation/features/auth/providers/auth_providers.dart';
import 'package:staki_mobile/presentation/features/consent/providers/consent_providers.dart';
import 'package:staki_mobile/presentation/features/consent/providers/consent_repository.dart';

class _MockFirestore extends Mock implements FirebaseFirestore {}

const _user = AppUser(
  uid: 'u1',
  email: 'demo@example.com',
  displayName: 'Demo',
  emailVerified: true,
  provider: 'password',
);

Future<ConsentRepository> _repoFor(AppUser? user) async {
  final container = ProviderContainer(
    overrides: [
      authStateProvider.overrideWith((ref) => Stream.value(user)),
      firestoreProvider.overrideWithValue(_MockFirestore()),
    ],
  );
  addTearDown(container.dispose);
  await container.read(authStateProvider.future);
  return container.read(consentRepositoryProvider);
}

void main() {
  test('uses the in-memory repository when nobody is signed in', () async {
    expect(await _repoFor(null), isA<MockConsentRepository>());
  });

  test('uses Firestore when a user is signed in', () async {
    expect(await _repoFor(_user), isA<FirestoreConsentRepository>());
  });
}
