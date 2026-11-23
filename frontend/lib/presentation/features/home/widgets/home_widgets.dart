import 'package:flutter/material.dart';
import 'package:staki_mobile/core/constants/spacing.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/app_icons.dart';
import 'package:staki_mobile/core/theme/text_styles.dart';
import 'package:staki_mobile/presentation/features/loan_lifecycle/providers/lifecycle_models.dart';

/// Short status for a loan stage, used on Home and the Loans tab.
String loanStageLabel(LoanStage stage) => switch (stage) {
      LoanStage.submitted => 'Application submitted',
      LoanStage.underReview => 'Under review',
      LoanStage.approved => 'Approved: ready to sign',
      LoanStage.disbursementPending => 'Disbursement in progress',
      LoanStage.disbursed => 'Funds disbursed',
      LoanStage.active => 'Active',
      LoanStage.repaymentDue => 'Repayment due',
      LoanStage.fullyRepaid => 'Fully repaid',
      LoanStage.declined => 'Declined',
    };

/// A summary card with an icon, a big headline and an optional action.
class HomeCard extends StatelessWidget {
  const HomeCard({
    required this.icon,
    required this.title,
    required this.headline,
    required this.detail,
    super.key,
    this.actionLabel,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String headline;
  final String detail;
  final String? actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceAlt,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    title.toUpperCase(),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s3),
              Text(
                headline,
                style: AppTextStyles.h1.copyWith(color: AppColors.primary),
              ),
              if (detail.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  detail,
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
              if (actionLabel != null) ...[
                const SizedBox(height: AppSpacing.s3),
                Row(
                  children: [
                    Text(
                      actionLabel!,
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    const Icon(
                      AppIcons.caretRight,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Square shortcut button on Home.
class QuickAction extends StatelessWidget {
  const QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md,
            horizontal: AppSpacing.sm,
          ),
          child: Column(
            children: [
              Icon(icon, size: 22, color: AppColors.primary),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
