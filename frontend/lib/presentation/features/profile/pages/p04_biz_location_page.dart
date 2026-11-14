import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/router/app_routes.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/app_icons.dart';
import 'package:staki_mobile/presentation/features/profile/providers/profile_setup_provider.dart';
import 'package:staki_mobile/presentation/shared_widgets/shared_widgets.dart';

/// P04_BizLocation
class P04BizLocationPage extends ConsumerWidget {
  const P04BizLocationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(profileSetupProvider);
    final n = ref.read(profileSetupProvider.notifier);

    return StepScaffold(
      step: 4,
      totalSteps: 5,
      heading: 'Where is your business located?',
      subheading: 'Business location is used to match you with nearby lenders.',
      ctaLabel: 'Continue',
      onCta: s.has(ProfileFields.location, min: 3)
          ? () => context.push(AppRoutes.review)
          : null,
      children: [
        AppTextField(
          label: 'Business location',
          hint: 'e.g. Kigali, Gasabo District',
          helper: 'District or province is sufficient',
          initialValue: s.value(ProfileFields.location),
          textCapitalization: TextCapitalization.words,
          prefix: const Icon(
            AppIcons.mapPin,
            size: 18,
            color: AppColors.textMuted,
          ),
          onChanged: (v) => n.setAnswer(ProfileFields.location, v),
        ),
      ],
    );
  }
}
