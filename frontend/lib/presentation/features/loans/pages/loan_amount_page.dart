import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/presentation/features/loans/loan_routes.dart';
import 'package:staki_mobile/presentation/features/loans/providers/loan_models.dart';
import 'package:staki_mobile/presentation/features/loans/providers/loan_providers.dart';
import 'package:staki_mobile/presentation/features/loans/widgets/loan_widgets.dart';
import 'package:staki_mobile/presentation/shared_widgets/shared_widgets.dart';

class LoanAmountPage extends ConsumerWidget {
  const LoanAmountPage({super.key, this.editing = false});

  /// True when opened from the pencil icon on the review screen.
  final bool editing;

  Future<void> _continue(BuildContext context, WidgetRef ref) async {
    final ok = await ref.read(loanFlowProvider.notifier).saveDraft();
    if (!context.mounted) return;
    if (!ok) {
      showLoanMessage(
        context,
        "We couldn't save your amount. Please try again.",
      );
      return;
    }
    if (editing) {
      context.pop();
    } else {
      unawaited(context.push(LoanRoutes.term));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(loanFlowProvider);
    final maxAmount =
        ref.watch(eligibilityProvider).valueOrNull?.offer?.maxAmount ?? 1200000;
    final divisions = (maxAmount - minLoanAmount) ~/ amountStep;

    return LoanScaffold(
      title: 'Loan Application',
      subtitle: 'STEP 1 OF 4',
      bottom: AppButton(
        label: 'Continue',
        showArrow: true,
        onPressed: () => unawaited(_continue(context, ref)),
      ),
      children: [
        const LoanHeading('How much do you need?'),
        const SizedBox(height: 6),
        Text(
          'You are pre-qualified for up to ${formatRwf(maxAmount)}.',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 32),
        Center(
          child: Container(
            padding: const EdgeInsets.only(bottom: 6, left: 12, right: 12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
            child: Text(
              formatRwf(draft.amount),
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Slider(
          value: draft.amount.clamp(minLoanAmount, maxAmount).toDouble(),
          min: minLoanAmount.toDouble(),
          max: maxAmount.toDouble(),
          divisions: divisions,
          activeColor: AppColors.primary,
          inactiveColor: AppColors.border,
          semanticFormatterCallback: (v) => formatRwf(v.round()),
          onChanged: (v) => ref
              .read(loanFlowProvider.notifier)
              .setAmount((v / amountStep).round() * amountStep),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              formatRwf(minLoanAmount),
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              formatRwf(maxAmount),
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
