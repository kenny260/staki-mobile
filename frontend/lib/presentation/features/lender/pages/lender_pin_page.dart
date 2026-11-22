import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/app_icons.dart';
import 'package:staki_mobile/presentation/features/lender/lender_routes.dart';
import 'package:staki_mobile/presentation/features/lender/providers/lender_providers.dart';
import 'package:staki_mobile/presentation/features/lender/widgets/entry_widgets.dart';
import 'package:staki_mobile/presentation/features/lender/widgets/lender_widgets.dart';

class LenderPinPage extends ConsumerWidget {
  const LenderPinPage({super.key});

  Future<void> _complete(
    BuildContext context,
    WidgetRef ref,
    String pin,
  ) async {
    final ok = await ref.read(lenderControllerProvider.notifier).createPin(pin);
    if (!context.mounted) return;
    ref.read(pinEntryProvider.notifier).state = '';
    if (!ok) {
      showLenderMessage(context, "We couldn't save your PIN. Please retry.");
      return;
    }
    unawaited(context.push(LenderRoutes.profile));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<String>(pinEntryProvider, (_, next) {
      if (next.length == 4) unawaited(_complete(context, ref, next));
    });
    final pin = ref.watch(pinEntryProvider);

    return LenderScaffold(
      title: 'Security',
      bottom: PinPad(
        onDigit: (d) {
          final current = ref.read(pinEntryProvider);
          if (current.length < 4) {
            ref.read(pinEntryProvider.notifier).state = current + d;
          }
        },
        onDelete: () {
          final current = ref.read(pinEntryProvider);
          if (current.isNotEmpty) {
            ref.read(pinEntryProvider.notifier).state =
                current.substring(0, current.length - 1);
          }
        },
      ),
      children: [
        const SizedBox(height: 8),
        const Center(child: AmberBadge(icon: AppIcons.lockKey)),
        const SizedBox(height: 16),
        const Center(child: LenderHeading('Create a PIN')),
        const SizedBox(height: 6),
        const Center(
          child: Text(
            'Secure your investor account.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(height: 20),
        Center(child: PinDots(filled: pin.length)),
      ],
    );
  }
}
