import 'package:flutter/material.dart';
import 'package:staki_mobile/core/constants/spacing.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/text_styles.dart';

enum BadgeTone { neutral, primary, success, warning, danger, info }

class AppBadge extends StatelessWidget {
  const AppBadge({
    required this.label,
    super.key,
    this.tone = BadgeTone.neutral,
  });

  final String label;
  final BadgeTone tone;

  Color get _fg => switch (tone) {
        BadgeTone.neutral => AppColors.textSecondary,
        BadgeTone.primary => AppColors.primary,
        BadgeTone.success => AppColors.success,
        BadgeTone.warning => AppColors.warning,
        BadgeTone.danger => AppColors.danger,
        BadgeTone.info => AppColors.info,
      };

  @override
  Widget build(BuildContext context) {
    final bg =
        tone == BadgeTone.neutral ? AppColors.surfaceAlt : _fg.withAlpha(28);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: _fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
