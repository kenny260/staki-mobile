import 'package:flutter/material.dart';
import 'package:staki_mobile/core/constants/spacing.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/text_styles.dart';
import 'package:staki_mobile/presentation/shared_widgets/app_badge.dart';

class ReviewItem {
  const ReviewItem(this.label, this.value);
  final String label;
  final String value;
}

/// "Review your profile" summary card (P05).
class ReviewCard extends StatelessWidget {
  const ReviewCard({
    required this.roleLabel,
    required this.items,
    super.key,
  });

  final String roleLabel;
  final List<ReviewItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
            ),
            child: Row(
              children: [
                const AppBadge(label: 'ROLE', tone: BadgeTone.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(roleLabel, style: AppTextStyles.title),
              ],
            ),
          ),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 10,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(item.label, style: AppTextStyles.caption),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Flexible(
                    child: Text(
                      item.value.isEmpty ? '-' : item.value,
                      textAlign: TextAlign.right,
                      style: AppTextStyles.label,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
