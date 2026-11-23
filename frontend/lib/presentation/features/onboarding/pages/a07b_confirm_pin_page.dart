import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/router/app_routes.dart';
import 'package:staki_mobile/data/datasources/pin_store.dart';
import 'package:staki_mobile/presentation/features/auth/providers/auth_providers.dart';
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

  Future<void> _onCompleted(String pin) async {
    final draft = ref.read(pinDraftProvider);
    if (pin == draft) {
      // Saves a salted hash on this phone (never the PIN itself).
      final uid = ref.read(authRepositoryProvider).currentUser?.uid;
      if (uid != null) await ref.read(pinStoreProvider).save(uid, pin);
      ref.read(pinDraftProvider.notifier).clear();
      if (mounted) unawaited(context.push(AppRoutes.biometric));
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
