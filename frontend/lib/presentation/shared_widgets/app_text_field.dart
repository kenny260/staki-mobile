import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/text_styles.dart';

/// Labelled text field with optional helper text, prefix and error.
class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.label,
    super.key,
    this.hint,
    this.helper,
    this.initialValue,
    this.onChanged,
    this.errorText,
    this.keyboardType,
    this.inputFormatters,
    this.prefix,
    this.maxLength,
    this.textCapitalization = TextCapitalization.none,
    this.autofocus = false,
    this.isOptional = false,
  });

  final String label;
  final String? hint;
  final String? helper;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefix;
  final int? maxLength;
  final TextCapitalization textCapitalization;
  final bool autofocus;
  final bool isOptional;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Expanded: a long label wraps instead of overflowing the row.
            Expanded(child: Text(label, style: AppTextStyles.label)),
            if (isOptional) ...[
              const SizedBox(width: 8),
              const Text('Optional', style: AppTextStyles.caption),
            ],
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          style: AppTextStyles.fieldText,
          initialValue: initialValue,
          onChanged: onChanged,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
          autofocus: autofocus,
          textCapitalization: textCapitalization,
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            counterText: '',
            prefixIcon: prefix == null
                ? null
                : Padding(
                    padding: const EdgeInsets.only(left: 14, right: 8),
                    child: prefix,
                  ),
            prefixIconConstraints: const BoxConstraints(),
          ),
        ),
        if (helper != null && errorText == null) ...[
          const SizedBox(height: 6),
          Text(
            helper!,
            style:
                AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ],
    );
  }
}
