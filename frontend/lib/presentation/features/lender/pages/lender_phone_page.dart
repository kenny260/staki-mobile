import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/app_icons.dart';
import 'package:staki_mobile/presentation/features/lender/lender_routes.dart';
import 'package:staki_mobile/presentation/features/lender/providers/lender_models.dart';
import 'package:staki_mobile/presentation/features/lender/providers/lender_providers.dart';
import 'package:staki_mobile/presentation/features/lender/widgets/lender_widgets.dart';
import 'package:staki_mobile/presentation/shared_widgets/shared_widgets.dart';

class LenderPhonePage extends ConsumerStatefulWidget {
  const LenderPhonePage({super.key});

  @override
  ConsumerState<LenderPhonePage> createState() => _LenderPhonePageState();
}

class _LenderPhonePageState extends ConsumerState<LenderPhonePage> {
  late final TextEditingController _controller;
  final ValueNotifier<String?> _error = ValueNotifier<String?>(null);
  final ValueNotifier<bool> _busy = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(lenderControllerProvider).draft.phone,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _error.dispose();
    _busy.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final phone = normalizeRwandaPhone(_controller.text);
    if (phone == null) {
      _error.value = 'Enter a valid Rwandan mobile number, '
          'for example 788 555 210.';
      return;
    }
    _error.value = null;
    _busy.value = true;
    final ok = await ref.read(lenderControllerProvider.notifier).sendOtp(phone);
    if (!mounted) return;
    _busy.value = false;
    if (!ok) {
      showLenderMessage(
        context,
        "We couldn't send the code. Please try again.",
      );
      return;
    }
    unawaited(context.push(LenderRoutes.otp));
  }

  @override
  Widget build(BuildContext context) {
    return LenderScaffold(
      title: 'Registration',
      bottom: ValueListenableBuilder<bool>(
        valueListenable: _busy,
        builder: (context, busy, _) => AppButton(
          label: 'Continue',
          isLoading: busy,
          onPressed: () => unawaited(_submit()),
        ),
      ),
      children: [
        const AmberBadge(icon: AppIcons.deviceMobile),
        const SizedBox(height: 20),
        const LenderHeading('Enter your phone number'),
        const SizedBox(height: 6),
        const LenderBody('We will send a code to verify your account.'),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: const Text(
                '+250',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ValueListenableBuilder<String?>(
                valueListenable: _error,
                builder: (context, error, _) => TextField(
                  controller: _controller,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9 ]')),
                    LengthLimitingTextInputFormatter(13),
                  ],
                  onSubmitted: (_) => unawaited(_submit()),
                  decoration: InputDecoration(
                    hintText: '788 555 210',
                    errorText: error,
                    errorMaxLines: 3,
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
