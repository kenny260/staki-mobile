import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/constants/spacing.dart';
import 'package:staki_mobile/core/router/app_routes.dart';
import 'package:staki_mobile/presentation/features/auth/providers/auth_controller.dart';
import 'package:staki_mobile/presentation/features/auth/providers/auth_form_providers.dart';
import 'package:staki_mobile/presentation/features/auth/widgets/auth_error_banner.dart';
import 'package:staki_mobile/presentation/shared_widgets/shared_widgets.dart';

/// Password reset. The confirmation is the same whether or not the email
/// has an account, so nobody can probe which emails are registered.
class ForgotPasswordPage extends ConsumerWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(forgotFormProvider);
    final formNotifier = ref.read(forgotFormProvider.notifier);
    final auth = ref.watch(authControllerProvider);
    final controller = ref.read(authControllerProvider.notifier);

    Future<void> submit() async {
      formNotifier.markSubmitted();
      if (!form.forgotValid) return;
      final ok = await controller.sendPasswordReset(form.email);
      if (ok) formNotifier.markResetSent();
    }

    return StepScaffold(
      appBarTitle: 'Reset password',
      heading: 'Forgot your password?',
      subheading: 'Enter your email and we will send you a link to choose a '
          'new one.',
      ctaLabel: auth.isLoading ? 'Sending...' : 'Send reset link',
      onCta: auth.isLoading ? null : submit,
      bottomExtra: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.sm),
        child: TextButton(
          onPressed: () => context.go(AppRoutes.login),
          child: const Text('Back to log in'),
        ),
      ),
      children: [
        if (auth.failure != null)
          AuthErrorBanner(message: auth.failure!.message),
        if (form.resetSent) ...[
          const InfoBanner(
            message: 'If an account exists for that email, we have sent a '
                'reset link. Check your inbox and spam folder.',
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        AppTextField(
          label: 'Email',
          hint: 'you@example.com',
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          textInputAction: TextInputAction.done,
          errorText: form.emailError,
          onChanged: formNotifier.setEmail,
        ),
      ],
    );
  }
}
