import 'package:flutter/material.dart';
import 'package:staki_mobile/core/constants/spacing.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/text_styles.dart';
import 'package:staki_mobile/presentation/shared_widgets/app_button.dart';
import 'package:staki_mobile/presentation/shared_widgets/step_indicator.dart';

/// Shared layout for onboarding and profile-setup steps, built from the
/// Figma P-frames: "Back" + "n of N" with a small progress bar, heading,
/// scrolling body, and a white bottom bar with a top border holding the CTA.
class StepScaffold extends StatelessWidget {
  const StepScaffold({
    required this.heading,
    required this.children,
    super.key,
    this.subheading,
    this.step,
    this.totalSteps,
    this.appBarTitle,
    this.ctaLabel,
    this.onCta,
    this.ctaShowArrow = false,
    this.footerText,
    this.bottomExtra,
  });

  final String heading;
  final String? subheading;
  final List<Widget> children;

  /// Shows "step of totalSteps" with a progress bar when both are set.
  final int? step;
  final int? totalSteps;

  /// When set (account screens), the top bar shows a bold title and a thin
  /// full-width progress line instead of "Back" and the small indicator.
  final String? appBarTitle;

  final String? ctaLabel;
  final VoidCallback? onCta;
  final bool ctaShowArrow;
  final String? footerText;
  final Widget? bottomExtra;

  bool get _hasProgress => step != null && totalSteps != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              appBarTitle: appBarTitle,
              step: step,
              totalSteps: totalSteps,
            ),
            if (_hasProgress && appBarTitle != null)
              LinearProgressIndicator(
                value: step! / totalSteps!,
                minHeight: 2,
                backgroundColor: AppColors.border,
                color: AppColors.primary,
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  AppSpacing.md,
                  AppSpacing.screenPadding,
                  AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(heading, style: AppTextStyles.h1),
                    if (subheading != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(subheading!, style: AppTextStyles.subtitle),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    ...children,
                  ],
                ),
              ),
            ),
            if (ctaLabel != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  AppSpacing.md,
                  AppSpacing.screenPadding,
                  AppSpacing.md,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (bottomExtra != null) bottomExtra!,
                    AppButton(
                      label: ctaLabel!,
                      onPressed: onCta,
                      showArrow: ctaShowArrow,
                    ),
                    if (footerText != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(footerText!, style: AppTextStyles.caption),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({this.appBarTitle, this.step, this.totalSteps});

  final String? appBarTitle;
  final int? step;
  final int? totalSteps;

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final showIndicator =
        appBarTitle == null && step != null && totalSteps != null;
    return SizedBox(
      height: 52,
      child: Row(
        children: [
          if (canPop && appBarTitle != null)
            IconButton(
              tooltip: 'Back',
              icon: const Icon(Icons.chevron_left_rounded, size: 28),
              onPressed: () => Navigator.of(context).maybePop(),
            )
          else if (canPop)
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.sm),
              child: TextButton.icon(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(
                  Icons.chevron_left_rounded,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                label: Text(
                  'Back',
                  style: AppTextStyles.label.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            )
          else
            const SizedBox(width: AppSpacing.md),
          if (appBarTitle != null)
            Expanded(child: Text(appBarTitle!, style: AppTextStyles.title))
          else
            const Spacer(),
          if (showIndicator)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.screenPadding),
              child: StepIndicator(step: step!, totalSteps: totalSteps!),
            ),
        ],
      ),
    );
  }
}
