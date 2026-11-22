import 'package:flutter/material.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/app_icons.dart';

/// Primary full-width button. Pass `onPressed: null` for the disabled state.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.showArrow = false,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool showArrow;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.onPrimary,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
                if (showArrow) ...[
                  const SizedBox(width: 6),
                  const Icon(AppIcons.arrowRight, size: 18),
                ],
              ],
            ),
    );
  }
}
