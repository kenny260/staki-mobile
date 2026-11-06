import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/constants/spacing.dart';
import 'package:staki_mobile/core/router/app_routes.dart';
import 'package:staki_mobile/core/theme/text_styles.dart';
import 'package:staki_mobile/core/utils/validators.dart';
import 'package:staki_mobile/presentation/features/onboarding/providers/onboarding_providers.dart';
import 'package:staki_mobile/presentation/shared_widgets/shared_widgets.dart';

/// A05_Phone
class A05PhonePage extends ConsumerWidget {
  const A05PhonePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phone = ref.watch(phoneNumberProvider);
    final digits = Validators.normalizeRwandaPhone(phone);
    final isValid = Validators.isValidRwandaPhone(phone);
    final showError = digits.length >= 9 && !isValid;

    return StepScaffold(
      appBarTitle: 'Create your account',
      step: 1,
      totalSteps: 2,
      heading: "What's your phone number?",
      subheading: "We'll send a one-time code to verify it's you. Use the "
          'number linked to your MTN MoMo account for the best experience.',
      ctaLabel: 'Send verification code',
      onCta: isValid ? () => context.push(AppRoutes.otp) : null,
      footerText: 'Standard SMS rates may apply · Rwanda only',
      children: [
        AppTextField(
          label: 'Phone number',
          hint: '078 400 2213',
          helper: 'Your number is used for verification only and is never '
              'shared with lenders without your consent.',
          initialValue: phone,
          keyboardType: TextInputType.phone,
          maxLength: 13,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp('[0-9 ]')),
          ],
          errorText: showError ? 'Enter a valid Rwandan mobile number' : null,
          prefix: const Text('🇷🇼  +250', style: AppTextStyles.label),
          onChanged: ref.read(phoneNumberProvider.notifier).set,
        ),
        const SizedBox(height: AppSpacing.md),
        const Wrap(
          spacing: AppSpacing.sm,
          children: [
            AppBadge(label: 'MTN MoMo'),
            AppBadge(label: 'Airtel Rwanda'),
          ],
        ),
      ],
    );
  }
}
