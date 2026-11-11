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

class LoanReviewPage extends ConsumerStatefulWidget {
  const LoanReviewPage({super.key});

  @override
  ConsumerState<LoanReviewPage> createState() => _LoanReviewPageState();
}

class _LoanReviewPageState extends ConsumerState<LoanReviewPage> {
  // Local UI flag only (shows the button spinner). App state is in Riverpod.
  bool _submitting = false;

  Future<void> _submit() async {
    setState(() => _submitting = true);
    final application = await ref.read(loanFlowProvider.notifier).submit();
    if (!mounted) return;
    setState(() => _submitting = false);
    if (application == null) {
      showLoanMessage(
        context,
        "We couldn't submit your application. Please check your details "
        'and try again.',
      );
      return;
    }
    context.go(LoanRoutes.submitted);
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(loanFlowProvider);
    final partner =
        ref.watch(eligibilityProvider).valueOrNull?.offer?.partner ??
            'Bank of Kigali';
    final estimate = LoanEstimate(
      principal: draft.amount,
      termMonths: draft.termMonths,
    );

    return LoanScaffold(
      title: 'Review Application',
      subtitle: 'STEP 4 OF 4',
      bottom: AppButton(
        label: 'Submit application',
        showArrow: true,
        isLoading: _submitting,
        onPressed: () => unawaited(_submit()),
      ),
      children: [
        const LoanHeading('Review details'),
        const SizedBox(height: 16),
        _ReviewCard(
          title: 'Loan Request',
          editTarget: '${LoanRoutes.amount}?edit=1',
          children: [
            _Field('Amount', formatRwf(draft.amount)),
            _Field('Purpose', draft.purpose?.label ?? 'Not chosen yet'),
            _Field('Lending partner', partner),
          ],
        ),
        const SizedBox(height: 14),
        _ReviewCard(
          title: 'Repayment Estimate',
          editTarget: '${LoanRoutes.term}?edit=1',
          children: [
            LoanSummaryRow(label: 'Term', value: '${draft.termMonths} months'),
            LoanSummaryRow(
              label: 'Monthly repayment',
              value: formatRwf(estimate.monthly),
            ),
            const Divider(height: 18, color: AppColors.border),
            LoanSummaryRow(
              label: 'Total estimated cost',
              value: formatRwf(estimate.total),
              bold: true,
            ),
          ],
        ),
        const SizedBox(height: 16),
        const LoanNote(
          text: 'Submitting this application allows the lending partner to '
              'review your Credit Passport.',
          boldTail: 'Approval is not guaranteed.',
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.title,
    required this.editTarget,
    required this.children,
  });

  final String title;
  final String editTarget;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Edit $title',
                visualDensity: VisualDensity.compact,
                icon: const Icon(
                  Icons.edit,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                onPressed: () => unawaited(context.push(editTarget)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ...children,
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
