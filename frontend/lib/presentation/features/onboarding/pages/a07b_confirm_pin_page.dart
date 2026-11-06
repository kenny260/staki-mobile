import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/router/app_routes.dart';
import 'package:staki_mobile/presentation/features/onboarding/providers/onboarding_providers.dart';
import 'package:staki_mobile/presentation/features/onboarding/widgets/pin_entry_view.dart';

/// A07b_ConfirmPIN
class A07bConfirmPinPage extends ConsumerStatefulWidget {
  const A07bConfirmPinPage({super.key});

  @override
  ConsumerState<A07bConfirmPinPage> createState() => _A07bConfirmPinPageState();
}

class _A07bConfirmPinPageState extends ConsumerState<A07bConfirmPinPage> {
  String? _error;

  void _onCompleted(String pin) {
    final draft = ref.read(pinDraftProvider);
    if (pin == draft) {
      // TODO(Tolu): save a hash of the PIN with flutter_secure_storage.
      ref.read(pinDraftProvider.notifier).clear();
      context.push(AppRoutes.biometric);
    } else {
      setState(() => _error = 'PINs do not match. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PinEntryView(
      heading: 'Confirm your PIN',
      subtitle: 'Re-enter to confirm',
      activeStep: 2,
      errorText: _error,
      onCompleted: _onCompleted,
    );
  }
}
