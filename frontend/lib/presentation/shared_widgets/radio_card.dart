import 'package:flutter/material.dart';
import 'package:staki_mobile/core/constants/spacing.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/app_icons.dart';
import 'package:staki_mobile/core/theme/text_styles.dart';
import 'package:staki_mobile/presentation/shared_widgets/app_badge.dart';

/// Selectable card used for role and borrower-type choices.
class RadioCard extends StatelessWidget {
  const RadioCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    super.key,
    this.badgeLabel,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final String? badgeLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '$title. $subtitle',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: selected ? AppColors.primarySoft : AppColors.background,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color:
                      selected ? AppColors.onPrimary : AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (badgeLabel != null) ...[
                      AppBadge(label: badgeLabel!),
                      const SizedBox(height: 6),
                    ],
                    Text(title, style: AppTextStyles.title),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTextStyles.caption),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? AppColors.primary : Colors.transparent,
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: selected
                    ? const Icon(
                        AppIcons.check,
                        size: 14,
                        color: AppColors.onPrimary,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
