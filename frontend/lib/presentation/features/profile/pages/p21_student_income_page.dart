import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/constants/spacing.dart';
import 'package:staki_mobile/core/router/app_routes.dart';
import 'package:staki_mobile/presentation/features/profile/profile_options.dart';
import 'package:staki_mobile/presentation/features/profile/providers/profile_setup_provider.dart';
import 'package:staki_mobile/presentation/shared_widgets/shared_widgets.dart';

/// P21_StudentIncome
class P21StudentIncomePage extends ConsumerWidget {
  const P21StudentIncomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(profileSetupProvider);
    final n = ref.read(profileSetupProvider.notifier);
    final valid =
        s.has(ProfileFields.incomeSource) && s.has(ProfileFields.studentIncome);

    return StepScaffold(
      step: 3,
      totalSteps: 4,
      heading: 'Income & support',
      subheading: 'This helps lenders understand your repayment capacity.',
      ctaLabel: 'Continue',
      onCta: valid ? () => context.push(AppRoutes.review) : null,
      children: [
        OptionChips(
          label: 'Primary source of income or support',
          options: ProfileOptions.incomeSources,
          selected: s.optionOrNull(ProfileFields.incomeSource),
          onSelected: (v) => n.setAnswer(ProfileFields.incomeSource, v),
        ),
        const SizedBox(height: AppSpacing.lg),
        OptionChips(
          label: 'Estimated monthly income / support (RWF)',
          options: ProfileOptions.studentIncome,
          selected: s.optionOrNull(ProfileFields.studentIncome),
          onSelected: (v) => n.setAnswer(ProfileFields.studentIncome, v),
        ),
        const SizedBox(height: AppSpacing.lg),
        const InfoBanner(
          message: 'Student loans from Staki fund partners are sized to your '
              'income and study duration, never more than you can repay.',
        ),
      ],
    );
  }
}
