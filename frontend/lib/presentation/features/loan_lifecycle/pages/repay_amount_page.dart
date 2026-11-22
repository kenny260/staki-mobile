import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/app_icons.dart';
import 'package:staki_mobile/presentation/features/loan_lifecycle/lifecycle_routes.dart';
import 'package:staki_mobile/presentation/features/loan_lifecycle/providers/lifecycle_models.dart';
import 'package:staki_mobile/presentation/features/loan_lifecycle/providers/lifecycle_providers.dart';
import 'package:staki_mobile/presentation/features/loan_lifecycle/widgets/lifecycle_widgets.dart';
import 'package:staki_mobile/presentation/shared_widgets/shared_widgets.dart';

class RepayAmountPage extends ConsumerWidget {
  const RepayAmountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(loanAccountProvider).valueOrNull;
    final method = ref.watch(selectedMethodProvider);
    final amount = account?.nextPaymentAmount ?? 0;
    final controller = ref.read(selectedMethodProvider.notifier);

    return LifecycleScaffold(
      title: 'Make Repayment',
      bottom: AppButton(
        label: 'Continue',
        // Nothing to pay if the loan is already settled.
        onPressed: amount <= 0
            ? null
            : () => unawaited(context.push(LifecycleRoutes.confirm)),
      ),
      children: [
        const Text(
          'Payment Details',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Amount to pay',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                formatMoney(amount),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const SectionTitle('Payment Method'),
        const SizedBox(height: 12),
        MethodCard(
          icon: AppIcons.deviceMobile,
          iconColor: AppColors.warning,
          title: 'MTN MoMo',
          subtitle: '078 ••• ••67',
          selected: method == PayMethod.momo,
          onTap: () => controller.state = PayMethod.momo,
        ),
        const SizedBox(height: 12),
        MethodCard(
          icon: AppIcons.bank,
          iconColor: AppColors.info,
          title: 'Bank Transfer',
          subtitle: 'Transfer from bank app',
          selected: method == PayMethod.bank,
          onTap: () => controller.state = PayMethod.bank,
        ),
      ],
    );
  }
}
