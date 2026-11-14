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

  /// Background and text pairs from the Figma status badges (DS4).
  (Color, Color) get _colors => switch (tone) {
        BadgeTone.neutral => (AppColors.surfaceAlt, AppColors.textSecondary),
        BadgeTone.primary => (AppColors.primarySoft, AppColors.primary),
        BadgeTone.success => (AppColors.successBg, AppColors.successText),
        BadgeTone.warning => (AppColors.warningBg, AppColors.warningText),
        BadgeTone.danger => (AppColors.dangerBg, AppColors.dangerText),
        BadgeTone.info => (AppColors.infoBg, AppColors.infoText),
      };

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
