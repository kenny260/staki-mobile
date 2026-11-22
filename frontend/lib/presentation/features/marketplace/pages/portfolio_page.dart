import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/app_icons.dart';
import 'package:staki_mobile/presentation/features/marketplace/market_routes.dart';
import 'package:staki_mobile/presentation/features/marketplace/providers/market_models.dart';
import 'package:staki_mobile/presentation/features/marketplace/providers/market_providers.dart';
import 'package:staki_mobile/presentation/features/marketplace/widgets/market_widgets.dart';

const _title = 'Portfolio';

class PortfolioPage extends ConsumerWidget {
  const PortfolioPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolio = ref.watch(portfolioProvider);
    final unread = ref.watch(hasUnreadProvider);

    return portfolio.when(
      loading: () => const MarketScaffold.loading(title: _title),
      error: (_, __) => const MarketScaffold.failure(title: _title),
      data: (data) => MarketScaffold(
        title: _title,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(AppIcons.user, color: AppColors.textMuted),
            IconButton(
              tooltip: 'Notifications',
              onPressed: () =>
                  unawaited(context.push(MarketRoutes.notifications)),
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(
                    AppIcons.bell,
                    color: AppColors.textMuted,
                  ),
                  if (unread)
                    const Positioned(
                      right: 0,
                      top: 0,
                      child: Icon(
                        AppIcons.circle,
                        size: 9,
                        color: AppColors.danger,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        children: [
          const MarketHeading('Overview', size: 22),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _Tile(
                  label: 'TOTAL ALLOCATED',
                  value: moneyRwf(data.totalAllocated),
                  background: AppColors.primary,
                  labelColor: AppColors.onPrimary.withValues(alpha: 0.7),
                  valueColor: AppColors.onPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Tile(
                  label: 'ACTIVE FUNDING',
                  value: moneyRwf(data.activeFunding),
                  background: AppColors.primarySoft,
                  labelColor: AppColors.primary,
                  valueColor: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _Tile(
                  label: 'REPAID (PRINCIPAL)',
                  value: moneyRwf(data.repaidPrincipal),
                  background: AppColors.successBg,
                  labelColor: AppColors.successText,
                  valueColor: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Tile(
                  label: 'PENDING REPAYMENTS',
                  value: moneyRwf(data.pendingRepayments),
                  background: AppColors.surface,
                  labelColor: AppColors.textSecondary,
                  valueColor: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              const Expanded(
                child: MarketHeading('Active Allocations', size: 14),
              ),
              TextButton(
                onPressed: () => unawaited(context.push(MarketRoutes.ledger)),
                child: const Text(
                  'VIEW LEDGER',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          for (final a in data.allocations)
            _AllocationCard(
              allocation: a,
              onTap: () =>
                  unawaited(context.push(MarketRoutes.allocation(a.id))),
            ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.label,
    required this.value,
    required this.background,
    required this.labelColor,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color background;
  final Color labelColor;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: labelColor,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _AllocationCard extends StatelessWidget {
  const _AllocationCard({required this.allocation, required this.onTap});

  final Allocation allocation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final a = allocation;
    final late = a.status == AllocationStatus.late;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surfaceAlt,
                    ),
                    child: const Icon(
                      AppIcons.buildings,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a.sector,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          a.opportunityId,
                          style: const TextStyle(
                            fontSize: 10,
                            fontFamily: 'monospace',
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: late ? AppColors.primarySoft : AppColors.successBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      late ? 'LATE' : 'PERFORMING',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color:
                            late ? AppColors.dangerText : AppColors.successText,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 26, color: AppColors.border),
              Row(
                children: [
                  Expanded(
                    child: LabelValue('Amount allocated', moneyRwf(a.amount)),
                  ),
                  Expanded(
                    child: LabelValue('Outstanding', moneyRwf(a.outstanding)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: LabelValue(
                      'Next repayment',
                      dateLabel(a.nextRepayment),
                    ),
                  ),
                  Expanded(child: _StatusCell(allocation: a)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusCell extends StatelessWidget {
  const _StatusCell({required this.allocation});

  final Allocation allocation;

  @override
  Widget build(BuildContext context) {
    final late = allocation.status == AllocationStatus.late;
    final color = late ? AppColors.danger : AppColors.success;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status',
          style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 3),
        Row(
          children: [
            Icon(
              late ? AppIcons.warning : AppIcons.checkCircle,
              size: 12,
              color: color,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                late ? '${allocation.daysLate} days late' : 'On time',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
