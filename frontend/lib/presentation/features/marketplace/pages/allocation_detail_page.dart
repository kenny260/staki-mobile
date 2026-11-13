import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/presentation/features/marketplace/market_routes.dart';
import 'package:staki_mobile/presentation/features/marketplace/providers/market_models.dart';
import 'package:staki_mobile/presentation/features/marketplace/providers/market_providers.dart';
import 'package:staki_mobile/presentation/features/marketplace/widgets/market_widgets.dart';

const _title = 'Allocation Detail';

class AllocationDetailPage extends ConsumerWidget {
  const AllocationDetailPage({required this.allocationId, super.key});

  final String allocationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolio = ref.watch(portfolioProvider);
    final a = ref.watch(allocationProvider(allocationId));

    if (a == null) {
      return portfolio.hasError
          ? const MarketScaffold.failure(
              title: _title,
              backTo: MarketRoutes.portfolio,
            )
          : const MarketScaffold.loading(
              title: _title,
              backTo: MarketRoutes.portfolio,
            );
    }

    final late = a.status == AllocationStatus.late;
    final statusColor = late ? AppColors.danger : AppColors.success;

    return MarketScaffold(
      title: _title,
      backTo: MarketRoutes.portfolio,
      children: [
        SectorLabel(a.sector),
        const SizedBox(height: 6),
        MarketHeading(a.opportunityId, size: 24),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              late ? Icons.warning_amber_rounded : Icons.check_circle,
              size: 14,
              color: statusColor,
            ),
            const SizedBox(width: 6),
            Text(
              late ? 'Late (${a.daysLate} days)' : 'Performing',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: statusColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: LabelValue('FUNDING AMOUNT', moneyRwf(a.amount)),
                  ),
                  Expanded(
                    child: LabelValue(
                      'OUTSTANDING BALANCE',
                      moneyRwf(a.outstanding),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: LabelValue(
                      'DISBURSEMENT DATE',
                      dateLabel(a.disbursedOn),
                    ),
                  ),
                  Expanded(
                    child: LabelValue('REPAYMENT SCHEDULE', a.schedule),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const MarketHeading('Repayment Progress', size: 15),
        const SizedBox(height: 10),
        FundingBar(fraction: a.progress, color: AppColors.success),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${moneyRwf(a.received)} received',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '${moneyRwf(a.amount)} principal',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const MarketHeading('Activity History', size: 15),
        const SizedBox(height: 8),
        for (final entry in a.history) LedgerRow(entry: entry),
      ],
    );
  }
}
