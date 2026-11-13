import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/presentation/features/marketplace/market_routes.dart';
import 'package:staki_mobile/presentation/features/marketplace/providers/market_models.dart';
import 'package:staki_mobile/presentation/features/marketplace/providers/market_providers.dart';
import 'package:staki_mobile/presentation/features/marketplace/widgets/market_widgets.dart';
import 'package:staki_mobile/presentation/shared_widgets/shared_widgets.dart';

const _title = 'Opportunity Detail';

class OpportunityDetailPage extends ConsumerWidget {
  const OpportunityDetailPage({required this.opportunityId, super.key});

  final String opportunityId;

  Future<void> _allocate(
    BuildContext context,
    WidgetRef ref,
    Opportunity opportunity,
  ) async {
    final balance = await ref.read(balanceProvider.future);
    if (!context.mounted) return;
    final maxAmount = maxFundable(opportunity, balance);
    if (maxAmount <= 0) {
      showMarketMessage(
        context,
        'There is nothing available to allocate right now.',
      );
      return;
    }
    ref
        .read(fundingControllerProvider.notifier)
        .start(opportunity.id, maxAmount: maxAmount);
    unawaited(context.push(MarketRoutes.fund));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = ref.watch(opportunitiesProvider);
    final o = ref.watch(opportunityProvider(opportunityId));

    if (o == null) {
      return loading.hasError
          ? const MarketScaffold.failure(title: _title)
          : const MarketScaffold.loading(title: _title);
    }

    return MarketScaffold(
      title: _title,
      bottom: AppButton(
        label: o.isFullyFunded ? 'Fully funded' : 'Allocate Funds',
        showArrow: !o.isFullyFunded,
        onPressed: o.isFullyFunded
            ? null
            : () => unawaited(_allocate(context, ref, o)),
      ),
      children: [
        SectorLabel(o.sector),
        const SizedBox(height: 8),
        MarketHeading(o.title, size: 22),
        const SizedBox(height: 2),
        Text(
          o.id,
          style: const TextStyle(
            fontSize: 11,
            fontFamily: 'monospace',
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: StatTile(
                label: 'Requested Amount',
                value: moneyRwf(o.requested),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatTile(label: 'Term', value: '${o.termMonths} months'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatTile(
                label: 'Indicative Rate',
                value: o.rateLabel,
                valueColor: AppColors.success,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: StatTile(
                label: 'Repayment Structure',
                value: 'Monthly P+I',
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const MarketHeading('Credit Passport Score', size: 15),
        const SizedBox(height: 12),
        _ScoreCard(score: o.score),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _FactorRow(
                Icons.show_chart,
                'Cash-flow consistency',
                o.cashFlow,
              ),
              _FactorRow(
                Icons.bar_chart,
                'Affordability ratio',
                o.affordability,
              ),
              _FactorRow(
                Icons.check_circle,
                'Repayment history',
                o.repaymentHistory,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const MarketHeading('Verified Data Points', size: 15),
        const SizedBox(height: 8),
        for (final point in o.verifiedPoints)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 16,
                  color: AppColors.success,
                ),
                const SizedBox(width: 10),
                Text(
                  point,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'OVERALL SCORE',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 0.8,
                    color: AppColors.onPrimary.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$score',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.warning, width: 4),
            ),
          ),
        ],
      ),
    );
  }
}

class _FactorRow extends StatelessWidget {
  const _FactorRow(this.icon, this.label, this.rating);

  final IconData icon;
  final String label;
  final String rating;

  @override
  Widget build(BuildContext context) {
    final color = rating == 'Moderate' ? AppColors.primary : AppColors.success;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            rating,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
