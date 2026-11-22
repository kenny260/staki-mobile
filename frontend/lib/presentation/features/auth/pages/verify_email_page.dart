import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/constants/spacing.dart';
import 'package:staki_mobile/core/router/app_routes.dart';
import 'package:staki_mobile/presentation/features/auth/providers/auth_controller.dart';
import 'package:staki_mobile/presentation/features/auth/providers/auth_form_providers.dart';
import 'package:staki_mobile/presentation/features/auth/providers/auth_providers.dart';
import 'package:staki_mobile/presentation/features/auth/widgets/auth_error_banner.dart';
import 'package:staki_mobile/presentation/shared_widgets/shared_widgets.dart';

/// Shown after email sign-up until the link in the email has been tapped.
class VerifyEmailPage extends ConsumerWidget {
  const VerifyEmailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = ref.watch(authStateProvider).valueOrNull?.email;
    final auth = ref.watch(authControllerProvider);
    final controller = ref.read(authControllerProvider.notifier);
    final cooldown = ref.watch(resendCooldownProvider);

    void showMessage(String text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(text)),
      );
    }

    Future<void> checkVerified() async {
      final verified = await controller.checkVerified();
      if (!context.mounted) return;
      if (!verified) {
        if (ref.read(authControllerProvider).failure == null) {
          showMessage(
            'We have not seen your verification yet. Tap the link in the '
            'email, then try again.',
          );
        }
        return;
      }
      context.go(await controller.landingLocation());
    }

    Future<void> resend() async {
      final ok = await controller.resendVerification();
      if (!ok) return;
      ref.read(resendCooldownProvider.notifier).start();
      if (context.mounted) showMessage('Verification email sent.');
    }

    Future<void> useDifferentEmail() async {
      await controller.signOut();
      if (context.mounted) context.go(AppRoutes.login);
    }

    return StepScaffold(
      appBarTitle: 'Verify your email',
      heading: 'Check your inbox',
      subheading: 'We sent a verification link to ${email ?? 'your email'}. '
          'Tap it, then come back here.',
      ctaLabel: auth.isLoading ? 'Checking...' : "I've verified my email",
      onCta: auth.isLoading ? null : checkVerified,
      bottomExtra: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.sm),
        child: Column(
          children: [
            AppOutlinedButton(
              label: cooldown > 0 ? 'Resend in ${cooldown}s' : 'Resend email',
              onPressed: auth.isLoading || cooldown > 0 ? null : resend,
            ),
            TextButton(
              onPressed: auth.isLoading ? null : useDifferentEmail,
              child: const Text('Use a different email'),
            ),
          ],
        ),
      ),
      children: [
        if (auth.failure != null)
          AuthErrorBanner(message: auth.failure!.message),
        const InfoBanner(
          message: "Can't find it? Check your spam folder. The link works "
              'only for this account.',
        ),
      ],
    );
  }
}
