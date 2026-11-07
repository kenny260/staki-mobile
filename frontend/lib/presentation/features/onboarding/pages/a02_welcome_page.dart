import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/constants/spacing.dart';
import 'package:staki_mobile/core/router/app_routes.dart';
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const StakiLogo(size: 24),
              const Spacer(),
              const Text(
                'Turn your financial activity into opportunity.',
                style: AppTextStyles.display,
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'Build your Staki fund profile, understand your financial '
                'standing and explore funding through trusted partners.',
                style: AppTextStyles.body,
              ),
              const SizedBox(height: AppSpacing.lg),
              const Wrap(
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
