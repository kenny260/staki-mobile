import 'package:flutter/material.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/text_styles.dart';

/// Placeholder wordmark. Swap for the exported SVG logo from Figma.
class StakiLogo extends StatelessWidget {
  const StakiLogo({super.key, this.size = 28});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Staki fund',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.show_chart_rounded, size: size, color: AppColors.primary),
          Text(
            'Staki fund',
            style: AppTextStyles.title.copyWith(
              color: AppColors.primary,
              fontSize: size * 0.55,
            ),
          ),
        ],
      ),
    );
  }
}
