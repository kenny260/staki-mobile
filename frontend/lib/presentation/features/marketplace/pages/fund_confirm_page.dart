import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/presentation/features/marketplace/market_routes.dart';
import 'package:staki_mobile/presentation/features/marketplace/providers/market_models.dart';
import 'package:staki_mobile/presentation/features/marketplace/providers/market_providers.dart';
import 'package:staki_mobile/presentation/features/marketplace/widgets/market_widgets.dart';
import 'package:staki_mobile/presentation/shared_widgets/shared_widgets.dart';

class FundConfirmPage extends ConsumerStatefulWidget {
  const FundConfirmPage({super.key});

  @override
  ConsumerState<FundConfirmPage> createState() => _FundConfirmPageState();
}

class _FundConfirmPageState extends ConsumerState<FundConfirmPage> {
  final ValueNotifier<bool> _busy = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _busy.dispose();
    super.dispose();
  }

  /// CREATE the allocation.
  Future<void> _allocate() async {
    _busy.value = true;
    final receipt =
        await ref.read(fundingControllerProvider.notifier).allocate();
    if (!mounted) return;
    _busy.value = false;
    if (receipt == null) {
      showMarketMessage(
        context,
        "We couldn't allocate your funds. Please check the amount and try "
        'again.',
      );
      return;
    }
    context.go(MarketRoutes.success);
  }

  @override
  Widget build(BuildContext context) {
    final flow = ref.watch(fundingControllerProvider);

    return MarketScaffold(
      title: 'Confirm funding',
      bottom: ValueListenableBuilder<bool>(
        valueListenable: _busy,
        builder: (context, busy, _) => AppButton(
          label: 'Confirm & Allocate',
          isLoading: busy,
          // Disabled until the box is ticked.
          onPressed: flow.confirmed ? _allocate : null,
        ),
      ),
      children: [
        const MarketHeading('Final Confirmation', size: 22),
        const SizedBox(height: 6),
        Text.rich(
          TextSpan(
            text: 'Please confirm your funding allocation of ',
            children: [
              TextSpan(
                text: moneyRwf(flow.amount),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const TextSpan(text: '.'),
            ],
          ),
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.account_balance,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Regulated Settlement',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              MarketBody(
                'Your allocation is subject to the applicable regulated '
                'lending and settlement process via Bank of Kigali. Credit '
                'Passport provides the matching technology but does not '
                'lend or hold these funds.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AckRow(
          checked: flow.confirmed,
          text: 'I explicitly confirm this funding allocation and '
              'understand the associated risks and settlement process.',
          onTap: ref.read(fundingControllerProvider.notifier).toggleConfirmed,
        ),
      ],
    );
  }
}
