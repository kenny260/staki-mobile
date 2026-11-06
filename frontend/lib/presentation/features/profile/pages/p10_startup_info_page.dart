import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/constants/spacing.dart';
import 'package:staki_mobile/core/router/app_routes.dart';
import 'package:staki_mobile/presentation/features/profile/profile_options.dart';
import 'package:staki_mobile/presentation/features/profile/providers/profile_setup_provider.dart';
import 'package:staki_mobile/presentation/shared_widgets/shared_widgets.dart';

/// P10_StartupInfo
class P10StartupInfoPage extends ConsumerWidget {
  const P10StartupInfoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(profileSetupProvider);
    final n = ref.read(profileSetupProvider.notifier);
    final valid = s.has(ProfileFields.startupName, min: 2) &&
        s.has(ProfileFields.startupStage);

    return StepScaffold(
      step: 2,
      totalSteps: 4,
      heading: 'Tell us about your startup',
      ctaLabel: 'Continue',
      onCta: valid ? () => context.push(AppRoutes.startupActivity) : null,
      children: [
        AppTextField(
          label: 'Startup / company name',
          hint: 'e.g. Soko Digital',
          initialValue: s.value(ProfileFields.startupName),
          textCapitalization: TextCapitalization.words,
          onChanged: (v) => n.setAnswer(ProfileFields.startupName, v),
        ),
        const SizedBox(height: AppSpacing.lg),
        OptionChips(
          label: 'Current stage',
          options: ProfileOptions.startupStages,
          selected: s.optionOrNull(ProfileFields.startupStage),
          onSelected: (v) => n.setAnswer(ProfileFields.startupStage, v),
        ),
      ],
    );
  }
}
