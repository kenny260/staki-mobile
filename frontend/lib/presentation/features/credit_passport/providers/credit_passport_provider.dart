import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staki_mobile/presentation/features/credit_passport/providers/credit_passport_models.dart';

// TEMP: swap the implementation when the backend repository is ready.
abstract class CreditPassportRepository {
  Stream<AssessmentStatus> watchAssessmentStatus();
  Stream<CreditScore?> watchScore();
  List<DataCheck> dataChecks();
  NeedsInfoIssue? needsInfoIssue();
}

class MockCreditPassportRepository implements CreditPassportRepository {
  const MockCreditPassportRepository();

  /// Change this value to preview each C01 state while building:
  /// processing, needsInfo, complete, failed.
  @override
  Stream<AssessmentStatus> watchAssessmentStatus() async* {
    yield AssessmentStatus.processing;
    await Future<void>.delayed(const Duration(seconds: 3));
    yield AssessmentStatus.complete;
  }

  @override
  Stream<CreditScore?> watchScore() => Stream.value(
        const CreditScore(
          value: 780,
          updatedLabel: 'Updated today',
          factors: [
            ScoreFactor(
              title: 'Cash-flow strength',
              levelLabel: 'HIGH',
              progress: 0.85,
              summary: 'Your incoming cash flow is consistent and healthy.',
              helped: 'Consistent weekly deposits over the last 6 months.',
              improve: 'More consistent monthly activity.',
              icon: Icons.show_chart,
            ),
            ScoreFactor(
              title: 'Financial consistency',
              levelLabel: 'GOOD',
              progress: 0.65,
              summary: 'Your financial activity is stable and '
                  'predictable over time.',
              helped: 'Long history of active account usage.',
              improve: 'Avoid sudden, large drops in transaction volume.',
              icon: Icons.sync,
            ),
          ],
        ),
      );

  @override
  List<DataCheck> dataChecks() => const [
        DataCheck('Identity and data verification', CheckState.done),
        DataCheck('Financial activity', CheckState.done),
        DataCheck('Transaction consistency', CheckState.active),
        DataCheck('Affordability', CheckState.pending),
        DataCheck('Repayment behavior', CheckState.pending),
      ];

  @override
  NeedsInfoIssue? needsInfoIssue() => const NeedsInfoIssue(
        documentName: 'Business Registration (RDB)',
        message: 'The uploaded photo was blurry and the registration number '
            'could not be read. Please upload a scanned PDF or a clearer '
            'photo.',
      );
}

final creditPassportRepositoryProvider = Provider<CreditPassportRepository>(
  (ref) => const MockCreditPassportRepository(),
);

final assessmentStatusProvider = StreamProvider<AssessmentStatus>(
  (ref) => ref.watch(creditPassportRepositoryProvider).watchAssessmentStatus(),
);

final creditScoreProvider = StreamProvider<CreditScore?>(
  (ref) => ref.watch(creditPassportRepositoryProvider).watchScore(),
);

final dataChecksProvider = Provider<List<DataCheck>>(
  (ref) => ref.watch(creditPassportRepositoryProvider).dataChecks(),
);

final needsInfoIssueProvider = Provider<NeedsInfoIssue?>(
  (ref) => ref.watch(creditPassportRepositoryProvider).needsInfoIssue(),
);
