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

const _title = 'Loan Details';

class LoanDetailsPage extends ConsumerWidget {
  const LoanDetailsPage({super.key});

  Future<void> _sign(BuildContext context, WidgetRef ref) async {
    final ok = await ref.read(loanAccountProvider.notifier).acceptAgreement();
    if (!context.mounted || ok) return;
    showLifecycleMessage(
      context,
      "We couldn't sign the agreement. Please try again.",
    );
  }

  Future<void> _openDashboard(BuildContext context, WidgetRef ref) async {
    final ok =
        await ref.read(loanAccountProvider.notifier).acknowledgeDisbursed();
    if (!context.mounted || ok) return;
    showLifecycleMessage(context, "We couldn't open your loan. Please retry.");
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loan = ref.watch(loanAccountProvider);

    return loan.when(
      loading: () => const LifecycleScaffold(
        title: _title,
        children: [
          SizedBox(height: 160),
          Center(child: CircularProgressIndicator()),
        ],
      ),
      error: (_, __) => const LifecycleScaffold(
        title: _title,
        children: [
          Text('We could not load your loan. Please try again.'),
        ],
      ),
      data: (account) => switch (account.stage) {
        LoanStage.submitted => _message(
            AppIcons.clock,
            AppColors.info,
            'Application submitted',
            '${account.partner} is reviewing your loan application and '
                'Credit Passport. We will notify you once a decision is made.',
          ),
        LoanStage.underReview => _message(
            AppIcons.clock,
            AppColors.info,
            'Application under review',
            '${account.partner} is reviewing your loan application and '
                'Credit Passport. We will notify you once a decision is made.',
          ),
        LoanStage.approved => _ApprovedView(
            account: account,
            onSign: () => unawaited(_sign(context, ref)),
          ),
        LoanStage.disbursementPending => _message(
            AppIcons.downloadSimple,
            AppColors.info,
            'Disbursement in progress',
            'Your approved funds are being sent through the regulated '
                'lending partner directly to your connected MTN MoMo '
                'account.',
          ),
        LoanStage.disbursed => _message(
            AppIcons.checkCircle,
            AppColors.success,
            'Funds Disbursed',
            '${account.partner} has successfully deposited the funds to '
                'your account.',
            action: AppButton(
              label: 'View Loan Dashboard',
              onPressed: () => unawaited(_openDashboard(context, ref)),
            ),
          ),
        LoanStage.declined => _message(
            AppIcons.warningCircle,
            AppColors.danger,
            'Application declined',
            '${account.partner} was unable to approve this specific loan '
                'request at this time based on their internal eligibility '
                'criteria.',
            action: OutlinedButton(
              onPressed: () => context.go('/loans'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: const StadiumBorder(),
                backgroundColor: AppColors.surfaceAlt,
                side: BorderSide.none,
                foregroundColor: AppColors.primary,
              ),
              child: const Text(
                'Explore other options',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        LoanStage.active ||
        LoanStage.repaymentDue ||
        LoanStage.fullyRepaid =>
          LifecycleScaffold(
            title: _title,
            children: [
              _Dashboard(
                account: account,
                onRepay: () => unawaited(context.push(LifecycleRoutes.repay)),
                onDownload: () => showLifecycleMessage(
                  context,
                  'The loan agreement will be available to download soon.',
                ),
              ),
            ],
          ),
      },
    );
  }

  Widget _message(
    IconData icon,
    Color color,
    String title,
    String body, {
    Widget? action,
  }) {
    return LifecycleScaffold(
      title: _title,
      children: [
        StatusMessage(
          icon: icon,
          color: color,
          title: title,
          body: body,
          action: action,
        ),
      ],
    );
  }
}

// ---------- L07c ----------
class _ApprovedView extends StatelessWidget {
  const _ApprovedView({required this.account, required this.onSign});

  final LoanAccount account;
  final VoidCallback onSign;

  @override
  Widget build(BuildContext context) {
    return LifecycleScaffold(
      title: _title,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.successBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(AppIcons.check, color: AppColors.success),
        ),
        const SizedBox(height: 16),
        const Text(
          'Your funding is approved',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${account.partner} has approved your request based on your '
          'Credit Passport profile.',
          style: const TextStyle(
            fontSize: 12,
            height: 1.4,
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
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(
                    AppIcons.bank,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    account.partner,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24, color: AppColors.border),
              SummaryRow(
                label: 'Approved amount',
                value: formatMoney(account.approvedAmount),
              ),
              SummaryRow(
                label: 'Term',
                value: '${account.termMonths} months',
              ),
              SummaryRow(label: 'Interest rate', value: account.interestLabel),
              SummaryRow(
                label: 'Monthly payment',
                value: formatMoney(account.monthlyPayment),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        AppButton(label: 'Accept & Sign Agreement', onPressed: onSign),
      ],
    );
  }
}

// ---------- L07_LoanActive, L07f, L07g ----------
class _Dashboard extends StatelessWidget {
  const _Dashboard({
    required this.account,
    required this.onRepay,
    required this.onDownload,
  });

  final LoanAccount account;
  final VoidCallback onRepay;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final due = account.stage == LoanStage.repaymentDue;
    final repaid = account.stage == LoanStage.fullyRepaid;
    final dueDate = account.nextDueDate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'OUTSTANDING BALANCE',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 0.8,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatMoney(account.outstanding),
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            _StagePill(stage: account.stage),
          ],
        ),
        const SizedBox(height: 16),
        if (repaid)
          const _RepaidBox()
        else
          _NextPaymentCard(
            amount: account.nextPaymentAmount,
            dueDate: dueDate,
            due: due,
            onRepay: onRepay,
          ),
        const SizedBox(height: 24),
        const SectionTitle('Repayment Progress'),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: account.progress,
            minHeight: 8,
            backgroundColor: AppColors.surfaceAlt,
            color: AppColors.success,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${formatMoney(account.paidAmount)} paid',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '${formatMoney(account.totalRepayable)} total',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const SectionTitle('Payment History'),
        const SizedBox(height: 6),
        if (account.payments.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'No payments yet.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
        for (final payment in account.payments) _PaymentRow(payment: payment),
        const SizedBox(height: 20),
        const SectionTitle('Documents'),
        const SizedBox(height: 10),
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onDownload,
          child: Ink(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: const Row(
              children: [
                Icon(AppIcons.fileText, size: 18, color: AppColors.textMuted),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Loan Agreement',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  AppIcons.downloadSimple,
                  size: 18,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StagePill extends StatelessWidget {
  const _StagePill({required this.stage});

  final LoanStage stage;

  @override
  Widget build(BuildContext context) {
    final (label, background, color) = switch (stage) {
      LoanStage.repaymentDue => (
          'DUE',
          AppColors.warningBg,
          AppColors.warningText,
        ),
      LoanStage.fullyRepaid => (
          'FULLY REPAID',
          AppColors.successBg,
          AppColors.successText,
        ),
      _ => ('ACTIVE', AppColors.infoBg, AppColors.info),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

class _NextPaymentCard extends StatelessWidget {
  const _NextPaymentCard({
    required this.amount,
    required this.dueDate,
    required this.due,
    required this.onRepay,
  });

  final int amount;
  final DateTime? dueDate;
  final bool due;
  final VoidCallback onRepay;

  @override
  Widget build(BuildContext context) {
    final accent = due ? AppColors.warningText : AppColors.primary;
    final date = dueDate;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: due ? AppColors.warningBg : AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: due ? AppColors.warning : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Next Payment',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
              ),
              if (date != null)
                Text(
                  'Due ${shortDate(date)}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color:
                        due ? AppColors.warningText : AppColors.textSecondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            formatMoney(amount),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: onRepay,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: due ? AppColors.warning : AppColors.primary,
              foregroundColor:
                  due ? AppColors.textPrimary : AppColors.onPrimary,
              shape: const StadiumBorder(),
            ),
            child: const Text(
              'Make repayment',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _RepaidBox extends StatelessWidget {
  const _RepaidBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.successBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
      ),
      child: const Column(
        children: [
          Icon(AppIcons.checkCircle, color: AppColors.success, size: 28),
          SizedBox(height: 8),
          Text(
            'Loan fully repaid',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.successText,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Thank you! Your excellent repayment behavior has positively '
            'impacted your Credit Passport score.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              height: 1.4,
              color: AppColors.successText,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.payment});

  final Payment payment;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.successBg,
            ),
            child: const Icon(
              AppIcons.arrowUpRight,
              size: 16,
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Payment',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  fullDate(payment.date),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            formatMoney(payment.amount),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
