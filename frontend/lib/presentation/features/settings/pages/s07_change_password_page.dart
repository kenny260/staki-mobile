import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staki_mobile/core/constants/spacing.dart';
import 'package:staki_mobile/core/errors/auth_failure.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/text_styles.dart';
import 'package:staki_mobile/core/utils/validators.dart';
import 'package:staki_mobile/presentation/features/auth/providers/auth_providers.dart';
import 'package:staki_mobile/presentation/shared_widgets/shared_widgets.dart';

/// S07_ChangePassword: current password, new password, confirm. Accounts
/// that sign in with Google have no Staki password to change.
class S07ChangePasswordPage extends ConsumerStatefulWidget {
  const S07ChangePasswordPage({super.key});

  @override
  ConsumerState<S07ChangePasswordPage> createState() =>
      _S07ChangePasswordPageState();
}

class _S07ChangePasswordPageState extends ConsumerState<S07ChangePasswordPage> {
  String _current = '';
  String _new = '';
  String _confirm = '';
  bool _submitted = false;
  bool _show = false;
  bool _saving = false;
  String? _failure;

  String? get _currentError =>
      _submitted ? Validators.requiredPassword(_current) : null;

  String? get _newError {
    if (!_submitted) return null;
    final rule = Validators.newPassword(_new);
    if (rule != null) return rule;
    if (_new == _current) return 'Choose a password you have not used here.';
    return null;
  }

  String? get _confirmError =>
      _submitted ? Validators.confirmPassword(_confirm, _new) : null;

  Future<void> _save() async {
    setState(() {
      _submitted = true;
      _failure = null;
    });
    if (_currentError != null || _newError != null || _confirmError != null) {
      return;
    }
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      await ref.read(changePasswordProvider)(_current, _new);
      // Lets the phone's password manager update the saved password.
      TextInput.finishAutofillContext();
      messenger.showSnackBar(
        const SnackBar(content: Text('Your password was changed.')),
      );
      await navigator.maybePop();
    } on AuthFailure catch (f) {
      if (mounted) setState(() => _failure = f.message);
    } on Object {
      if (mounted) {
        setState(() => _failure = 'Something went wrong. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final isGoogle = user?.isGoogle ?? false;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              title: 'Change password',
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: isGoogle ? const _GoogleAccount() : _form(user?.email),
            ),
            if (!isGoogle)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  AppSpacing.sm,
                  AppSpacing.screenPadding,
                  AppSpacing.md,
                ),
                child: AppButton(
                  label: 'Change password',
                  isLoading: _saving,
                  onPressed: _saving ? null : _save,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _form(String? email) {
    Widget toggle() => TextButton(
          onPressed: () => setState(() => _show = !_show),
          child: Text(_show ? 'Hide' : 'Show'),
        );

    return AutofillGroup(
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          if (email != null) ...[
            Text(
              'Signed in as $email',
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          if (_failure != null) ...[
            Text(
              _failure!,
              style: AppTextStyles.caption.copyWith(color: AppColors.danger),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          AppTextField(
            // Keys keep each box's text in place when the error line
            // appears above them (ListView matches children by position).
            key: const ValueKey('current'),
            label: 'Current password',
            obscureText: !_show,
            autofillHints: const [AutofillHints.password],
            textInputAction: TextInputAction.next,
            errorText: _currentError,
            suffix: toggle(),
            onChanged: (v) => setState(() => _current = v),
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            key: const ValueKey('new'),
            label: 'New password',
            helper: 'At least 8 characters, with a letter and a number.',
            obscureText: !_show,
            autofillHints: const [AutofillHints.newPassword],
            textInputAction: TextInputAction.next,
            errorText: _newError,
            onChanged: (v) => setState(() => _new = v),
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            key: const ValueKey('confirm'),
            label: 'Confirm new password',
            obscureText: !_show,
            autofillHints: const [AutofillHints.newPassword],
            textInputAction: TextInputAction.done,
            errorText: _confirmError,
            onChanged: (v) => setState(() => _confirm = v),
          ),
        ],
      ),
    );
  }
}

class _GoogleAccount extends StatelessWidget {
  const _GoogleAccount();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.screenPadding),
      child: Text(
        'You sign in with Google, so there is no Staki password to change. '
        'Manage your password in your Google account.',
        style: AppTextStyles.subtitle,
      ),
    );
  }
}
