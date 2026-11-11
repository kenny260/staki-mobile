import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/presentation/features/lender/lender_routes.dart';
import 'package:staki_mobile/presentation/features/lender/providers/lender_models.dart';
import 'package:staki_mobile/presentation/features/lender/providers/lender_providers.dart';
import 'package:staki_mobile/presentation/features/lender/widgets/entry_widgets.dart';
import 'package:staki_mobile/presentation/features/lender/widgets/lender_widgets.dart';
import 'package:staki_mobile/presentation/shared_widgets/shared_widgets.dart';

class LenderOtpPage extends ConsumerStatefulWidget {
  const LenderOtpPage({super.key});

  @override
  ConsumerState<LenderOtpPage> createState() => _LenderOtpPageState();
}

class _LenderOtpPageState extends ConsumerState<LenderOtpPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();
  final ValueNotifier<String?> _error = ValueNotifier<String?>(null);
  final ValueNotifier<bool> _busy = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    _error.dispose();
    _busy.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final code = _controller.text;
    if (code.length < OtpBoxes.length) {
      _error.value = 'Enter all 6 digits of the code.';
      return;
    }
    _error.value = null;
    _busy.value = true;
    final ok =
        await ref.read(lenderControllerProvider.notifier).verifyOtp(code);
    if (!mounted) return;
    _busy.value = false;
    if (!ok) {
      _error.value = "That code didn't match. Please check it and try again.";
      return;
    }
    unawaited(context.push(LenderRoutes.pin));
  }

  Future<void> _resend() async {
    final phone = ref.read(lenderControllerProvider).draft.phone;
    ref.invalidate(resendCountdownProvider);
    final ok = await ref.read(lenderControllerProvider.notifier).sendOtp(phone);
    if (!mounted) return;
    showLenderMessage(
      context,
      ok ? 'A new code was sent.' : "We couldn't send a new code.",
    );
  }

  @override
  Widget build(BuildContext context) {
    final phone = ref.watch(
      lenderControllerProvider.select((s) => s.draft.phone),
    );
    final shown = phone.length == 9 ? formatRwandaPhone(phone) : phone;
    final seconds = ref.watch(resendCountdownProvider).valueOrNull ?? 45;
    final countdown = '00:${seconds.toString().padLeft(2, '0')}';

    return LenderScaffold(
      title: 'Verification',
      bottom: ValueListenableBuilder<bool>(
        valueListenable: _busy,
        builder: (context, busy, _) => AppButton(
          label: 'Verify',
          isLoading: busy,
          onPressed: () => unawaited(_verify()),
        ),
      ),
      children: [
        const LenderHeading('Verify your number'),
        const SizedBox(height: 6),
        LenderBody('Enter the 6-digit code sent to +250 $shown'),
        const SizedBox(height: 24),
        ValueListenableBuilder<String?>(
          valueListenable: _error,
          builder: (context, error, _) => Column(
            children: [
              OtpBoxes(
                controller: _controller,
                focusNode: _focus,
                hasError: error != null,
              ),
              if (error != null) ...[
                const SizedBox(height: 10),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.danger,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: seconds > 0
              ? Text(
                  'Resend code in $countdown',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.warningText,
                  ),
                )
              : TextButton(
                  onPressed: () => unawaited(_resend()),
                  child: const Text('Resend code'),
                ),
        ),
      ],
    );
  }
}
