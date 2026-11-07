import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/constants/spacing.dart';
import 'package:staki_mobile/core/router/app_routes.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/text_styles.dart';
import 'package:staki_mobile/domain/entities/user_role.dart';
import 'package:staki_mobile/presentation/features/onboarding/providers/onboarding_providers.dart';
import 'package:staki_mobile/presentation/shared_widgets/shared_widgets.dart';

/// A09_AccountCreated
class A09AccountCreatedPage extends ConsumerWidget {
  const A09AccountCreatedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLender = ref.watch(selectedRoleProvider) == UserRole.lender;

    return StepScaffold(
      heading: 'Account created!',
      ctaLabel: 'Set up my profile →',
      onCta: () => context.go(
        isLender ? AppRoutes.lenderOnboarding : AppRoutes.profileRole,
      ),
      children: [
        Center(
          child: Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.successBg,
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 44,
              color: AppColors.success,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const Text(
          'Your Staki fund account is ready. Next, complete your profile and '
          'start building your financial passport.',
          style: AppTextStyles.body,
        ),
        const SizedBox(height: AppSpacing.lg),
        const _NextStep(
          number: '1',
          title: 'Complete your profile',
          subtitle: 'Name, ID number and address',
        ),
        const _NextStep(
          number: '2',
          title: 'Connect your data',
          subtitle: 'MTN MoMo and bank accounts',
        ),
        const _NextStep(
          number: '3',
          title: 'Get your score',
          subtitle: '300–1000 Credit Passport score',
        ),
      ],
    );
  }
}

class _NextStep extends StatelessWidget {
  const _NextStep({
    required this.number,
    required this.title,
    required this.subtitle,
  });

  final String number;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              number,
              style: AppTextStyles.label.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.label),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
