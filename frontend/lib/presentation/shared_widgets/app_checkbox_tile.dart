import 'package:flutter/material.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/app_icons.dart';
import 'package:staki_mobile/core/theme/text_styles.dart';

/// Checkbox + label (Figma CHECKBOXES): 18 x 18 box, radius 5. Checked =
/// primary fill with a white tick; unchecked = borderMid outline.
/// Pass `onChanged: null` for the disabled state.
class AppCheckboxTile extends StatelessWidget {
  const AppCheckboxTile({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;

  bool get _enabled => onChanged != null;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      checked: value,
      enabled: _enabled,
      label: label,
      child: InkWell(
        onTap: _enabled ? () => onChanged!(!value) : null,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                width: 18,
                height: 18,
                margin: const EdgeInsets.only(top: 1),
                decoration: BoxDecoration(
                  color: value
                      ? (_enabled ? AppColors.primary : AppColors.textMuted)
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: value
                        ? (_enabled ? AppColors.primary : AppColors.textMuted)
                        : AppColors.borderMid,
                  ),
                ),
                child: value
                    ? const Icon(
                        AppIcons.check,
                        size: 12,
                        color: AppColors.onPrimary,
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ExcludeSemantics(
                  child: Text(
                    label,
                    style: AppTextStyles.fieldText.copyWith(
                      color: _enabled
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
