import 'package:flutter/material.dart';
import 'package:staki_mobile/core/constants/spacing.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/text_styles.dart';
import 'package:staki_mobile/presentation/features/settings/widgets/settings_widgets.dart';
import 'package:staki_mobile/presentation/shared_widgets/shared_widgets.dart';

/// S04_Support
class S04SupportPage extends StatelessWidget {
  const S04SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            ScreenHeader(
              title: 'Help & Support',
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How can we help?',
                    style: AppTextStyles.h2.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // TODO(Binthia): wire chat and report to support.
                  const SettingsGroup(
                    children: [
                      SettingsRow(label: 'Chat with Support'),
                      SettingsRow(label: 'Report an issue'),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Automated Credit Decisions',
                    style:
                        AppTextStyles.label.copyWith(color: AppColors.primary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'If your loan application was declined or you need '
                    'help understanding an automated decision, our team '
                    'can assist with a manual review request.',
                    style: AppTextStyles.subtitle.copyWith(fontSize: 12),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const AppOutlinedButton(
                    label: 'Request Decision Help',
                    onPressed: null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
