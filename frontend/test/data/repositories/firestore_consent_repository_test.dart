import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:staki_mobile/data/datasources/consent_datasource.dart';
import 'package:staki_mobile/data/repositories/firestore_consent_repository.dart';

class _MockConsentDatasource extends Mock implements ConsentDatasource {}

Map<String, dynamic> _doc({bool granted = true}) => {
      'id': 'c1',
      'userId': 'uid1',
      'type': 'momo',
      'granted': granted,
      'grantedAt': Timestamp.fromDate(DateTime(2026)),
      'revokedAt': granted ? null : Timestamp.fromDate(DateTime(2026, 1, 2)),
    };

void main() {
  late _MockConsentDatasource datasource;
  late FirestoreConsentRepository repo;

  setUp(() {
    datasource = _MockConsentDatasource();
    repo = FirestoreConsentRepository(
      datasource: datasource,
      currentUid: () => 'uid1',
    );
  });

  test('getConsent returns null when nothing is saved', () async {
    when(() => datasource.getLatest('uid1', 'momo'))
        .thenAnswer((_) async => null);

    expect(await repo.getConsent('momo'), isNull);
  });

  test('grantConsent creates a consent when none exists', () async {
    when(() => datasource.getLatest('uid1', 'momo'))
        .thenAnswer((_) async => null);
    when(() => datasource.grant('uid1', 'momo'))
        .thenAnswer((_) async => _doc());

    final record = await repo.grantConsent('momo');

    expect(record.type, 'momo');
    expect(record.granted, isTrue);
    verify(() => datasource.grant('uid1', 'momo')).called(1);
  });

  test('grantConsent does not duplicate an active consent', () async {
    when(() => datasource.getLatest('uid1', 'momo'))
        .thenAnswer((_) async => _doc());

    final record = await repo.grantConsent('momo');

    expect(record.granted, isTrue);
    verifyNever(() => datasource.grant(any(), any()));
  });

  test('revokeConsent revokes the active consent', () async {
    when(() => datasource.getLatest('uid1', 'momo'))
        .thenAnswer((_) async => _doc());
    when(() => datasource.revoke('c1'))
        .thenAnswer((_) async => _doc(granted: false));

    final record = await repo.revokeConsent('momo');

    expect(record.granted, isFalse);
    expect(record.revokedAt, DateTime(2026, 1, 2));
    verify(() => datasource.revoke('c1')).called(1);
  });

  test('revokeConsent throws when there is nothing to revoke', () async {
    when(() => datasource.getLatest('uid1', 'momo'))
        .thenAnswer((_) async => null);

    expect(() => repo.revokeConsent('momo'), throwsStateError);
  });

  test('throws when nobody is signed in', () {
    final signedOut = FirestoreConsentRepository(
      datasource: datasource,
      currentUid: () => null,
    );

    expect(() => signedOut.getConsent('momo'), throwsStateError);
  });
}
