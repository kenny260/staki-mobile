import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:staki_mobile/core/theme/app_icons.dart';
import 'package:staki_mobile/presentation/features/credit_passport/providers/credit_passport_models.dart';
import 'package:staki_mobile/presentation/features/credit_passport/providers/credit_passport_provider.dart';

/// Reads the Credit Passport the scoring API writes to scores/{uid}
/// (backend/api/src/credit_passport.ts). The app can only read it; the
/// rules let only the server write scores.
///
/// The C01 data checks and the needs-info message have no backend yet, so
/// they still come from the mock.
class FirestoreCreditPassportRepository implements CreditPassportRepository {
  FirestoreCreditPassportRepository({
    required Stream<Map<String, dynamic>?> Function(String uid) watchScoreDoc,
    required String? uid,
    CreditPassportRepository fallback = const MockCreditPassportRepository(),
  })  : _watchScoreDoc = watchScoreDoc,
        _uid = uid,
        _fallback = fallback;

  /// Reads scores/{uid} from [firestore].
  factory FirestoreCreditPassportRepository.firestore(
    FirebaseFirestore firestore, {
    required String? uid,
  }) =>
      FirestoreCreditPassportRepository(
        uid: uid,
        watchScoreDoc: (uid) => firestore
            .collection('scores')
            .doc(uid)
            .snapshots()
            .map((doc) => doc.data()),
      );

  final Stream<Map<String, dynamic>?> Function(String uid) _watchScoreDoc;
  final String? _uid;
  final CreditPassportRepository _fallback;

  /// Live: updates on its own when a new assessment saves a score.
  @override
  Stream<CreditScore?> watchScore() {
    final uid = _uid;
    if (uid == null) return Stream.value(null);
    return _watchScoreDoc(uid).map(creditScoreFromDoc);
  }

  @override
  Stream<AssessmentStatus> watchAssessmentStatus() =>
      _fallback.watchAssessmentStatus();

  @override
  List<DataCheck> dataChecks() => _fallback.dataChecks();

  @override
  NeedsInfoIssue? needsInfoIssue() => _fallback.needsInfoIssue();
}

/// Maps a scores/{uid} document to a [CreditScore]. Null when there is no
/// document, or the last assessment needed more data (value is null).
CreditScore? creditScoreFromDoc(
  Map<String, dynamic>? data, {
  DateTime? now,
}) {
  if (data == null) return null;
  final value = (data['value'] as num?)?.toInt();
  if (value == null) return null;

  final updatedAt = (data['updatedAt'] as Timestamp?)?.toDate();
  final rawFactors = data['factors'];
  return CreditScore(
    value: value,
    updatedLabel: updatedLabel(updatedAt, now ?? DateTime.now()),
    factors: rawFactors is List
        ? rawFactors
            .whereType<Map<dynamic, dynamic>>()
            .map((f) => _factorFrom(f.cast<String, dynamic>()))
            .toList()
        : const [],
  );
}

ScoreFactor _factorFrom(Map<String, dynamic> f) => ScoreFactor(
      title: f['title'] as String? ?? '',
      levelLabel: f['levelLabel'] as String? ?? '',
      progress: ((f['progress'] as num?)?.toDouble() ?? 0).clamp(0.0, 1.0),
      summary: f['summary'] as String? ?? '',
      helped: f['helped'] as String? ?? '',
      improve: f['improve'] as String? ?? '',
      icon: factorIcon(f['id'] as String?),
      points: (f['points'] as num?)?.toInt(),
    );

/// Icon for each scorecard factor id (backend/api/src/scoring).
IconData factorIcon(String? id) => switch (id) {
      'cashFlow' => AppIcons.chartLineUp,
      'regularity' => AppIcons.arrowsClockwise,
      'payments' => AppIcons.money,
      'balance' => AppIcons.wallet,
      'history' => AppIcons.clockCounterClockwise,
      'verification' => AppIcons.shieldCheck,
      _ => AppIcons.gauge,
    };

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// "Updated today", "Updated yesterday" or "Updated Nov 20". A score the
/// server has not timestamped yet (pending write) counts as just now.
String updatedLabel(DateTime? updatedAt, DateTime now) {
  if (updatedAt == null) return 'Updated just now';
  final local = updatedAt.toLocal();
  final day = DateTime(local.year, local.month, local.day);
  final today = DateTime(now.year, now.month, now.day);
  final diff = today.difference(day).inDays;
  if (diff <= 0) return 'Updated today';
  if (diff == 1) return 'Updated yesterday';
  final label = '${_months[local.month - 1]} ${local.day}';
  return local.year == now.year
      ? 'Updated $label'
      : 'Updated $label, ${local.year}';
}
