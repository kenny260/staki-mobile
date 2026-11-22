import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/app_icons.dart';
import 'package:staki_mobile/presentation/features/lender/lender_routes.dart';
import 'package:staki_mobile/presentation/features/lender/providers/lender_providers.dart';
import 'package:staki_mobile/presentation/features/lender/widgets/lender_widgets.dart';
import 'package:staki_mobile/presentation/shared_widgets/shared_widgets.dart';

class LenderStructurePage extends ConsumerStatefulWidget {
  const LenderStructurePage({super.key});

  @override
  ConsumerState<LenderStructurePage> createState() =>
      _LenderStructurePageState();
}

class _LenderStructurePageState extends ConsumerState<LenderStructurePage> {
  final ValueNotifier<bool> _busy = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _busy.dispose();
    super.dispose();
  }

  /// CREATE the lender registration.
  Future<void> _submit() async {
    _busy.value = true;
    final profile = await ref.read(lenderControllerProvider.notifier).submit();
    if (!mounted) return;
    _busy.value = false;
    if (profile == null) {
      showLenderMessage(
        context,
        "We couldn't complete your registration. Please check every step "
        'and try again.',
      );
      return;
    }
    context.go(LenderRoutes.success);
  }

  @override
  Widget build(BuildContext context) {
    final accepted = ref.watch(
      lenderControllerProvider.select((s) => s.draft.structureAccepted),
    );

    return LenderScaffold(
      title: 'Our Structure',
      bottom: ValueListenableBuilder<bool>(
        valueListenable: _busy,
        builder: (context, busy, _) => AppButton(
          label: 'Agree & Continue',
          isLoading: busy,
          // Disabled until the box is ticked.
          onPressed: accepted ? () => unawaited(_submit()) : null,
        ),
      ),
      children: [
        const AmberBadge(icon: AppIcons.info, color: AppColors.info),
        const SizedBox(height: 20),
        const LenderHeading('How Staki fund works'),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Technology & Infrastructure',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 8),
              LenderBody(
                'Credit Passport (by Staki fund) provides technology, '
                'scoring infrastructure, and platform interface.',
              ),
              Divider(height: 28, color: AppColors.border),
              Text(
                'Regulated Lending',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 8),
              LenderBody(
                'Regulated partners handle lending, compliance, and '
                'regulated money movement. Staki fund does not directly '
                'hold customer funds.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AcknowledgeRow(
          checked: accepted,
          text: 'I understand that loans and money movements are managed by '
              'regulated partners, not Staki fund.',
          onTap: ref.read(lenderControllerProvider.notifier).toggleStructure,
        ),
      ],
    );
  }
}
