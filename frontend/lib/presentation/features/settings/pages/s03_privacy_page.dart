import 'package:flutter/material.dart';
import 'package:staki_mobile/core/constants/spacing.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/text_styles.dart';
import 'package:staki_mobile/presentation/shared_widgets/shared_widgets.dart';

/// One titled paragraph on the privacy screen.
class _PrivacySection {
  const _PrivacySection({required this.title, required this.body});

  final String title;
  final String body;
}

/// S03_Privacy
class S03PrivacyPage extends StatelessWidget {
  const S03PrivacyPage({super.key});

  static const _sections = [
    _PrivacySection(
      title: 'What data is used',
      body: 'We only access data you explicitly authorize. This includes '
          'transaction history from MTN MoMo, bank statements, identity '
          'documents, and basic profile information.',
    ),
    _PrivacySection(
      title: 'Why it is used',
      body: 'Your data is used solely to generate your Credit Passport '
          'score, analyzing cash flow, affordability, and repayment '
          'behavior to match you with suitable lending partners.',
    ),
    _PrivacySection(
      title: 'Who it may be shared with',
      body: 'Abstracted score data is shared with regulated lending '
          'partners (e.g. Bank of Kigali) only when you apply for a loan. '
          'We do not sell your personal data.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final titleStyle = AppTextStyles.title.copyWith(color: AppColors.primary);
    final bodyStyle = AppTextStyles.subtitle.copyWith(fontSize: 12);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            ScreenHeader(
              title: 'Privacy & Data',
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.infoBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      size: 20,
                      color: AppColors.info,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'How we protect your data',
                    style: AppTextStyles.h2.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  for (final section in _sections) ...[
                    Text(section.title, style: titleStyle),
                    const SizedBox(height: 6),
                    Text(section.body, style: bodyStyle),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  _AutomatedDecisionsCard(bodyStyle: bodyStyle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AutomatedDecisionsCard extends StatelessWidget {
  const _AutomatedDecisionsCard({required this.bodyStyle});

  final TextStyle bodyStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Automated Decisions',
            style: AppTextStyles.label.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 6),
          Text(
            'Your Credit Passport involves automated profiling. If you '
            'believe your score does not reflect your true financial '
            'state, you have the right to request a manual review.',
            style: bodyStyle,
          ),
          const SizedBox(height: AppSpacing.s3),
          // TODO(Abdull-Kudus): create a review request.
          const AppOutlinedButton(
            label: 'Request Manual Review',
            onPressed: null,
          ),
        ],
      ),
    );
  }
}
