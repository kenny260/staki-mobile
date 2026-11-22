import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/constants/spacing.dart';
import 'package:staki_mobile/core/router/app_routes.dart';
import 'package:staki_mobile/core/theme/app_icons.dart';
import 'package:staki_mobile/domain/entities/user_role.dart';
import 'package:staki_mobile/presentation/features/onboarding/providers/onboarding_providers.dart';
import 'package:staki_mobile/presentation/shared_widgets/shared_widgets.dart';

/// A03_RoleSelect
class A03RoleSelectPage extends ConsumerWidget {
  const A03RoleSelectPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(selectedRoleProvider);
    final notifier = ref.read(selectedRoleProvider.notifier);

    VoidCallback? onContinue;
    if (role != null) {
      onContinue = () => context.push(
            role == UserRole.borrower
                ? AppRoutes.borrowerConfirmed
                : AppRoutes.lenderConfirmed,
          );
    }

    return StepScaffold(
      heading: 'How will you use Staki fund?',
      subheading: 'Choose your role. You can always add the other later.',
      ctaLabel: switch (role) {
        UserRole.borrower => 'Continue as Borrower',
        UserRole.lender => 'Continue as Lender',
        null => 'Continue as ...',
      },
      onCta: onContinue,
      children: [
        RadioCard(
          icon: AppIcons.wallet,
          badgeLabel: 'Borrower',
          title: 'I need funding',
          subtitle: 'Build your financial profile, get a Staki fund score and '
              'apply for loans from regulated lenders.',
          selected: role == UserRole.borrower,
          onTap: () => notifier.select(UserRole.borrower),
        ),
        const SizedBox(height: AppSpacing.md),
        RadioCard(
          icon: AppIcons.trendUp,
          badgeLabel: 'Lender / Investor',
          title: 'I want to fund',
          subtitle: 'Browse pre-scored, verified borrowers and fund '
              'opportunities matched to your portfolio criteria.',
          selected: role == UserRole.lender,
          onTap: () => notifier.select(UserRole.lender),
        ),
      ],
    );
  }
}
