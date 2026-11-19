import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:staki_mobile/data/datasources/scoring_datasource.dart';

ScoringDatasource _datasource(
  MockClient client, {
  String? token = 'abc123',
}) {
  return ScoringDatasource(
    idToken: () async => token,
    client: client,
    baseUrl: 'https://example.test',
  );
}

void main() {
  test('posts to the API with the Firebase token and returns the JSON',
      () async {
    late http.Request seen;
    final client = MockClient((request) async {
      seen = request;
      return http.Response(
        jsonEncode({'assessmentStatus': 'complete', 'value': 742}),
        200,
      );
    });

    final result = await _datasource(client).computeCreditPassport();

    expect(seen.method, 'POST');
    expect(seen.url.toString(), 'https://example.test/api/credit-passport');
    expect(seen.headers['Authorization'], 'Bearer abc123');
    expect(result['value'], 742);
  });

  test('a 401 means the session expired', () async {
    final client = MockClient((_) async => http.Response('', 401));
    expect(
      _datasource(client).computeCreditPassport(),
      throwsA(isA<ScoringSessionExpiredException>()),
    );
  });

  test('no signed-in user means the session expired, with no request',
      () async {
    var called = false;
    final client = MockClient((_) async {
      called = true;
      return http.Response('{}', 200);
    });
    await expectLater(
      _datasource(client, token: null).computeCreditPassport(),
      throwsA(isA<ScoringSessionExpiredException>()),
    );
    expect(called, isFalse);
  });

  test('a 500 is a server failure', () async {
    final client = MockClient((_) async => http.Response('', 500));
    expect(
      _datasource(client).computeCreditPassport(),
      throwsA(isA<ScoringServerException>()),
    );
  });

  test('an unreadable body is a server failure', () async {
    final client = MockClient((_) async => http.Response('not json[', 200));
    expect(
      _datasource(client).computeCreditPassport(),
      throwsA(isA<FormatException>()),
    );
  });
}
