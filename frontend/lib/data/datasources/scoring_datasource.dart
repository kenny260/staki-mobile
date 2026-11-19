import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:staki_mobile/core/constants/scoring_config.dart';

/// Returns the signed-in user's Firebase ID token, or null if nobody is
/// signed in.
typedef IdTokenProvider = Future<String?> Function();

/// The server answered 401, or there is no signed-in user.
class ScoringSessionExpiredException implements Exception {
  const ScoringSessionExpiredException();
}

/// The server answered with an error, or with something unreadable.
class ScoringServerException implements Exception {
  const ScoringServerException(this.statusCode);

  final int statusCode;
}

/// Asks the server to compute the borrower's Credit Passport.
class ScoringDatasource {
  ScoringDatasource({
    required IdTokenProvider idToken,
    http.Client? client,
    String? baseUrl,
  })  : _idToken = idToken,
        _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? ScoringConfig.baseUrl;

  static const _timeout = Duration(seconds: 30);

  final IdTokenProvider _idToken;
  final http.Client _client;
  final String _baseUrl;

  /// POST with no body. The result is also saved to Firestore scores/{uid}.
  Future<Map<String, dynamic>> computeCreditPassport() async {
    final token = await _idToken();
    if (token == null || token.isEmpty) {
      throw const ScoringSessionExpiredException();
    }

    final response = await _client.post(
      Uri.parse('$_baseUrl${ScoringConfig.computePath}'),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(_timeout);

    if (response.statusCode == 401) {
      throw const ScoringSessionExpiredException();
    }
    if (response.statusCode != 200) {
      throw ScoringServerException(response.statusCode);
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw ScoringServerException(response.statusCode);
    }
    return decoded;
  }
}
