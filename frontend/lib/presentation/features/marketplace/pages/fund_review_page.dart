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

const _title = 'Review funding';

class FundReviewPage extends ConsumerWidget {
  const FundReviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flow = ref.watch(fundingControllerProvider);
    final o = ref.watch(opportunityProvider(flow.opportunityId ?? ''));
    final balance = ref.watch(balanceProvider).valueOrNull ?? 0;
    if (o == null) return const MarketScaffold.loading(title: _title);

    return MarketScaffold(
      title: _title,
      bottom: AppButton(
        label: 'Continue to Confirm',
        showArrow: true,
        onPressed: () => unawaited(context.push(MarketRoutes.confirm)),
      ),
      children: [
        const MarketHeading('Review allocation', size: 22),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MarketHeading('Funding Details', size: 13),
              const SizedBox(height: 4),
              DetailRow('Funding amount', moneyRwf(flow.amount), bold: true),
              const Divider(height: 1, color: AppColors.border),
              DetailRow('Term', '${o.termMonths} months'),
              DetailRow('Expected repayment structure', o.repaymentStructure),
              DetailRow(
                'Applicable fees',
                moneyRwf(allocationFee(flow.amount)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.infoBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Available balance after allocation',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Text(
                moneyRwf(balance - flow.amount),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.warningText,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.warningBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: AppColors.warningText,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Risk Disclosure',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.warningText,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'Returns are not guaranteed. Past performance of similar '
                'Credit Passport scores does not guarantee future repayment. '
                'Staki fund does not underwrite this loan or guarantee your '
                'principal.',
                style: TextStyle(
                  fontSize: 11,
                  height: 1.5,
                  color: AppColors.warningText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
