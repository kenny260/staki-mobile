import 'package:flutter/material.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/text_styles.dart';

/// "2 of 4" with the 40 x 4 progress pill from the P-frames.
class StepIndicator extends StatelessWidget {
  const StepIndicator({
    required this.step,
    required this.totalSteps,
    super.key,
  });

  final int step;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    const trackWidth = 40.0;
    final fraction = (step / totalSteps).clamp(0.0, 1.0);
    const small = TextStyle(
      fontFamily: AppTextStyles.fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppColors.textMuted,
    );
    return Semantics(
      label: 'Step $step of $totalSteps',
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$step', style: small.copyWith(color: AppColors.primary)),
            const SizedBox(width: 4),
            const Text('of', style: small),
            const SizedBox(width: 4),
            Text('$totalSteps', style: small),
            const SizedBox(width: 8),
            Stack(
              children: [
                Container(
                  width: trackWidth,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Container(
                  width: trackWidth * fraction,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
