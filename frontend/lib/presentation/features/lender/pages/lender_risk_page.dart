import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/presentation/features/lender/lender_routes.dart';
import 'package:staki_mobile/presentation/features/lender/providers/lender_providers.dart';
import 'package:staki_mobile/presentation/features/lender/widgets/lender_widgets.dart';
import 'package:staki_mobile/presentation/shared_widgets/shared_widgets.dart';

class LenderRiskPage extends ConsumerWidget {
  const LenderRiskPage({super.key});

  Future<void> _continue(BuildContext context, WidgetRef ref) async {
    final ok = await ref.read(lenderControllerProvider.notifier).saveDraft();
    if (!context.mounted) return;
    if (!ok) {
      showLenderMessage(context, "We couldn't save that. Please try again.");
      return;
    }
    unawaited(context.push(LenderRoutes.structure));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final acknowledged = ref.watch(
      lenderControllerProvider.select((s) => s.draft.riskAcknowledged),
    );

    return LenderScaffold(
      title: 'Risk Disclosure',
      bottom: AppButton(
        label: 'I Acknowledge',
        // Disabled until the box is ticked.
        onPressed:
            acknowledged ? () => unawaited(_continue(context, ref)) : null,
      ),
      children: [
        const AmberBadge(icon: Icons.warning_amber_rounded),
        const SizedBox(height: 20),
        const LenderHeading('Risk Disclosure'),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.warningBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            'Funding opportunities involve risk. Returns are not guaranteed.',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.warningText,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const LenderBody(
          'By participating as a lender or investor, you acknowledge that '
          'lending money involves the risk of loss, including potential loss '
          'of principal.',
        ),
        const SizedBox(height: 12),
        const LenderBody(
          'While Credit Passport utilizes advanced scoring to assess '
          'financial health, past performance is not a guarantee of future '
          'repayment.',
        ),
        const SizedBox(height: 12),
        const LenderBody(
          'Ensure you understand the terms and recovery processes before '
          'committing funds.',
        ),
        const SizedBox(height: 8),
        AcknowledgeRow(
          checked: acknowledged,
          text: 'I have read and understand the risks associated with '
              'funding opportunities.',
          onTap: ref.read(lenderControllerProvider.notifier).toggleRisk,
        ),
      ],
    );
  }
}
