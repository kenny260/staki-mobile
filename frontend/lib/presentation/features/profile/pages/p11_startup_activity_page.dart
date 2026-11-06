import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/constants/spacing.dart';
import 'package:staki_mobile/core/router/app_routes.dart';
import 'package:staki_mobile/presentation/features/profile/profile_options.dart';
import 'package:staki_mobile/presentation/features/profile/providers/profile_setup_provider.dart';
import 'package:staki_mobile/presentation/shared_widgets/shared_widgets.dart';

/// P11_StartupActivity
class P11StartupActivityPage extends ConsumerWidget {
  const P11StartupActivityPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(profileSetupProvider);
    final n = ref.read(profileSetupProvider.notifier);
    final valid = s.has(ProfileFields.startupActivity) &&
        s.has(ProfileFields.operatingHistory);

    return StepScaffold(
      step: 3,
      totalSteps: 4,
      heading: 'Activity & operating history',
      ctaLabel: 'Continue',
      onCta: valid ? () => context.push(AppRoutes.review) : null,
      children: [
        OptionChips(
          label: 'Business activity',
          options: ProfileOptions.startupActivities,
          selected: s.optionOrNull(ProfileFields.startupActivity),
          onSelected: (v) => n.setAnswer(ProfileFields.startupActivity, v),
        ),
        const SizedBox(height: AppSpacing.lg),
        OptionChips(
          label: 'Operating history',
          options: ProfileOptions.operatingHistory,
          selected: s.optionOrNull(ProfileFields.operatingHistory),
          onSelected: (v) => n.setAnswer(ProfileFields.operatingHistory, v),
        ),
        const SizedBox(height: AppSpacing.lg),
        OptionChips(
          label: 'Approximate monthly revenue (RWF)',
          isOptional: true,
          options: ProfileOptions.startupRevenue,
          selected: s.optionOrNull(ProfileFields.startupRevenue),
          onSelected: (v) => n.setAnswer(ProfileFields.startupRevenue, v),
        ),
      ],
    );
  }
}
