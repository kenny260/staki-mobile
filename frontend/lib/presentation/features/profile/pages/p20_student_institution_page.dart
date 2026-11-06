import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/constants/spacing.dart';
import 'package:staki_mobile/core/router/app_routes.dart';
import 'package:staki_mobile/presentation/features/profile/profile_options.dart';
import 'package:staki_mobile/presentation/features/profile/providers/profile_setup_provider.dart';
import 'package:staki_mobile/presentation/shared_widgets/shared_widgets.dart';

/// P20_StudentInstitution
class P20StudentInstitutionPage extends ConsumerWidget {
  const P20StudentInstitutionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(profileSetupProvider);
    final n = ref.read(profileSetupProvider.notifier);
    final valid = s.has(ProfileFields.institution, min: 2) &&
        s.has(ProfileFields.studyLevel) &&
        s.has(ProfileFields.enrollment);

    return StepScaffold(
      step: 2,
      totalSteps: 4,
      heading: 'Your studies',
      subheading: 'We tailor your profile to reflect student borrowers '
          'accurately.',
      ctaLabel: 'Continue',
      onCta: valid ? () => context.push(AppRoutes.studentIncome) : null,
      children: [
        AppTextField(
          label: 'Institution',
          hint: 'e.g. University of Rwanda',
          initialValue: s.value(ProfileFields.institution),
          textCapitalization: TextCapitalization.words,
          onChanged: (v) => n.setAnswer(ProfileFields.institution, v),
        ),
        const SizedBox(height: AppSpacing.lg),
        OptionChips(
          label: 'Study level',
          options: ProfileOptions.studyLevels,
          selected: s.optionOrNull(ProfileFields.studyLevel),
          onSelected: (v) => n.setAnswer(ProfileFields.studyLevel, v),
        ),
        const SizedBox(height: AppSpacing.lg),
        OptionChips(
          label: 'Enrollment status',
          options: ProfileOptions.enrollment,
          selected: s.optionOrNull(ProfileFields.enrollment),
          onSelected: (v) => n.setAnswer(ProfileFields.enrollment, v),
        ),
      ],
    );
  }
}
