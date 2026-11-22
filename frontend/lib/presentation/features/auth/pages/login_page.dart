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

/// Login (email and password, or Google).
class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(loginFormProvider);
    final formNotifier = ref.read(loginFormProvider.notifier);
    final auth = ref.watch(authControllerProvider);
    final controller = ref.read(authControllerProvider.notifier);

    Future<void> goToLanding() async {
      final location = await controller.landingLocation();
      if (context.mounted) context.go(location);
    }

    Future<void> submit() async {
      formNotifier.markSubmitted();
      if (!form.loginValid) return;
      final ok = await controller.signIn(form.email, form.password);
      if (ok) await goToLanding();
    }

    Future<void> signInWithGoogle() async {
      final ok = await controller.signInWithGoogle();
      if (ok) await goToLanding();
    }

    return StepScaffold(
      appBarTitle: 'Log in',
      heading: 'Welcome back',
      subheading: 'Log in to continue to your Staki fund account.',
      ctaLabel: auth.isLoading ? 'Logging in...' : 'Log in',
      onCta: auth.isLoading ? null : submit,
      bottomExtra: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.sm),
        child: TextButton(
          onPressed: () => context.go(AppRoutes.roleSelect),
          child: const Text('New to Staki? Create an account'),
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
          hint: 'Enter your password',
          obscureText: !form.showPassword,
          autofillHints: const [AutofillHints.password],
          textInputAction: TextInputAction.done,
          errorText: form.loginPasswordError,
          suffix: TextButton(
            onPressed: formNotifier.toggleShowPassword,
            child: Text(form.showPassword ? 'Hide' : 'Show'),
          ),
          onChanged: formNotifier.setPassword,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => context.push(AppRoutes.forgotPassword),
            child: const Text('Forgot password?'),
          ),
        ),
        const OrDivider(),
        GoogleSignInButton(
          onPressed: auth.isLoading ? null : signInWithGoogle,
        ),
      ],
    );
  }
}
