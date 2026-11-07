import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/router/app_routes.dart';
import 'package:staki_mobile/presentation/features/onboarding/providers/onboarding_providers.dart';
import 'package:staki_mobile/presentation/features/onboarding/widgets/pin_entry_view.dart';

/// A07_CreatePIN
class A07CreatePinPage extends ConsumerWidget {
  const A07CreatePinPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PinEntryView(
      heading: 'Create a secure PIN',
      subtitle: '4-digit PIN for quick access',
      activeStep: 1,
      onCompleted: (pin) {
        ref.read(pinDraftProvider.notifier).set(pin);
        context.push(AppRoutes.confirmPin);
      },
    );
  }
}
