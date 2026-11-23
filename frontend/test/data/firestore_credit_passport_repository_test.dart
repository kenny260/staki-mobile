import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staki_mobile/core/theme/app_icons.dart';
import 'package:staki_mobile/data/repositories/firestore_credit_passport_repository.dart';
import 'package:staki_mobile/presentation/features/credit_passport/providers/credit_passport_models.dart';

/// What the scoring API saves to scores/{uid}.
Map<String, dynamic> _apiDoc({DateTime? updatedAt}) => {
      'assessmentStatus': 'complete',
      'value': 688,
      'band': 'good',
      'modelVersion': 'rules-v1',
      'updatedAt': updatedAt == null ? null : Timestamp.fromDate(updatedAt),
      'factors': [
        {
          'id': 'cashFlow',
          'title': 'Cash-flow strength',
          'levelLabel': 'HIGH',
          'progress': 0.82,
          'points': 164,
          'summary': 'Money comes in steadily.',
          'helped': 'Money comes in steadily.',
          'improve': 'Keep income flowing in.',
        },
        {
          'id': 'verification',
          'title': 'Identity & data',
          'levelLabel': 'LOW',
          'progress': 0.2,
          'points': 14,
          'summary': 'Some identity or bank data is still missing.',
          'helped': 'Some activity was found.',
          'improve': 'Connect a bank account.',
        },
      ],
    };

void main() {
  final now = DateTime(2026, 11, 23, 15);

  group('creditScoreFromDoc', () {
    test('maps the API document to a CreditScore', () {
      final score = creditScoreFromDoc(
        _apiDoc(updatedAt: DateTime(2026, 11, 23, 9)),
        now: now,
      )!;
      expect(score.value, 688);
      expect(score.band, ScoreBand.good);
      expect(score.updatedLabel, 'Updated today');
      expect(score.factors, hasLength(2));
      final cash = score.factors.first;
      expect(cash.title, 'Cash-flow strength');
      expect(cash.levelLabel, 'HIGH');
      expect(cash.progress, 0.82);
      expect(cash.summary, 'Money comes in steadily.');
      expect(cash.improve, 'Keep income flowing in.');
      expect(cash.icon, AppIcons.chartLineUp);
      expect(cash.points, 164);
      expect(score.factors.last.points, 14);
      expect(score.factors.last.icon, AppIcons.shieldCheck);
    });

    test('no document means no score yet', () {
      expect(creditScoreFromDoc(null), isNull);
    });

    test('a needsInfo result (value null) means no score yet', () {
      expect(
        creditScoreFromDoc({'assessmentStatus': 'needsInfo', 'value': null}),
        isNull,
      );
    });

    test('a score without factors still shows', () {
      final score = creditScoreFromDoc({'value': 600}, now: now)!;
      expect(score.value, 600);
      expect(score.factors, isEmpty);
      expect(score.updatedLabel, 'Updated just now');
    });
  });

  group('updatedLabel', () {
    test('today, yesterday, a date this year and an older date', () {
      expect(updatedLabel(DateTime(2026, 11, 23, 1), now), 'Updated today');
      expect(updatedLabel(DateTime(2026, 11, 22), now), 'Updated yesterday');
      expect(updatedLabel(DateTime(2026, 11, 20), now), 'Updated Nov 20');
      expect(
        updatedLabel(DateTime(2025, 6, 24), now),
        'Updated Jun 24, 2025',
      );
    });

    test('a pending server timestamp reads as just now', () {
      expect(updatedLabel(null, now), 'Updated just now');
    });
  });

  test('factorIcon has an icon for every scorecard factor', () {
    for (final id in [
      'cashFlow',
      'regularity',
      'payments',
      'balance',
      'history',
      'verification',
    ]) {
      expect(factorIcon(id), isNot(AppIcons.gauge), reason: id);
    }
    expect(factorIcon('somethingNew'), AppIcons.gauge);
  });

  group('FirestoreCreditPassportRepository.watchScore', () {
    test('listens to the score document and updates when a new one is saved',
        () async {
      final docs = StreamController<Map<String, dynamic>?>();
      addTearDown(docs.close);
      String? watchedUid;
      final repo = FirestoreCreditPassportRepository(
        uid: 'u1',
        watchScoreDoc: (uid) {
          watchedUid = uid;
          return docs.stream;
        },
      );
      final values = <int?>[];
      final sub = repo.watchScore().listen((s) => values.add(s?.value));
      addTearDown(sub.cancel);

      docs
        ..add(null)
        ..add(_apiDoc())
        ..add({..._apiDoc(), 'value': 731});
      await Future<void>.delayed(Duration.zero);

      expect(watchedUid, 'u1');
      expect(values, [null, 688, 731]);
    });

    test('signed out: no score and nothing is read', () async {
      var read = false;
      final repo = FirestoreCreditPassportRepository(
        uid: null,
        watchScoreDoc: (_) {
          read = true;
          return const Stream.empty();
        },
      );
      expect(await repo.watchScore().first, isNull);
      expect(read, isFalse);
    });

    test('the C01 checks still come from the mock', () {
      final repo = FirestoreCreditPassportRepository(
        uid: 'u1',
        watchScoreDoc: (_) => const Stream.empty(),
      );
      expect(repo.dataChecks(), isNotEmpty);
      expect(repo.needsInfoIssue(), isNotNull);
    });
  });
}
