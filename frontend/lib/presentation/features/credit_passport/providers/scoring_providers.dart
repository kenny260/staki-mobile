import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:staki_mobile/data/datasources/scoring_datasource.dart';
import 'package:staki_mobile/presentation/features/credit_passport/providers/credit_passport_models.dart';

/// What the server sends back. Only the status and score are used here: C02
/// and C03 read the full result (with factors) from Firestore scores/{uid}.
class ScoringResult {
  const ScoringResult({
    required this.status,
    this.value,
    this.band,
    this.factors = const [],
    this.modelVersion = '',
  });

  factory ScoringResult.fromJson(Map<String, dynamic> json) {
    final status = switch (json['assessmentStatus']) {
      'complete' => AssessmentStatus.complete,
      'needsInfo' => AssessmentStatus.needsInfo,
      _ => throw const FormatException('Unknown assessmentStatus'),
    };
    final value = (json['value'] as num?)?.toInt();
    if (status == AssessmentStatus.complete && value == null) {
      throw const FormatException('A complete assessment needs a score');
    }
    final rawFactors = json['factors'];
    return ScoringResult(
      status: status,
      value: value,
      band: json['band'] as String?,
      factors: rawFactors is List
          ? rawFactors.whereType<Map<String, dynamic>>().toList()
          : const [],
      modelVersion: json['modelVersion'] as String? ?? '',
    );
  }

  final AssessmentStatus status;
  final int? value;
  final String? band;
  final List<Map<String, dynamic>> factors;
  final String modelVersion;
}

final scoringDatasourceProvider = Provider<ScoringDatasource>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return ScoringDatasource(
    client: client,
    idToken: () async {
      final user = FirebaseAuth.instance.currentUser;
      return user?.getIdToken();
    },
  );
});

/// Calls the API once when C01 opens. Retry = ref.invalidate(this provider).
final scoringResultProvider = FutureProvider.autoDispose<ScoringResult>((
  ref,
) async {
  final json =
      await ref.watch(scoringDatasourceProvider).computeCreditPassport();
  return ScoringResult.fromJson(json);
});
