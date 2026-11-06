import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:staki_mobile/core/constants/spacing.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/text_styles.dart';

/// Six-box OTP input backed by one invisible TextField, so paste, autofill
/// and the number keypad all work.
class OtpInput extends StatefulWidget {
  const OtpInput({
    super.key,
    this.length = 6,
    this.onChanged,
    this.onCompleted,
    this.hasError = false,
  });

  final int length;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final bool hasError;

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_refresh);
    _focus.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _handleChanged(String value) {
    widget.onChanged?.call(value);
    if (value.length == widget.length) widget.onCompleted?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final text = _controller.text;
    return Semantics(
      label: 'Enter the ${widget.length}-digit verification code',
      child: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              // Figma boxes are 48 x 56. Shrink on narrow screens.
              const gap = 8.0;
              final fit = (constraints.maxWidth - gap * (widget.length - 1)) /
                  widget.length;
              final boxWidth = fit < 48 ? fit : 48.0;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(widget.length, (i) {
                  final isActive = _focus.hasFocus &&
                      (i == text.length ||
                          (i == widget.length - 1 &&
                              text.length == widget.length));
                  final isFilled = i < text.length;
                  final borderColor = widget.hasError
                      ? AppColors.danger
                      : (isActive || isFilled)
                          ? AppColors.primary
                          : AppColors.border;
                  return Container(
                    width: boxWidth,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isFilled
                          ? AppColors.primarySoft
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: borderColor,
                        width: isActive ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      isFilled ? text[i] : '',
                      style: AppTextStyles.otpDigit,
                    ),
                  );
                }),
              );
            },
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: _controller,
                focusNode: _focus,
                autofocus: true,
                keyboardType: TextInputType.number,
                maxLength: widget.length,
                showCursor: false,
                enableInteractiveSelection: false,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                autofillHints: const [AutofillHints.oneTimeCode],
                decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                ),
                onChanged: _handleChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
