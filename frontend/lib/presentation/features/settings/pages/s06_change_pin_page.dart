import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staki_mobile/core/constants/spacing.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/text_styles.dart';
import 'package:staki_mobile/data/datasources/pin_store.dart';
import 'package:staki_mobile/presentation/features/auth/providers/auth_providers.dart';
import 'package:staki_mobile/presentation/shared_widgets/shared_widgets.dart';

enum _Step { loading, current, fresh, confirm, locked }

/// S06_ChangePIN: current PIN (if one is saved on this phone), then the
/// new PIN twice. Accounts with no PIN yet go straight to setting one.
class S06ChangePinPage extends ConsumerStatefulWidget {
  const S06ChangePinPage({super.key});

  static const maxAttempts = 5;
  static const pinLength = 4;

  @override
  ConsumerState<S06ChangePinPage> createState() => _S06ChangePinPageState();
}

class _S06ChangePinPageState extends ConsumerState<S06ChangePinPage> {
  _Step _step = _Step.loading;
  bool _hadPin = false;
  String _entry = '';
  String _currentPin = '';
  String _newPin = '';
  String? _error;
  int _wrongAttempts = 0;
  bool _busy = false;

  String? get _uid => ref.read(authStateProvider).valueOrNull?.uid;

  @override
  void initState() {
    super.initState();
    unawaited(_start());
  }

  Future<void> _start() async {
    // Waits for the signed-in user if the auth stream has not emitted yet.
    final user = await ref.read(authStateProvider.future);
    final uid = user?.uid;
    final has = uid != null && await ref.read(pinStoreProvider).hasPin(uid);
    if (!mounted) return;
    setState(() {
      _hadPin = has;
      _step = has ? _Step.current : _Step.fresh;
    });
  }

  void _add(String digit) {
    if (_busy || _entry.length >= S06ChangePinPage.pinLength) return;
    setState(() {
      _entry += digit;
      _error = null;
    });
    if (_entry.length == S06ChangePinPage.pinLength) {
      final pin = _entry;
      unawaited(
        Future<void>.delayed(
          const Duration(milliseconds: 150),
          () => _completed(pin),
        ),
      );
    }
  }

  void _backspace() {
    if (_busy || _entry.isEmpty) return;
    setState(() => _entry = _entry.substring(0, _entry.length - 1));
  }

  void _fail(String message, {_Step? step}) => setState(() {
        _entry = '';
        _error = message;
        if (step != null) _step = step;
      });

  Future<void> _completed(String pin) async {
    if (!mounted) return;
    final uid = _uid;
    if (uid == null) return _fail('You are signed out. Log in again.');
    final store = ref.read(pinStoreProvider);

    switch (_step) {
      case _Step.current:
        setState(() => _busy = true);
        final ok = await store.verify(uid, pin);
        if (!mounted) return;
        setState(() => _busy = false);
        if (ok) {
          _currentPin = pin;
          setState(() {
            _entry = '';
            _step = _Step.fresh;
          });
        } else {
          _wrongAttempts++;
          final left = S06ChangePinPage.maxAttempts - _wrongAttempts;
          if (left <= 0) {
            _fail(
              'Too many wrong attempts. Log out and log in again to '
              'reset your PIN.',
              step: _Step.locked,
            );
          } else {
            _fail('Wrong PIN. $left ${left == 1 ? 'try' : 'tries'} left.');
          }
        }
      case _Step.fresh:
        if (_hadPin && pin == _currentPin) {
          return _fail('Choose a PIN different from your current one.');
        }
        _newPin = pin;
        setState(() {
          _entry = '';
          _step = _Step.confirm;
        });
      case _Step.confirm:
        if (pin != _newPin) {
          return _fail(
            'PINs do not match. Enter your new PIN again.',
            step: _Step.fresh,
          );
        }
        setState(() => _busy = true);
        final messenger = ScaffoldMessenger.of(context);
        final navigator = Navigator.of(context);
        try {
          await store.save(uid, pin);
          messenger.showSnackBar(
            SnackBar(
              content: Text(_hadPin ? 'Your PIN was changed.' : 'PIN set.'),
            ),
          );
          unawaited(navigator.maybePop());
        } on Object {
          if (mounted) {
            setState(() => _busy = false);
            _fail('We could not save your PIN. Try again.', step: _Step.fresh);
          }
        }
      case _Step.loading:
      case _Step.locked:
        return;
    }
  }

  (String, String) get _copy => switch (_step) {
        _Step.loading => ('Change PIN', ''),
        _Step.current => (
            'Enter your current PIN',
            'To keep your account safe, confirm it is you.',
          ),
        _Step.fresh => _hadPin
            ? ('Enter a new PIN', 'Choose 4 digits you will remember.')
            : (
                'Set your PIN',
                'No PIN is saved on this phone yet. Choose 4 digits.',
              ),
        _Step.confirm => ('Confirm your new PIN', 'Enter the same 4 digits.'),
        _Step.locked => ('PIN locked', ''),
      };

  @override
  Widget build(BuildContext context) {
    final (heading, subtitle) = _copy;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              title:
                  _hadPin || _step == _Step.loading ? 'Change PIN' : 'Set PIN',
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: _step == _Step.loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: const EdgeInsets.all(AppSpacing.screenPadding),
                      children: [
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          heading,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.h2
                              .copyWith(color: AppColors.primary),
                        ),
                        if (subtitle.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            subtitle,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.subtitle,
                          ),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                        PinDots(
                          value: _entry,
                          hasError: _error != null,
                        ),
                        const SizedBox(height: AppSpacing.s3),
                        SizedBox(
                          height: 40,
                          child: Center(
                            child: Text(
                              _error ?? '',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.caption
                                  .copyWith(color: AppColors.danger),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        if (_step != _Step.locked)
                          PinPad(onDigit: _add, onBackspace: _backspace),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
