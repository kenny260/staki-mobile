import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/constants/spacing.dart';
import 'package:staki_mobile/core/router/app_routes.dart';
import 'package:staki_mobile/presentation/features/profile/profile_options.dart';
import 'package:staki_mobile/presentation/features/profile/providers/profile_setup_provider.dart';
import 'package:staki_mobile/presentation/shared_widgets/shared_widgets.dart';

/// P30_SalaryEmployment (step 2 of 4)
class P30SalaryEmploymentPage extends ConsumerWidget {
  const P30SalaryEmploymentPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(profileSetupProvider);
    final n = ref.read(profileSetupProvider.notifier);
    final valid = s.has(ProfileFields.employmentType) &&
        s.has(ProfileFields.employerName, min: 2);

    return StepScaffold(
      step: 2,
      totalSteps: ProfileOptions.totalSteps(s.type),
      heading: 'Your employment',
      ctaLabel: 'Continue',
      onCta: valid ? () => context.push(AppRoutes.salariedIncome) : null,
      children: [
        OptionChips(
          label: 'Employment type',
          options: ProfileOptions.employmentTypes,
          selected: s.optionOrNull(ProfileFields.employmentType),
          onSelected: (v) => n.setAnswer(ProfileFields.employmentType, v),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: 'Employer name',
          hint: 'e.g. Bank of Kigali',
          helper: 'As it appears on your contract or payslip',
          initialValue: s.value(ProfileFields.employerName),
          textCapitalization: TextCapitalization.words,
          onChanged: (v) => n.setAnswer(ProfileFields.employerName, v),
        ),
      ],
    );
  }
}
