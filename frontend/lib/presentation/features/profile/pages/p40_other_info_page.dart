import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/constants/spacing.dart';
import 'package:staki_mobile/core/router/app_routes.dart';
import 'package:staki_mobile/presentation/features/profile/profile_options.dart';
import 'package:staki_mobile/presentation/features/profile/providers/profile_setup_provider.dart';
import 'package:staki_mobile/presentation/shared_widgets/shared_widgets.dart';

/// P40_OtherInfo (step 2 of 3). Income is optional in the design.
class P40OtherInfoPage extends ConsumerWidget {
  const P40OtherInfoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(profileSetupProvider);
    final n = ref.read(profileSetupProvider.notifier);

    return StepScaffold(
      step: 2,
      totalSteps: ProfileOptions.totalSteps(s.type),
      heading: 'Your occupation',
      subheading: 'Help us understand your financial situation.',
      ctaLabel: 'Continue',
      onCta: s.has(ProfileFields.occupation)
          ? () => context.push(AppRoutes.review)
          : null,
      children: [
        OptionChips(
          label: 'Occupation type',
          options: ProfileOptions.occupations,
          selected: s.optionOrNull(ProfileFields.occupation),
          onSelected: (v) => n.setAnswer(ProfileFields.occupation, v),
        ),
        const SizedBox(height: AppSpacing.lg),
        OptionChips(
          label: 'Approximate monthly income (RWF)',
          isOptional: true,
          options: ProfileOptions.otherIncomes,
          selected: s.optionOrNull(ProfileFields.otherIncome),
          onSelected: (v) => n.setAnswer(ProfileFields.otherIncome, v),
        ),
      ],
    );
  }
}
