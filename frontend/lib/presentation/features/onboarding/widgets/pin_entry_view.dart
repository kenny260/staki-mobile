import 'package:flutter/material.dart';
import 'package:staki_mobile/core/constants/spacing.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/app_icons.dart';
import 'package:staki_mobile/core/theme/text_styles.dart';
import 'package:staki_mobile/presentation/shared_widgets/shared_widgets.dart';

/// Shared body for A07_CreatePIN and A07b_ConfirmPIN: heading, Set/Confirm
/// stepper, dots, "Show PIN" and the keypad. Typing and show/hide are local
/// UI state; the PIN itself is handed to the page through [onCompleted].
class PinEntryView extends StatefulWidget {
  const PinEntryView({
    required this.heading,
    required this.subtitle,
    required this.activeStep,
    required this.onCompleted,
    super.key,
    this.errorText,
    this.pinLength = 4,
  });

  final String heading;
  final String subtitle;

  /// 1 = "Set", 2 = "Confirm".
  final int activeStep;
  final ValueChanged<String> onCompleted;
  final String? errorText;
  final int pinLength;

  @override
  State<PinEntryView> createState() => _PinEntryViewState();
}

class _PinEntryViewState extends State<PinEntryView> {
  String _pin = '';
  bool _show = false;

  @override
  void didUpdateWidget(covariant PinEntryView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A new error means the attempt failed: clear the dots to retry.
    if (widget.errorText != null && widget.errorText != oldWidget.errorText) {
      setState(() => _pin = '');
    }
  }

  void _add(String digit) {
    if (_pin.length >= widget.pinLength) return;
    setState(() => _pin += digit);
    if (_pin.length == widget.pinLength) {
      final done = _pin;
      Future<void>.delayed(const Duration(milliseconds: 150), () {
        if (mounted) widget.onCompleted(done);
      });
    }
  }

  void _backspace() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    return StepScaffold(
      heading: widget.heading,
      children: [
        _Stepper(activeStep: widget.activeStep),
        const SizedBox(height: AppSpacing.md),
        Center(child: Text(widget.subtitle, style: AppTextStyles.subtitle)),
        const SizedBox(height: AppSpacing.lg),
        PinDots(
          value: _pin,
          length: widget.pinLength,
          reveal: _show,
          hasError: widget.errorText != null,
        ),
        const SizedBox(height: AppSpacing.s3),
        Center(
          child: widget.errorText != null
              ? Text(
                  widget.errorText!,
                  style:
                      AppTextStyles.caption.copyWith(color: AppColors.danger),
                )
              : TextButton(
                  onPressed: () => setState(() => _show = !_show),
                  child: Text(_show ? 'Hide PIN' : 'Show PIN'),
                ),
        ),
        const SizedBox(height: AppSpacing.md),
        PinPad(onDigit: _add, onBackspace: _backspace),
      ],
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.activeStep});

  final int activeStep;

  Widget _circle(int n) {
    final done = n < activeStep;
    final active = n == activeStep;
    return Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done
            ? AppColors.success
            : active
                ? AppColors.primary
                : AppColors.border,
      ),
      child: done
          ? const Icon(AppIcons.check, size: 12, color: AppColors.onPrimary)
          : Text(
              '$n',
              style: AppTextStyles.navLabel.copyWith(
                fontWeight: FontWeight.w700,
                color: active ? AppColors.onPrimary : AppColors.textMuted,
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _circle(1),
        const SizedBox(width: 6),
        Text(
          'Set',
          style: AppTextStyles.caption.copyWith(
            color: activeStep > 1 ? AppColors.success : AppColors.textPrimary,
          ),
        ),
        Container(
          width: 32,
          height: 1,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          color: AppColors.border,
        ),
        _circle(2),
        const SizedBox(width: 6),
        Text(
          'Confirm',
          style: AppTextStyles.caption.copyWith(
            color:
                activeStep == 2 ? AppColors.textPrimary : AppColors.textMuted,
            fontWeight: activeStep == 2 ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
