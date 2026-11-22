import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:staki_mobile/core/errors/auth_failure.dart';
import 'package:staki_mobile/data/datasources/firebase_auth_datasource.dart';
import 'package:staki_mobile/data/datasources/google_sign_in_datasource.dart';
import 'package:staki_mobile/data/repositories/auth_repository_impl.dart';

class _MockAuth extends Mock implements FirebaseAuthDatasource {}

class _MockGoogle extends Mock implements GoogleSignInDatasource {}

class _MockUser extends Mock implements User {}

class _MockCredential extends Mock implements AuthCredential {}

User _user({bool verified = true}) {
  final u = _MockUser();
  when(() => u.uid).thenReturn('u1');
  when(() => u.email).thenReturn('demo@example.com');
  when(() => u.displayName).thenReturn('Demo');
  when(() => u.emailVerified).thenReturn(verified);
  when(() => u.providerData).thenReturn([]);
  return u;
}

void main() {
  late _MockAuth auth;
  late _MockGoogle google;
  late AuthRepositoryImpl repo;

  setUpAll(() => registerFallbackValue(_MockCredential()));

  setUp(() {
    auth = _MockAuth();
    google = _MockGoogle();
    repo = AuthRepositoryImpl(auth, google);
  });

  test('register creates the account and sends a verification email', () async {
    final user = _user(verified: false);
    when(() => auth.register('a@b.co', 'secret12'))
        .thenAnswer((_) async => user);
    when(() => auth.sendVerificationEmail()).thenAnswer((_) async {});

    final result = await repo.registerWithEmail('a@b.co', 'secret12');

    expect(result.uid, 'u1');
    expect(result.emailVerified, isFalse);
    expect(result.provider, 'password');
    verify(() => auth.sendVerificationEmail()).called(1);
  });

  test('a wrong password becomes a friendly AuthFailure', () {
    when(() => auth.signIn(any(), any()))
        .thenThrow(FirebaseAuthException(code: 'wrong-password'));
    expect(
      () => repo.signInWithEmail('a@b.co', 'bad'),
      throwsA(isA<AuthFailure>()),
    );
  });

  test('closing the Google picker returns null, not an error', () async {
    when(() => google.getCredential()).thenAnswer((_) async => null);
    expect(await repo.signInWithGoogle(), isNull);
    verifyNever(() => auth.signInWithCredential(any()));
  });

  test('Google sign-in exchanges the credential with Firebase', () async {
    final cred = _MockCredential();
    final user = _user();
    when(() => google.getCredential()).thenAnswer((_) async => cred);
    when(() => auth.signInWithCredential(cred)).thenAnswer((_) async => user);
    expect((await repo.signInWithGoogle())!.uid, 'u1');
  });

  test('password reset stays silent for an unknown email', () async {
    when(() => auth.sendPasswordReset(any()))
        .thenThrow(FirebaseAuthException(code: 'user-not-found'));
    await repo.sendPasswordReset('nobody@example.com');
  });

  test('checking verification reloads the user', () async {
    final user = _user();
    when(() => auth.reload()).thenAnswer((_) async => user);
    expect(await repo.reloadAndCheckVerified(), isTrue);
  });

  test('checking verification when signed out fails clearly', () {
    when(() => auth.reload()).thenAnswer((_) async => null);
    expect(
      repo.reloadAndCheckVerified,
      throwsA(
        isA<AuthFailure>().having(
          (f) => f.code,
          'code',
          AuthFailureCode.notSignedIn,
        ),
      ),
    );
  });

  test('sign out signs out of Google and Firebase', () async {
    when(() => google.signOut()).thenAnswer((_) async {});
    when(() => auth.signOut()).thenAnswer((_) async {});
    await repo.signOut();
    verify(() => google.signOut()).called(1);
    verify(() => auth.signOut()).called(1);
  });

  test('auth state maps Firebase users to app users', () async {
    when(() => auth.userChanges())
        .thenAnswer((_) => Stream.fromIterable([null, _user()]));
    final users = await repo.authStateChanges().toList();
    expect(users.first, isNull);
    expect(users.last!.email, 'demo@example.com');
  });
}
