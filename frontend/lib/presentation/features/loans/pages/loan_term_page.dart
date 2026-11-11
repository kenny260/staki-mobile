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

class LoanTermPage extends ConsumerWidget {
  const LoanTermPage({super.key, this.editing = false});

  final bool editing;

  Future<void> _continue(BuildContext context, WidgetRef ref) async {
    final ok = await ref.read(loanFlowProvider.notifier).saveDraft();
    if (!context.mounted) return;
    if (!ok) {
      showLoanMessage(context, "We couldn't save your term. Please try again.");
      return;
    }
    if (editing) {
      context.pop();
    } else {
      unawaited(context.push(LoanRoutes.purpose));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(loanFlowProvider);
    final controller = ref.read(loanFlowProvider.notifier);
    final estimate = LoanEstimate(
      principal: draft.amount,
      termMonths: draft.termMonths,
    );

    Widget termCard(int months) {
      final monthly = LoanEstimate(
        principal: draft.amount,
        termMonths: months,
      ).monthly;
      return LoanOptionCard(
        selected: draft.termMonths == months,
        onTap: () => controller.setTerm(months),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$months months',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '~${formatRwf(monthly)} / mo',
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return LoanScaffold(
      title: 'Loan Application',
      subtitle: 'STEP 2 OF 4',
      bottom: AppButton(
        label: 'Continue',
        showArrow: true,
        onPressed: () => unawaited(_continue(context, ref)),
      ),
      children: [
        const LoanHeading('Choose repayment term'),
        const SizedBox(height: 6),
        Text(
          'Select how long you need to repay ${formatRwf(draft.amount)}.',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 20),
        for (var i = 0; i < termOptions.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(child: termCard(termOptions[i])),
                const SizedBox(width: 12),
                Expanded(child: termCard(termOptions[i + 1])),
              ],
            ),
          ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Loan Estimate',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              LoanSummaryRow(
                label: 'Principal amount',
                value: formatRwf(estimate.principal),
              ),
              LoanSummaryRow(
                label: 'Estimated interest (1.5%/mo)',
                value: formatRwf(estimate.interest),
              ),
              LoanSummaryRow(
                label: 'Origination fee (2%)',
                value: formatRwf(estimate.fee),
              ),
              const Divider(height: 20, color: AppColors.border),
              LoanSummaryRow(
                label: 'Total estimated repayment',
                value: formatRwf(estimate.total),
                bold: true,
              ),
              const SizedBox(height: 10),
              const LoanNote(
                blue: true,
                text: 'This is an estimate. Final terms are determined by the '
                    'lending partner and provided before you sign the '
                    'agreement.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
