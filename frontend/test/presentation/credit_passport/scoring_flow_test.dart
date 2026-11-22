import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/router/app_routes.dart';
import 'package:staki_mobile/data/datasources/scoring_datasource.dart';
import 'package:staki_mobile/presentation/features/credit_passport/pages/assessment_page.dart';
import 'package:staki_mobile/presentation/features/credit_passport/providers/credit_passport_models.dart';
import 'package:staki_mobile/presentation/features/credit_passport/providers/scoring_providers.dart';

class _FakeDatasource implements ScoringDatasource {
  _FakeDatasource(this._handler);

  final Future<Map<String, dynamic>> Function() _handler;
  int calls = 0;

  @override
  Future<Map<String, dynamic>> computeCreditPassport() {
    calls++;
    return _handler();
  }
}

const _complete = {
  'assessmentStatus': 'complete',
  'value': 742,
  'band': 'good',
  'factors': <Map<String, dynamic>>[],
  'modelVersion': 'rules-v1',
};

const _needsInfo = {
  'assessmentStatus': 'needsInfo',
  'value': null,
  'band': null,
  'factors': <Map<String, dynamic>>[],
  'modelVersion': 'rules-v1',
};

Future<void> _show(WidgetTester tester, _FakeDatasource datasource) async {
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, __) => const AssessmentPage()),
      GoRoute(
        path: AppRoutes.creditPassport,
        builder: (_, __) => const Scaffold(body: Text('SCORE SCREEN')),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [scoringDatasourceProvider.overrideWithValue(datasource)],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('ScoringResult.fromJson', () {
    test('reads a complete result', () {
      final result = ScoringResult.fromJson(_complete);
      expect(result.status, AssessmentStatus.complete);
      expect(result.value, 742);
      expect(result.band, 'good');
      expect(result.modelVersion, 'rules-v1');
    });

    test('reads a needsInfo result with no score', () {
      final result = ScoringResult.fromJson(_needsInfo);
      expect(result.status, AssessmentStatus.needsInfo);
      expect(result.value, isNull);
    });

    test('rejects an unknown status or a complete result without a score', () {
      expect(
        () => ScoringResult.fromJson({'assessmentStatus': 'weird'}),
        throwsFormatException,
      );
      expect(
        () => ScoringResult.fromJson({'assessmentStatus': 'complete'}),
        throwsFormatException,
      );
    });
  });

  testWidgets('complete shows C01c and View my Passport opens the score', (
    tester,
  ) async {
    final datasource = _FakeDatasource(() async => _complete);
    await _show(tester, datasource);
    expect(find.text('Assessment Complete'), findsOneWidget);
    expect(find.text('SCORE SCREEN'), findsNothing);
    expect(datasource.calls, 1);

    await tester.tap(find.text('View my Passport'));
    await tester.pumpAndSettle();
    expect(find.text('SCORE SCREEN'), findsOneWidget);
  });

  testWidgets('needsInfo shows the additional information screen', (
    tester,
  ) async {
    await _show(tester, _FakeDatasource(() async => _needsInfo));
    expect(find.text('Additional information required'), findsOneWidget);
    expect(find.text('Update Document'), findsOneWidget);
  });

  testWidgets('a server error shows the failed screen and Try Again retries', (
    tester,
  ) async {
    var attempt = 0;
    final datasource = _FakeDatasource(() async {
      attempt++;
      if (attempt == 1) throw const ScoringServerException(500);
      return _needsInfo;
    });
    await _show(tester, datasource);
    expect(find.text('Try Again'), findsOneWidget);

    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();

    expect(datasource.calls, 2);
    expect(find.text('Additional information required'), findsOneWidget);
  });

  testWidgets('an expired session shows the session expired screen', (
    tester,
  ) async {
    await _show(
      tester,
      _FakeDatasource(() async => throw const ScoringSessionExpiredException()),
    );
    expect(find.text('Session expired'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });
}
