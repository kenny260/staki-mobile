import 'package:flutter/material.dart';
import 'package:staki_mobile/core/constants/spacing.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/text_styles.dart';
import 'package:staki_mobile/presentation/shared_widgets/shared_widgets.dart';

/// Shared body for A04_BorrowerConfirmed and A04c_LenderConfirmed.
class RoleConfirmedView extends StatelessWidget {
  const RoleConfirmedView({
    required this.icon,
    required this.title,
    required this.message,
    required this.onContinue,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    const centered = TextAlign.center;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _IconTile(icon: icon),
                    const SizedBox(height: AppSpacing.lg),
                    Text(title, style: AppTextStyles.h2, textAlign: centered),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      message,
                      style: AppTextStyles.body,
                      textAlign: centered,
                    ),
                  ],
                ),
              ),
              AppButton(
                label: 'Create my account',
                showArrow: true,
                onPressed: onContinue,
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Secured · BNR Regulated · Rwanda',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Icon(icon, color: AppColors.primary, size: 28),
    );
  }
}
