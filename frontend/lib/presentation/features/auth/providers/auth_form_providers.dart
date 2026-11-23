import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staki_mobile/core/utils/validators.dart';
import 'package:staki_mobile/presentation/shared_providers/preferences_providers.dart';

/// Field values and error display for the auth forms. Errors only show
/// after the first tap on the button, so people are not scolded mid-typing.
class AuthFormState {
  const AuthFormState({
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.showPassword = false,
    this.submitted = false,
    this.resetSent = false,
  });

  final String email;
  final String password;
  final String confirmPassword;
  final bool showPassword;
  final bool submitted;
  final bool resetSent;

  AuthFormState copyWith({
    String? email,
    String? password,
    String? confirmPassword,
    bool? showPassword,
    bool? submitted,
    bool? resetSent,
  }) {
    return AuthFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      showPassword: showPassword ?? this.showPassword,
      submitted: submitted ?? this.submitted,
      resetSent: resetSent ?? this.resetSent,
    );
  }

  String? get emailError => submitted ? Validators.email(email) : null;

  String? get loginPasswordError =>
      submitted ? Validators.requiredPassword(password) : null;

  String? get newPasswordError =>
      submitted ? Validators.newPassword(password) : null;

  String? get confirmError =>
      submitted ? Validators.confirmPassword(confirmPassword, password) : null;

  bool get loginValid =>
      Validators.email(email) == null &&
      Validators.requiredPassword(password) == null;

  bool get registerValid =>
      Validators.email(email) == null &&
      Validators.newPassword(password) == null &&
      Validators.confirmPassword(confirmPassword, password) == null;

  bool get forgotValid => Validators.email(email) == null;
}

class AuthFormNotifier extends AutoDisposeNotifier<AuthFormState> {
  @override
  AuthFormState build() => const AuthFormState();

  void setEmail(String value) => state = state.copyWith(email: value);

  void setPassword(String value) => state = state.copyWith(password: value);

  void setConfirmPassword(String value) =>
      state = state.copyWith(confirmPassword: value);

  void toggleShowPassword() =>
      state = state.copyWith(showPassword: !state.showPassword);

  void markSubmitted() => state = state.copyWith(submitted: true);

  void markResetSent() => state = state.copyWith(resetSent: true);
}

/// Login starts with the email of the last successful login, if any.
class LoginFormNotifier extends AuthFormNotifier {
  @override
  AuthFormState build() {
    try {
      final last = ref.read(preferencesProvider).lastLoginEmail;
      return AuthFormState(email: last ?? '');
    } on Object {
      // No SharedPreferences (for example a page tested on its own).
      return const AuthFormState();
    }
  }
}

// One provider per screen so the forms do not share values.
final loginFormProvider =
    NotifierProvider.autoDispose<LoginFormNotifier, AuthFormState>(
  LoginFormNotifier.new,
);

final registerFormProvider =
    NotifierProvider.autoDispose<AuthFormNotifier, AuthFormState>(
  AuthFormNotifier.new,
);

final forgotFormProvider =
    NotifierProvider.autoDispose<AuthFormNotifier, AuthFormState>(
  AuthFormNotifier.new,
);

/// Seconds left before "Resend email" works again. Not auto-disposed, so
/// the countdown started on the register page survives the navigation.
class ResendCooldownNotifier extends Notifier<int> {
  Timer? _timer;

  @override
  int build() {
    ref.onDispose(() => _timer?.cancel());
    return 0;
  }

  void start([int seconds = 60]) {
    _timer?.cancel();
    state = seconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state <= 1) {
        timer.cancel();
        state = 0;
      } else {
        state -= 1;
      }
    });
  }
}

final resendCooldownProvider =
    NotifierProvider<ResendCooldownNotifier, int>(ResendCooldownNotifier.new);
