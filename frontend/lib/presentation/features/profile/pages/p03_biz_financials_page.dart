import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/constants/spacing.dart';
import 'package:staki_mobile/core/router/app_routes.dart';
import 'package:staki_mobile/presentation/features/profile/profile_options.dart';
import 'package:staki_mobile/presentation/features/profile/providers/profile_setup_provider.dart';
import 'package:staki_mobile/presentation/shared_widgets/shared_widgets.dart';

/// P03_BizFinancials
class P03BizFinancialsPage extends ConsumerWidget {
  const P03BizFinancialsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(profileSetupProvider);
    final n = ref.read(profileSetupProvider.notifier);
    final valid = s.has(ProfileFields.yearsOperating) &&
        s.has(ProfileFields.monthlyRevenue);

    return StepScaffold(
      step: 3,
      totalSteps: 5,
      heading: 'Business history & revenue',
      subheading: 'Approximate figures are fine. We use them to calibrate '
          'your score.',
      ctaLabel: 'Continue',
      onCta: valid ? () => context.push(AppRoutes.bizLocation) : null,
      children: [
        OptionChips(
          label: 'Years operating',
          options: ProfileOptions.yearsOperating,
          selected: s.optionOrNull(ProfileFields.yearsOperating),
          onSelected: (v) => n.setAnswer(ProfileFields.yearsOperating, v),
        ),
        const SizedBox(height: AppSpacing.lg),
        OptionChips(
          label: 'Approximate monthly revenue (RWF)',
          options: ProfileOptions.businessRevenue,
          selected: s.optionOrNull(ProfileFields.monthlyRevenue),
          onSelected: (v) => n.setAnswer(ProfileFields.monthlyRevenue, v),
        ),
        const SizedBox(height: AppSpacing.lg),
        const InfoBanner(
          message: 'Revenue figures are never shown directly to lenders. '
              'They inform your score band only.',
        ),
      ],
    );
  }
}
