import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/constants/spacing.dart';
import 'package:staki_mobile/core/router/app_routes.dart';
import 'package:staki_mobile/presentation/features/auth/providers/auth_controller.dart';
import 'package:staki_mobile/presentation/features/auth/providers/auth_form_providers.dart';
import 'package:staki_mobile/presentation/features/auth/widgets/auth_error_banner.dart';
import 'package:staki_mobile/presentation/features/auth/widgets/google_sign_in_button.dart';
import 'package:staki_mobile/presentation/features/auth/widgets/or_divider.dart';
import 'package:staki_mobile/presentation/shared_widgets/shared_widgets.dart';

/// Create account (email and password, or Google). Needs the role chosen
/// on A03 first; the controller handles the "no role" case.
class RegisterPage extends ConsumerWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(registerFormProvider);
    final formNotifier = ref.read(registerFormProvider.notifier);
    final auth = ref.watch(authControllerProvider);
    final controller = ref.read(authControllerProvider.notifier);

    Future<void> submit() async {
      formNotifier.markSubmitted();
      if (!form.registerValid) return;
      final ok = await controller.register(form.email, form.password);
      if (!ok || !context.mounted) return;
      // A verification email was just sent, so start the resend cooldown.
      ref.read(resendCooldownProvider.notifier).start();
      context.go(AppRoutes.verifyEmail);
    }

    Future<void> signUpWithGoogle() async {
      final ok = await controller.signInWithGoogle();
      if (!ok) return;
      final location = await controller.landingLocation();
      if (context.mounted) context.go(location);
    }

    return StepScaffold(
      appBarTitle: 'Create your account',
      heading: 'Sign up with email',
      subheading: 'Use an email you can open now. We will send a link to '
          'confirm it.',
      ctaLabel: auth.isLoading ? 'Creating account...' : 'Create account',
      onCta: auth.isLoading ? null : submit,
      bottomExtra: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.sm),
        child: TextButton(
          onPressed: () => context.go(AppRoutes.login),
          child: const Text('Already have an account? Log in'),
        ),
      ),
      children: [
        if (auth.failure != null)
          AuthErrorBanner(message: auth.failure!.message),
        AppTextField(
          label: 'Email',
          hint: 'you@example.com',
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          textInputAction: TextInputAction.next,
          errorText: form.emailError,
          onChanged: formNotifier.setEmail,
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          label: 'Password',
          hint: 'Create a password',
          helper: 'At least 8 characters, with a letter and a number.',
          obscureText: !form.showPassword,
          autofillHints: const [AutofillHints.newPassword],
          textInputAction: TextInputAction.next,
          errorText: form.newPasswordError,
          suffix: TextButton(
            onPressed: formNotifier.toggleShowPassword,
            child: Text(form.showPassword ? 'Hide' : 'Show'),
          ),
          onChanged: formNotifier.setPassword,
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          label: 'Confirm password',
          hint: 'Re-enter your password',
          obscureText: !form.showPassword,
          autofillHints: const [AutofillHints.newPassword],
          textInputAction: TextInputAction.done,
          errorText: form.confirmError,
          onChanged: formNotifier.setConfirmPassword,
        ),
        const OrDivider(),
        GoogleSignInButton(
          label: 'Sign up with Google',
          onPressed: auth.isLoading ? null : signUpWithGoogle,
        ),
      ],
    );
  }
}
