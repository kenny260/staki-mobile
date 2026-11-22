import 'package:flutter/material.dart';
import 'package:staki_mobile/core/constants/spacing.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/app_icons.dart';
import 'package:staki_mobile/core/theme/text_styles.dart';

/// Small grey section label ("SECURITY").
class SettingsSectionLabel extends StatelessWidget {
  const SettingsSectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, AppSpacing.lg, 0, AppSpacing.sm),
      child: Text(
        text,
        style: AppTextStyles.navLabel.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

/// Rounded white card holding a list of rows (radius 24 in Figma).
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({
    required this.children,
    super.key,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              const Divider(height: 1, color: AppColors.border),
          ],
        ],
      ),
    );
  }
}

class SettingsRow extends StatelessWidget {
  const SettingsRow({
    required this.label,
    super.key,
    this.value,
    this.onTap,
    this.isDestructive = false,
  });

  final String label;
  final String? value;
  final VoidCallback? onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: value == null ? label : '$label, $value',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 15,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.label.copyWith(
                    color: isDestructive ? AppColors.danger : AppColors.primary,
                  ),
                ),
              ),
              if (value != null)
                Text(
                  value!,
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textSecondary),
                ),
              if (onTap != null && !isDestructive) ...[
                const SizedBox(width: 6),
                const Icon(
                  AppIcons.caretRight,
                  size: 18,
                  color: AppColors.textMuted,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
