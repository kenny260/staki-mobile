import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/constants/spacing.dart';
import 'package:staki_mobile/core/router/app_routes.dart';
import 'package:staki_mobile/presentation/features/profile/profile_options.dart';
import 'package:staki_mobile/presentation/features/profile/providers/profile_setup_provider.dart';
import 'package:staki_mobile/presentation/shared_widgets/shared_widgets.dart';

/// P31_SalaryIncome (step 3 of 4)
class P31SalaryIncomePage extends ConsumerWidget {
  const P31SalaryIncomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(profileSetupProvider);
    final n = ref.read(profileSetupProvider.notifier);
    final valid =
        s.has(ProfileFields.salaryRange) && s.has(ProfileFields.tenure);

    return StepScaffold(
      step: 3,
      totalSteps: ProfileOptions.totalSteps(s.type),
      heading: 'Income & tenure',
      subheading: 'Gross monthly income before deductions.',
      ctaLabel: 'Continue',
      onCta: valid ? () => context.push(AppRoutes.review) : null,
      children: [
        OptionChips(
          label: 'Monthly income range (RWF)',
          options: ProfileOptions.salaryRanges,
          selected: s.optionOrNull(ProfileFields.salaryRange),
          onSelected: (v) => n.setAnswer(ProfileFields.salaryRange, v),
        ),
        const SizedBox(height: AppSpacing.lg),
        OptionChips(
          label: 'Time with current employer',
          options: ProfileOptions.tenures,
          selected: s.optionOrNull(ProfileFields.tenure),
          onSelected: (v) => n.setAnswer(ProfileFields.tenure, v),
        ),
        const SizedBox(height: AppSpacing.lg),
        const InfoBanner(
          message: 'We will verify income against your MTN MoMo salary '
              'credits or bank deposits — no documents needed upfront.',
        ),
      ],
    );
  }
}
