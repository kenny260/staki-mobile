import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/constants/spacing.dart';
import 'package:staki_mobile/core/router/app_routes.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/text_styles.dart';
import 'package:staki_mobile/presentation/shared_widgets/shared_widgets.dart';

/// A02_Welcome
class A02WelcomePage extends StatelessWidget {
  const A02WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: AppSpacing.lg),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: StakiLogo(),
                ),
              ),
              const Spacer(),
              Text.rich(
                TextSpan(
                  text: 'Turn your financial activity into ',
                  children: [
                    TextSpan(
                      text: 'opportunity.',
                      style: AppTextStyles.display.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
                style: AppTextStyles.display.copyWith(
                  fontSize: 32,
                  height: 1.15,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: SizedBox(
                  width: 300,
                  child: Text(
                    'Build your Staki fund profile, understand your financial '
                    'standing and access funding through trusted partners.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Wrap(
                alignment: WrapAlignment.center,
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  AppBadge(label: 'BNR regulated', tone: BadgeTone.primary),
                  AppBadge(label: 'Read-only data', tone: BadgeTone.primary),
                  AppBadge(label: 'Revocable anytime', tone: BadgeTone.primary),
                ],
              ),
              const Spacer(),
              AppButton(
                label: 'Get started',
                onPressed: () => context.push(AppRoutes.roleSelect),
              ),
              const SizedBox(height: AppSpacing.sm),
              Center(
                child: TextButton(
                  onPressed: () => context.push(AppRoutes.login),
                  child: const Text('I already have an account'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
