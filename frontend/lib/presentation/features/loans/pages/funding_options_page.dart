import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/router/app_routes.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/app_icons.dart';
import 'package:staki_mobile/presentation/features/loans/loan_routes.dart';
import 'package:staki_mobile/presentation/features/loans/providers/loan_models.dart';
import 'package:staki_mobile/presentation/features/loans/providers/loan_providers.dart';
import 'package:staki_mobile/presentation/features/loans/widgets/loan_widgets.dart';
import 'package:staki_mobile/presentation/shared_widgets/shared_widgets.dart';

const _title = 'Funding Options';

class FundingOptionsPage extends ConsumerWidget {
  const FundingOptionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eligibility = ref.watch(eligibilityProvider);

    return eligibility.when(
      loading: () => const LoanScaffold(
        title: _title,
        children: [
          SizedBox(height: 160),
          Center(child: CircularProgressIndicator()),
        ],
      ),
      error: (_, __) => const LoanScaffold(
        title: _title,
        children: [
          LoanBody('We could not load your funding options. Please try again.'),
        ],
      ),
      data: (result) {
        final offer = result.offer;
        switch (result.status) {
          case EligibilityStatus.eligible:
          case EligibilityStatus.partiallyEligible:
            if (offer == null) return const _NotEligibleView();
            return _OfferView(offer: offer);
          case EligibilityStatus.notEligible:
            return const _NotEligibleView();
          case EligibilityStatus.underReview:
            return const _UnderReviewView();
        }
      },
    );
  }
}

// ---------- L01 / L01b ----------
class _OfferView extends ConsumerWidget {
  const _OfferView({required this.offer});

  final LoanOffer offer;

  Future<void> _viewOffer(BuildContext context, WidgetRef ref) async {
    await ref.read(loanFlowProvider.notifier).start(maxAmount: offer.maxAmount);
    if (!context.mounted) return;
    unawaited(context.push(LoanRoutes.amount));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LoanScaffold(
      title: _title,
      bottom: AppButton(
        label: 'View offer',
        showArrow: true,
        onPressed: () => unawaited(_viewOffer(context, ref)),
      ),
      children: [
        const LoanHeading('Funding available to you', size: 22),
        const SizedBox(height: 8),
        const LoanBody(
          'Based on your Credit Passport, you have been matched with the '
          'following estimated offers.',
        ),
        const SizedBox(height: 20),
        _OfferCard(offer: offer),
        const SizedBox(height: 20),
        const LoanNote(
          text: 'Your Credit Passport Score is one factor in lending '
              'decisions. Final terms, amounts, and approvals are provided '
              'directly by the lending partner.',
        ),
      ],
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({required this.offer});

  final LoanOffer offer;

  @override
  Widget build(BuildContext context) {
    final pending = offer.pendingVerification;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(height: 4, color: AppColors.success),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            pending ? AppIcons.info : AppIcons.checkCircle,
                            size: 12,
                            color:
                                pending ? AppColors.primary : AppColors.success,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            pending ? 'PENDING VERIFICATION' : 'PRE-QUALIFIED',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    const _BankBadge(),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'ESTIMATED OFFER',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Up to ${formatRwf(offer.maxAmount)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            color: AppColors.surface,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _Detail('Term', '${offer.termMonths} months'),
                    ),
                    Expanded(
                      child: _Detail(
                        'Estimated repayment',
                        '${formatRwf(offer.monthlyRepayment)} / mo',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _Detail('Interest / Fees', offer.interestLabel),
                    ),
                    Expanded(child: _Detail('Lending partner', offer.partner)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _BankBadge extends StatelessWidget {
  const _BankBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        color: AppColors.surfaceAlt,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        AppIcons.bank,
        size: 18,
        color: AppColors.primary,
      ),
    );
  }
}

// ---------- L01c ----------
class _NotEligibleView extends StatelessWidget {
  const _NotEligibleView();

  @override
  Widget build(BuildContext context) {
    return LoanScaffold(
      title: _title,
      bottom: OutlinedButton(
        // TODO(chris): point at the dashboard once that screen exists.
        onPressed: () => context.go(AppRoutes.creditPassport),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: const StadiumBorder(),
          backgroundColor: AppColors.surfaceAlt,
          side: BorderSide.none,
          foregroundColor: AppColors.primary,
        ),
        child: const Text(
          'Return to Dashboard',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      children: const [
        _Badge(icon: AppIcons.shieldCheck, color: AppColors.info),
        SizedBox(height: 20),
        LoanHeading('No matching offers right now'),
        SizedBox(height: 10),
        LoanBody(
          'We regularly check your Credit Passport against lending criteria. '
          'Currently, partners are looking for a longer history of '
          'consistent transaction activity for this loan tier.',
        ),
        SizedBox(height: 24),
        LoanHeading('How to improve your eligibility', size: 14),
        SizedBox(height: 12),
        _TipCard(
          icon: AppIcons.trendUp,
          color: AppColors.success,
          title: 'Keep your connections active',
          text: 'Leave your MTN MoMo and Bank accounts connected. More '
              'history leads to better matches.',
        ),
        SizedBox(height: 10),
        _TipCard(
          icon: AppIcons.checkCircle,
          color: AppColors.primary,
          title: 'Pay utility bills on time',
          text: 'Consistent digital payments strengthen your affordability '
              'and repayment profile.',
        ),
        SizedBox(height: 20),
        LoanNote(
          text: "Eligibility is determined by individual lenders' policies, "
              'not solely by your Credit Passport score. We will notify you '
              'when new offers become available.',
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(icon, color: color, size: 30),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- L01d ----------
class _UnderReviewView extends ConsumerWidget {
  const _UnderReviewView();

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    // Captured first: this view is rebuilt after the cancel completes.
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel application?'),
        content: const Text(
          'Your application will be withdrawn. You can apply again later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep it'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Cancel application'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final ok = await ref.read(loanFlowProvider.notifier).cancelApplication();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Application cancelled.'
              : "We couldn't cancel it. Please try again.",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final application = ref.watch(applicationProvider).valueOrNull;

    return LoanScaffold(
      title: _title,
      bottom: application == null
          ? null
          : OutlinedButton(
              onPressed: () => unawaited(_cancel(context, ref)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: const StadiumBorder(),
                side: const BorderSide(color: AppColors.border),
                foregroundColor: AppColors.primary,
              ),
              child: const Text(
                'Cancel Application',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
      children: [
        const SizedBox(height: 24),
        const Center(
          child: _Badge(icon: AppIcons.clock, color: AppColors.warning),
        ),
        const SizedBox(height: 20),
        const Center(child: LoanHeading('Application under review')),
        const SizedBox(height: 10),
        const Center(
          child: Text(
            'The lending partner is reviewing your Credit Passport and '
            'application details.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (application != null) _ApplicationCard(application: application),
      ],
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({required this.application});

  final LoanApplication application;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const _BankBadge(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.partner,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const Text(
                      'Business Loan',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warningBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'PENDING',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.warningText,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 28, color: AppColors.border),
          LoanSummaryRow(
            label: 'Requested amount',
            value: formatRwf(application.amount),
          ),
          LoanSummaryRow(
            label: 'Submitted on',
            value: formatDate(application.submittedOn),
          ),
        ],
      ),
    );
  }
}
