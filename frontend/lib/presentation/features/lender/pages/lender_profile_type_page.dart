import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/app_icons.dart';
import 'package:staki_mobile/presentation/features/lender/lender_routes.dart';
import 'package:staki_mobile/presentation/features/lender/providers/lender_models.dart';
import 'package:staki_mobile/presentation/features/lender/providers/lender_providers.dart';
import 'package:staki_mobile/presentation/features/lender/widgets/lender_widgets.dart';
import 'package:staki_mobile/presentation/shared_widgets/shared_widgets.dart';

class LenderProfileTypePage extends ConsumerWidget {
  const LenderProfileTypePage({super.key});

  static const _icons = <InvestorType, IconData>{
    InvestorType.individual: AppIcons.user,
    InvestorType.diaspora: AppIcons.globe,
    InvestorType.institutional: AppIcons.buildings,
  };

  Future<void> _continue(BuildContext context, WidgetRef ref) async {
    final ok = await ref.read(lenderControllerProvider.notifier).saveDraft();
    if (!context.mounted) return;
    if (!ok) {
      showLenderMessage(
        context,
        "We couldn't save your choice. Please try again.",
      );
      return;
    }
    unawaited(context.push(LenderRoutes.kyc));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(
      lenderControllerProvider.select((s) => s.draft.profileType),
    );
    final controller = ref.read(lenderControllerProvider.notifier);

    return LenderScaffold(
      title: 'Profile Setup',
      bottom: AppButton(
        label: 'Continue',
        // Disabled until a type is chosen.
        onPressed:
            selected == null ? null : () => unawaited(_continue(context, ref)),
      ),
      children: [
        const LenderHeading('Investor Profile'),
        const SizedBox(height: 6),
        const Text(
          'What type of investor are you?',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 20),
        for (final type in InvestorType.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: LenderOptionCard(
              icon: _icons[type] ?? AppIcons.user,
              title: type.title,
              subtitle: type.subtitle,
              selected: selected == type,
              onTap: () => controller.chooseType(type),
            ),
          ),
      ],
    );
  }
}
