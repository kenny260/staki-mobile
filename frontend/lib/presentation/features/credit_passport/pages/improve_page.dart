import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/app_icons.dart';
import 'package:staki_mobile/presentation/features/credit_passport/providers/credit_passport_models.dart';
import 'package:staki_mobile/presentation/features/credit_passport/providers/credit_passport_provider.dart';
import 'package:staki_mobile/presentation/features/credit_passport/widgets/passport_app_bar.dart';
import 'package:staki_mobile/presentation/features/loans/loan_routes.dart';

/// C04: one tip per score factor, weakest factor first, then on to the
/// funding options (L01).
class ImprovePage extends ConsumerWidget {
  const ImprovePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final score = ref.watch(creditScoreProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PassportAppBar(title: 'Improve your score'),
      body: Column(
        children: [
          Expanded(
            child: score.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Center(
                child: Text('Could not load your tips. Please try again.'),
              ),
              data: (s) {
                final factors = [...?s?.factors]
                  ..sort((a, b) => a.progress.compareTo(b.progress));
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ways to raise your score',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Start with the factors at the top: they have the '
                        'most room to grow. Your score updates as new '
                        'activity comes in.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (factors.isEmpty)
                        const Text('Your tips are not ready yet.')
                      else
                        ...factors.map((f) => _TipCard(factor: f)),
                    ],
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: FilledButton(
                onPressed: () => unawaited(context.push(LoanRoutes.base)),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  shape: const StadiumBorder(),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'See funding options',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(width: 8),
                    Icon(AppIcons.arrowRight, size: 18),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({required this.factor});

  final ScoreFactor factor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(factor.icon, size: 18, color: AppColors.warning),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        factor.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Text(
                      factor.levelLabel,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  factor.improve,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
