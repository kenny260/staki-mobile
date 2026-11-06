import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/constants/spacing.dart';
import 'package:staki_mobile/core/router/app_routes.dart';
import 'package:staki_mobile/domain/entities/borrower_type.dart';
import 'package:staki_mobile/presentation/features/profile/profile_options.dart';
import 'package:staki_mobile/presentation/features/profile/providers/profile_setup_provider.dart';
import 'package:staki_mobile/presentation/shared_widgets/shared_widgets.dart';

/// P01_ProfileRole (P01b is the same screen with a card selected).
class P01ProfileRolePage extends ConsumerWidget {
  const P01ProfileRolePage({super.key});

  String _routeFor(BorrowerType type) => switch (type) {
        BorrowerType.business => AppRoutes.bizInfo,
        BorrowerType.startup => AppRoutes.startupInfo,
        BorrowerType.student => AppRoutes.studentInstitution,
        BorrowerType.salaried => AppRoutes.salaried,
        BorrowerType.other => AppRoutes.otherInfo,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final type = ref.watch(profileSetupProvider).type;

    return StepScaffold(
      step: 1,
      totalSteps: ProfileOptions.totalSteps(type),
      heading: 'What best describes you?',
      subheading: 'This shapes the questions we ask. You can update it later.',
      ctaLabel: 'Continue',
      onCta: type == null ? null : () => context.push(_routeFor(type)),
      children: [
        for (final t in BorrowerType.values) ...[
          RadioCard(
            icon: ProfileOptions.icon(t),
            title: ProfileOptions.title(t),
            subtitle: ProfileOptions.subtitle(t),
            selected: type == t,
            onTap: () => ref.read(profileSetupProvider.notifier).setType(t),
          ),
          const SizedBox(height: AppSpacing.sm + 4),
        ],
      ],
    );
  }
}
