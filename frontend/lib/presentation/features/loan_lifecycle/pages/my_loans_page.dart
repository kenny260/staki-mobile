import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/constants/spacing.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/app_icons.dart';
import 'package:staki_mobile/core/theme/text_styles.dart';
import 'package:staki_mobile/presentation/features/home/widgets/home_widgets.dart';
import 'package:staki_mobile/presentation/features/loan_lifecycle/lifecycle_routes.dart';
import 'package:staki_mobile/presentation/features/loan_lifecycle/providers/lifecycle_models.dart';
import 'package:staki_mobile/presentation/features/loan_lifecycle/providers/lifecycle_providers.dart';
import 'package:staki_mobile/presentation/features/loans/loan_routes.dart';
import 'package:staki_mobile/presentation/shared_widgets/shared_widgets.dart';

/// Borrower Loans tab: the current loan, or a way to apply for one.
class MyLoansPage extends ConsumerWidget {
  const MyLoansPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loan = ref.watch(loanAccountProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(title: 'My Loans'),
            const Divider(height: 1, color: AppColors.border),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => ref.invalidate(loanAccountProvider),
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.screenPadding),
                  children: loan.when(
                    loading: () => const [
                      SizedBox(height: 160),
                      Center(child: CircularProgressIndicator()),
                    ],
                    error: (_, __) => [_NoLoan(onApply: () => _apply(context))],
                    data: (l) => [
                      _LoanSummary(loan: l),
                      const SizedBox(height: AppSpacing.lg),
                      AppButton(
                        label: 'View loan details',
                        onPressed: () =>
                            unawaited(context.push(LifecycleRoutes.base)),
                      ),
                      if (l.stage == LoanStage.active ||
                          l.stage == LoanStage.repaymentDue) ...[
                        const SizedBox(height: AppSpacing.s3),
                        AppOutlinedButton(
                          label: 'Make a repayment',
                          onPressed: () => unawaited(
                            context.push(LifecycleRoutes.repay),
                          ),
                        ),
                      ],
                      if (l.stage == LoanStage.declined ||
                          l.stage == LoanStage.fullyRepaid) ...[
                        const SizedBox(height: AppSpacing.s3),
                        AppOutlinedButton(
                          label: 'Apply for a new loan',
                          onPressed: () => _apply(context),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _apply(BuildContext context) => unawaited(context.push(LoanRoutes.base));
}

class _NoLoan extends StatelessWidget {
  const _NoLoan({required this.onApply});

  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.s12),
        const Icon(AppIcons.money, size: 48, color: AppColors.textMuted),
        const SizedBox(height: AppSpacing.md),
        Text(
          'No loan yet',
          style: AppTextStyles.title.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Apply in a few steps. Your Credit Passport decides which offers '
          'you can choose from.',
          textAlign: TextAlign.center,
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppButton(label: 'Apply for a loan', onPressed: onApply),
      ],
    );
  }
}

class _LoanSummary extends StatelessWidget {
  const _LoanSummary({required this.loan});

  final LoanAccount loan;

  @override
  Widget build(BuildContext context) {
    final due = loan.nextDueDate;
    return HomeCard(
      icon: AppIcons.money,
      title: loan.partner,
      headline: formatMoney(loan.approvedAmount),
      detail: [
        loanStageLabel(loan.stage),
        if (loan.monthlyPayment > 0)
          '${formatMoney(loan.monthlyPayment)} a month',
        if (due != null) 'next due ${shortDate(due)}',
      ].join(' · '),
    );
  }
}
