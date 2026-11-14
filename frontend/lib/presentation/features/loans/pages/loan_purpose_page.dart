import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/app_icons.dart';
import 'package:staki_mobile/presentation/features/loans/loan_routes.dart';
import 'package:staki_mobile/presentation/features/loans/providers/loan_models.dart';
import 'package:staki_mobile/presentation/features/loans/providers/loan_providers.dart';
import 'package:staki_mobile/presentation/features/loans/widgets/loan_widgets.dart';
import 'package:staki_mobile/presentation/shared_widgets/shared_widgets.dart';

class LoanPurposePage extends ConsumerWidget {
  const LoanPurposePage({super.key});

  Future<void> _continue(BuildContext context, WidgetRef ref) async {
    final ok = await ref.read(loanFlowProvider.notifier).saveDraft();
    if (!context.mounted) return;
    if (!ok) {
      showLoanMessage(
        context,
        "We couldn't save your choice. Please try again.",
      );
      return;
    }
    unawaited(context.push(LoanRoutes.review));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(loanFlowProvider).purpose;
    final controller = ref.read(loanFlowProvider.notifier);

    return LoanScaffold(
      title: 'Loan Application',
      subtitle: 'STEP 3 OF 4',
      bottom: AppButton(
        label: 'Continue',
        showArrow: true,
        // Disabled until a purpose is picked (L04).
        onPressed:
            selected == null ? null : () => unawaited(_continue(context, ref)),
      ),
      children: [
        const LoanHeading('How will you use this loan?'),
        const SizedBox(height: 6),
        const Text(
          'This helps lenders match you with the right loan product.',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 20),
        for (final purpose in LoanPurpose.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: LoanOptionCard(
              selected: selected == purpose,
              onTap: () => controller.setPurpose(purpose),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      purpose.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: selected == purpose
                            ? AppColors.successText
                            : AppColors.primary,
                      ),
                    ),
                  ),
                  if (selected == purpose)
                    const Icon(
                      AppIcons.checkCircle,
                      size: 20,
                      color: AppColors.success,
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
