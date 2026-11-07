import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/constants/spacing.dart';
import 'package:staki_mobile/core/router/app_routes.dart';
import 'package:staki_mobile/presentation/features/profile/profile_options.dart';
import 'package:staki_mobile/presentation/features/profile/providers/profile_setup_provider.dart';
import 'package:staki_mobile/presentation/shared_widgets/shared_widgets.dart';

/// P02_BizInfo
class P02BizInfoPage extends ConsumerWidget {
  const P02BizInfoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(profileSetupProvider);
    final n = ref.read(profileSetupProvider.notifier);
    final valid = s.has(ProfileFields.businessName, min: 2) &&
        s.has(ProfileFields.businessType);

    return StepScaffold(
      step: 2,
      totalSteps: 5,
      heading: 'Tell us about your business',
      subheading: 'Used for your credit profile only, not shared with lenders '
          'without consent.',
      ctaLabel: 'Continue',
      onCta: valid ? () => context.push(AppRoutes.bizFinancials) : null,
      children: [
        AppTextField(
          label: 'Business name',
          hint: 'e.g. Mukamana Crafts Ltd',
          helper: 'Use the name your customers know you by',
          initialValue: s.value(ProfileFields.businessName),
          textCapitalization: TextCapitalization.words,
          onChanged: (v) => n.setAnswer(ProfileFields.businessName, v),
        ),
        const SizedBox(height: AppSpacing.lg),
        OptionChips(
          label: 'Business type',
          options: ProfileOptions.businessTypes,
          selected: s.optionOrNull(ProfileFields.businessType),
          onSelected: (v) => n.setAnswer(ProfileFields.businessType, v),
        ),
      ],
    );
  }
}
