import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/constants/spacing.dart';
import 'package:staki_mobile/core/router/app_routes.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/text_styles.dart';
import 'package:staki_mobile/core/utils/validators.dart';
import 'package:staki_mobile/presentation/features/onboarding/providers/onboarding_providers.dart';
import 'package:staki_mobile/presentation/shared_widgets/shared_widgets.dart';

/// A06_Otp. The resend countdown is purely local UI state, so a
/// StatefulWidget is fine here (feature state lives in Riverpod).
class A06OtpPage extends ConsumerStatefulWidget {
  const A06OtpPage({super.key});

  @override
  ConsumerState<A06OtpPage> createState() => _A06OtpPageState();
}

class _A06OtpPageState extends ConsumerState<A06OtpPage> {
  static const _resendSeconds = 30;
  int _secondsLeft = _resendSeconds;
  String _code = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 1) {
        t.cancel();
      }
      if (mounted) setState(() => _secondsLeft = _secondsLeft - 1);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _verify() {
    // TODO(Tolu): verify the code with the auth backend before continuing.
    context.push(AppRoutes.createPin);
  }

  @override
  Widget build(BuildContext context) {
    final phone = ref.watch(phoneNumberProvider);
    final canResend = _secondsLeft <= 0;

    return StepScaffold(
      appBarTitle: 'Verify your number',
      step: 2,
      totalSteps: 2,
      heading: 'Enter the 6-digit code',
      subheading: 'We sent a code to ${Validators.displayRwandaPhone(phone)}',
      ctaLabel: 'Verify',
      onCta: _code.length == 6 ? _verify : null,
      footerText: 'Standard SMS rates may apply · Rwanda only',
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: const Text('Change number'),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        OtpInput(onChanged: (v) => setState(() => _code = v)),
        const SizedBox(height: AppSpacing.md),
        Center(
          child: canResend
              ? TextButton(
                  onPressed: _startTimer, // TODO(Tolu): re-send the code.
                  child: const Text('Resend code'),
                )
              : Text(
                  'Resend code in 0:${_secondsLeft.toString().padLeft(2, '0')}',
                  style: AppTextStyles.caption,
                ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const InfoBanner(
          icon: Icons.shield_outlined,
          message: 'Never share this code. Staki fund will never ask for your '
              'OTP over the phone or chat.',
        ),
        const SizedBox(height: AppSpacing.sm),
        const Text(
          'Codes expire after a few minutes.',
          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
      ],
    );
  }
}
