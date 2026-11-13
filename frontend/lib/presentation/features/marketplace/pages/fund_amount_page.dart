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

const _title = 'Fund this opportunity';

class FundAmountPage extends ConsumerWidget {
  const FundAmountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flow = ref.watch(fundingControllerProvider);
    final o = ref.watch(opportunityProvider(flow.opportunityId ?? ''));
    final balance = ref.watch(balanceProvider).valueOrNull ?? 0;
    if (o == null) return const MarketScaffold.loading(title: _title);

    final maxAmount = maxFundable(o, balance);
    final minAmount = minAllocationFor(maxAmount);
    final amount = clampInt(flow.amount, minAmount, maxAmount);
    final span = maxAmount - minAmount;

    return MarketScaffold(
      title: _title,
      bottom: AppButton(
        label: 'Review Funding',
        showArrow: true,
        onPressed: amount <= 0
            ? null
            : () => unawaited(context.push(MarketRoutes.review)),
      ),
      children: [
        const MarketHeading('Allocate Funds', size: 22),
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
                    child: LabelValue(
                      'REQUESTED AMOUNT',
                      moneyRwf(o.requested),
                    ),
                  ),
                  Expanded(
                    child: LabelValue('ALREADY FUNDED', moneyRwf(o.funded)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: LabelValue(
                      'REMAINING AMOUNT',
                      moneyRwf(o.remaining),
                      valueColor: AppColors.success,
                    ),
                  ),
                  Expanded(
                    child: LabelValue(
                      'AVAILABLE TO ALLOCATE',
                      moneyRwf(balance),
                      valueColor: AppColors.warningText,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const Center(
          child: Text(
            'How much would you like to fund?',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Container(
            padding: const EdgeInsets.only(bottom: 6, left: 12, right: 12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.warning, width: 2),
              ),
            ),
            child: Text(
              moneyRwf(amount),
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Slider(
          value: amount.toDouble(),
          min: minAmount.toDouble(),
          max: maxAmount.toDouble(),
          divisions: span >= allocationStep ? span ~/ allocationStep : null,
          activeColor: AppColors.warning,
          inactiveColor: AppColors.border,
          semanticFormatterCallback: (v) => moneyRwf(v.round()),
          onChanged: (v) =>
              ref.read(fundingControllerProvider.notifier).setAmount(v.round()),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              moneyRwf(minAmount),
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              moneyRwf(maxAmount),
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
