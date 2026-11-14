import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/app_icons.dart';

/// Six boxes showing the digits typed into a hidden text field.
class OtpBoxes extends StatelessWidget {
  const OtpBoxes({
    required this.controller,
    required this.focusNode,
    super.key,
    this.hasError = false,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasError;

  static const length = 6;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      textField: true,
      label: '6 digit verification code',
      child: SizedBox(
        height: 52,
        child: Stack(
          children: [
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var i = 0; i < length; i++)
                    _Box(
                      char: i < value.text.length ? value.text[i] : '',
                      error: hasError,
                    ),
                ],
              ),
            ),
            Positioned.fill(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(length),
                ],
                showCursor: false,
                enableInteractiveSelection: false,
                style: const TextStyle(color: Colors.transparent),
                decoration: const InputDecoration(
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  counterText: '',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({required this.char, required this.error});

  final String char;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final filled = char.isNotEmpty;
    return Container(
      width: 44,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: error
              ? AppColors.danger
              : (filled ? AppColors.primary : AppColors.border),
        ),
      ),
      child: Text(
        char,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

/// Four dots showing how many PIN digits are entered.
class PinDots extends StatelessWidget {
  const PinDots({required this.filled, super.key});

  final int filled;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$filled of 4 digits entered',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 4; i++)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < filled ? AppColors.primary : AppColors.border,
              ),
            ),
        ],
      ),
    );
  }
}

/// Number keypad: 1-9, 0 and delete.
class PinPad extends StatelessWidget {
  const PinPad({required this.onDigit, required this.onDelete, super.key});

  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    Widget digit(String value) => Expanded(
          child: Semantics(
            button: true,
            label: value,
            child: InkWell(
              onTap: () => onDigit(value),
              child: SizedBox(
                height: 52,
                child: Center(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

    return Column(
      children: [
        for (final row in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ])
          Row(children: [for (final d in row) digit(d)]),
        Row(
          children: [
            const Expanded(child: SizedBox(height: 52)),
            digit('0'),
            Expanded(
              child: Semantics(
                button: true,
                label: 'Delete',
                child: InkWell(
                  onTap: onDelete,
                  child: const SizedBox(
                    height: 52,
                    child: Icon(
                      AppIcons.backspace,
                      size: 22,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
