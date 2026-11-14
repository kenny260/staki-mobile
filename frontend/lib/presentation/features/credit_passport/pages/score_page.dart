import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/app_icons.dart';
import 'package:staki_mobile/presentation/features/credit_passport/providers/credit_passport_models.dart';
import 'package:staki_mobile/presentation/features/credit_passport/providers/credit_passport_provider.dart';
import 'package:staki_mobile/presentation/features/credit_passport/widgets/factor_summary_card.dart';
import 'package:staki_mobile/presentation/features/credit_passport/widgets/passport_app_bar.dart';
import 'package:staki_mobile/presentation/features/credit_passport/widgets/score_gauge.dart';

class ScorePage extends ConsumerWidget {
  const ScorePage({super.key});

  Color _bandColor(ScoreBand band) {
    switch (band) {
      case ScoreBand.poor:
        return AppColors.scorePoor;
      case ScoreBand.fair:
        return AppColors.scoreFair;
      case ScoreBand.good:
        return AppColors.scoreGood;
      case ScoreBand.veryGood:
        return AppColors.scoreVeryGood;
      case ScoreBand.exceptional:
        return AppColors.scoreExceptional;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final score = ref.watch(creditScoreProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PassportAppBar(title: 'Credit Passport'),
      body: score.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(
          child: Text('Could not load your score. Please try again.'),
        ),
        data: (s) {
          if (s == null) {
            return const Center(child: Text('Your score is being prepared.'));
          }
          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  color: AppColors.surfaceAlt,
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Column(
                    children: [
                      const Text(
                        'YOUR CREDIT PASSPORT SCORE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ScoreGauge(
                        score: s.value,
                        color: _bandColor(s.band),
                        bandLabel: s.bandLabel,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '300',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                AppIcons.circle,
                                size: 8,
                                color: AppColors.success,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                s.updatedLabel,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            '1000',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'What this means',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Your score summarizes the financial information '
                        "you've authorized us to analyze. It is one factor "
                        'used by partnered lenders when making funding '
                        'decisions.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _PillButton(
                              label: 'Understand my score',
                              onTap: () =>
                                  context.push('/credit-passport/breakdown'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _PillButton(
                              label: 'Improve my score',
                              // TODO(chris): confirm the target in Figma.
                              onTap: () =>
                                  context.push('/credit-passport/breakdown'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'Score Factors',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...s.factors.map((f) => FactorSummaryCard(factor: f)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        shape: const StadiumBorder(),
        side: const BorderSide(color: AppColors.border),
        foregroundColor: AppColors.primary,
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
