import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/app_icons.dart';
import 'package:staki_mobile/presentation/features/marketplace/market_routes.dart';
import 'package:staki_mobile/presentation/features/marketplace/providers/market_models.dart';
import 'package:staki_mobile/presentation/features/marketplace/providers/market_providers.dart';

class FundSuccessPage extends ConsumerWidget {
  const FundSuccessPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receipt = ref.watch(fundingControllerProvider).receipt;
    final message = receipt == null
        ? 'Your allocation has been initiated through Bank of Kigali.'
        : 'Your ${moneyRwf(receipt.amount)} allocation has been initiated '
            'through Bank of Kigali.';

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.onPrimary.withValues(alpha: 0.1),
                        ),
                        child: const Icon(
                          AppIcons.shieldCheck,
                          size: 38,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Funding allocated',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.onPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: AppColors.onPrimary.withValues(alpha: 0.8),
                        ),
                      ),
                      if (receipt != null) ...[
                        const SizedBox(height: 24),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.onPrimary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              _Row('Reference ID', receipt.reference),
                              const SizedBox(height: 8),
                              _Row('Opportunity', receipt.opportunityId),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: FilledButton.icon(
                onPressed: () => context.go(MarketRoutes.portfolio),
                icon: const Icon(AppIcons.briefcase, size: 18),
                label: const Text(
                  'View Portfolio',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: AppColors.onPrimary,
                  foregroundColor: AppColors.primary,
                  shape: const StadiumBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.onPrimary.withValues(alpha: 0.7),
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontFamily: 'monospace',
            fontWeight: FontWeight.w700,
            color: AppColors.onPrimary,
          ),
        ),
      ],
    );
  }
}
