import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/presentation/features/loan_lifecycle/lifecycle_routes.dart';
import 'package:staki_mobile/presentation/features/loan_lifecycle/providers/lifecycle_models.dart';
import 'package:staki_mobile/presentation/features/loan_lifecycle/providers/lifecycle_providers.dart';
import 'package:staki_mobile/presentation/features/loan_lifecycle/widgets/lifecycle_widgets.dart';
import 'package:staki_mobile/presentation/shared_widgets/shared_widgets.dart';

class RepayConfirmPage extends ConsumerStatefulWidget {
  const RepayConfirmPage({super.key});

  @override
  ConsumerState<RepayConfirmPage> createState() => _RepayConfirmPageState();
}

class _RepayConfirmPageState extends ConsumerState<RepayConfirmPage> {
  final ValueNotifier<bool> _busy = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _busy.dispose();
    super.dispose();
  }

  /// CREATE the repayment and UPDATE the loan balance.
  Future<void> _pay() async {
    _busy.value = true;
    final method = ref.read(selectedMethodProvider);
    final receipt = await ref.read(loanAccountProvider.notifier).repay(method);
    if (!mounted) return;
    _busy.value = false;
    if (receipt == null) {
      showLifecycleMessage(
        context,
        "We couldn't process your payment. Please try again.",
      );
      return;
    }
    context.go(LifecycleRoutes.success);
  }

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(loanAccountProvider).valueOrNull;
    final method = ref.watch(selectedMethodProvider);
    final amount = account?.nextPaymentAmount ?? 0;

    return LifecycleScaffold(
      title: 'Confirm',
      bottom: ValueListenableBuilder<bool>(
        valueListenable: _busy,
        builder: (context, busy, _) => AppButton(
          label: 'Confirm & Pay',
          isLoading: busy,
          onPressed: amount <= 0 ? null : _pay,
        ),
      ),
      children: [
        const Text(
          'Confirm Payment',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              SummaryRow(
                label: 'Recipient',
                value: account?.partner ?? '',
              ),
              SummaryRow(label: 'Method', value: methodLabel(method)),
              const Divider(height: 24, color: AppColors.border),
              SummaryRow(
                label: 'Total Amount',
                value: formatMoney(amount),
                bold: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'By confirming, a push prompt will be sent to your phone to '
          'authorize the transaction. Staki fund does not hold or process '
          'these funds.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            height: 1.5,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
