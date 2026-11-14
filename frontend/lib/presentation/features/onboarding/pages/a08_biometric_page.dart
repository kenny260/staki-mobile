import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/constants/spacing.dart';
import 'package:staki_mobile/core/router/app_routes.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/app_icons.dart';
import 'package:staki_mobile/core/theme/text_styles.dart';
import 'package:staki_mobile/presentation/shared_widgets/shared_widgets.dart';

/// A08_Biometric
class A08BiometricPage extends StatelessWidget {
  const A08BiometricPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StepScaffold(
      heading: 'Faster, safer login',
      ctaLabel: 'Enable biometrics',
      // TODO(Tolu): request biometrics with local_auth, then continue.
      onCta: () => context.push(AppRoutes.accountCreated),
      bottomExtra: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.s3),
        child: TextButton(
          onPressed: () => context.push(AppRoutes.accountCreated),
          child: const Text('Not now'),
        ),
      ),
      children: [
        Center(
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              AppIcons.fingerprint,
              size: 48,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const Center(
          child: Text(
            'Use biometrics to log in',
            textAlign: TextAlign.center,
            style: AppTextStyles.h1,
          ),
        ),
        const SizedBox(height: AppSpacing.s3),
        const Text(
          'Use your fingerprint or Face ID for quick, secure access. '
          'You can always use your PIN instead.',
          textAlign: TextAlign.center,
          style: AppTextStyles.body,
        ),
        const SizedBox(height: AppSpacing.lg),
        const _Benefit(
          icon: AppIcons.lightning,
          title: 'Log in instantly',
          subtitle: 'No PIN needed on trusted devices',
        ),
        const _Benefit(
          icon: AppIcons.shieldCheck,
          title: 'Just as secure',
          subtitle: "Backed by your device's secure enclave",
        ),
        const _Benefit(
          icon: AppIcons.arrowCounterClockwise,
          title: 'Revocable anytime',
          subtitle: 'Remove biometrics from your settings',
        ),
      ],
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 14, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.label),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
