import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:staki_mobile/core/constants/spacing.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/app_icons.dart';
import 'package:staki_mobile/core/theme/text_styles.dart';

/// PIN dots: 20 x 20 circles, filled when typed.
class PinDots extends StatelessWidget {
  const PinDots({
    required this.value,
    super.key,
    this.length = 4,
    this.reveal = false,
    this.hasError = false,
  });

  final String value;
  final int length;

  /// "Show PIN": display the digits instead of dots.
  final bool reveal;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${value.length} of $length digits entered',
      child: ExcludeSemantics(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 7),
                child: Container(
                  width: reveal && i < value.length ? 28 : 20,
                  height: 28,
                  alignment: Alignment.center,
                  child: reveal && i < value.length
                      ? Text(value[i], style: AppTextStyles.h2)
                      : Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i < value.length
                                ? AppColors.primary
                                : Colors.transparent,
                            border: Border.all(
                              color: hasError
                                  ? AppColors.danger
                                  : i < value.length
                                      ? AppColors.primary
                                      : AppColors.borderMid,
                              width: 1.5,
                            ),
                          ),
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 3 x 4 numeric keypad: keys 108 x 62, radius 16 (Figma A07b).
class PinPad extends StatelessWidget {
  const PinPad({
    required this.onDigit,
    required this.onBackspace,
    super.key,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  Widget _key(Widget child, VoidCallback? onTap, String semantic) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Semantics(
          button: true,
          label: semantic,
          excludeSemantics: true,
          child: Material(
            color: onTap == null ? Colors.transparent : AppColors.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              side: onTap == null
                  ? BorderSide.none
                  : const BorderSide(color: AppColors.border),
            ),
            child: InkWell(
              onTap: onTap == null
                  ? null
                  : () {
                      HapticFeedback.selectionClick();
                      onTap();
                    },
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: SizedBox(height: 62, child: Center(child: child)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _digit(String d) => _key(
        Text(d, style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.w600)),
        () => onDigit(d),
        d,
      );

  @override
  Widget build(BuildContext context) {
    Widget row(List<Widget> keys) => Row(children: keys);
    return Column(
      children: [
        row([_digit('1'), _digit('2'), _digit('3')]),
        row([_digit('4'), _digit('5'), _digit('6')]),
        row([_digit('7'), _digit('8'), _digit('9')]),
        row([
          _key(const SizedBox.shrink(), null, ''),
          _digit('0'),
          _key(
            const Icon(
              AppIcons.backspace,
              color: AppColors.textSecondary,
            ),
            onBackspace,
            'Delete',
          ),
        ]),
      ],
    );
  }
}
