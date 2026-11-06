import 'package:flutter/material.dart';
import 'package:staki_mobile/core/constants/spacing.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/text_styles.dart';
import 'package:staki_mobile/presentation/shared_widgets/app_button.dart';
import 'package:staki_mobile/presentation/shared_widgets/app_outlined_button.dart';
import 'package:staki_mobile/presentation/shared_widgets/edge_case.dart';

/// One reusable screen for every edge case, E01 to E34.
///
///   StateScreen(type: EdgeCaseType.offline, onPrimary: retry)
///
/// Title, message, tone, icon and button labels come from [EdgeCaseType];
/// override the labels only if a screen needs different wording.
/// If a callback is null, the button just goes back.
class StateScreen extends StatelessWidget {
  const StateScreen({
    required this.type,
    super.key,
    this.onPrimary,
    this.onSecondary,
    this.title,
    this.message,
    this.primaryLabel,
    this.secondaryLabel,
  });

  final EdgeCaseType type;
  final VoidCallback? onPrimary;
  final VoidCallback? onSecondary;
  final String? title;
  final String? message;
  final String? primaryLabel;
  final String? secondaryLabel;

  @override
  Widget build(BuildContext context) {
    final c = type.content;
    return Scaffold(
      body: SafeArea(
        child: switch (type) {
          EdgeCaseType.skeleton => const _SkeletonView(),
          EdgeCaseType.loading => _Body(
              leading: const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
              title: title ?? c.title,
              message: message ?? c.message,
              titleStyle: AppTextStyles.h2.copyWith(color: AppColors.primary),
            ),
          _ => _MessageView(
              content: c,
              title: title,
              message: message,
              primaryLabel: primaryLabel,
              secondaryLabel: secondaryLabel,
              onPrimary: onPrimary ?? () => Navigator.of(context).maybePop(),
              onSecondary:
                  onSecondary ?? () => Navigator.of(context).maybePop(),
            ),
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.leading,
    required this.title,
    required this.message,
    this.titleStyle,
  });

  final Widget leading;
  final String title;
  final String message;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      container: true,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              leading,
              const SizedBox(height: AppSpacing.lg),
              Text(
                title,
                textAlign: TextAlign.center,
                style: titleStyle ??
                    AppTextStyles.h1.copyWith(color: AppColors.primary),
              ),
              if (message.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.s3),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.subtitle
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageView extends StatelessWidget {
  const _MessageView({
    required this.content,
    required this.onPrimary,
    required this.onSecondary,
    this.title,
    this.message,
    this.primaryLabel,
    this.secondaryLabel,
  });

  final EdgeCaseContent content;
  final VoidCallback onPrimary;
  final VoidCallback onSecondary;
  final String? title;
  final String? message;
  final String? primaryLabel;
  final String? secondaryLabel;

  (Color, Color) get _tone => switch (content.tone) {
        EdgeCaseTone.error => (AppColors.dangerBg, AppColors.danger),
        EdgeCaseTone.warning => (AppColors.warningBg, AppColors.warning),
        EdgeCaseTone.info => (AppColors.infoBg, AppColors.info),
        EdgeCaseTone.neutral => (AppColors.surface, AppColors.textSecondary),
      };

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _tone;
    final primary = primaryLabel ?? content.primaryLabel;
    final secondary = secondaryLabel ?? content.secondaryLabel;

    return Column(
      children: [
        Expanded(
          child: _Body(
            leading: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(AppRadius.xxl + 4),
                border: content.tone == EdgeCaseTone.neutral
                    ? Border.all(color: AppColors.border)
                    : null,
              ),
              child: Icon(content.icon, size: 36, color: fg),
            ),
            title: title ?? content.title,
            message: message ?? content.message,
          ),
        ),
        if (primary != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.sm,
              AppSpacing.screenPadding,
              AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppButton(label: primary, onPressed: onPrimary),
                if (secondary != null) ...[
                  const SizedBox(height: AppSpacing.s3),
                  AppOutlinedButton(label: secondary, onPressed: onSecondary),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

/// E02: pulsing placeholder blocks shaped like the dashboard.
class _SkeletonView extends StatefulWidget {
  const _SkeletonView();

  @override
  State<_SkeletonView> createState() => _SkeletonViewState();
}

class _SkeletonViewState extends State<_SkeletonView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _block(double height, {double? width, double radius = 20}) =>
      Container(
        width: width,
        height: height,
        margin: const EdgeInsets.only(bottom: AppSpacing.s3),
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(radius),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading content',
      child: ExcludeSemantics(
        child: FadeTransition(
          opacity: Tween<double>(begin: 0.45, end: 1).animate(_controller),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            children: [
              _block(43),
              const SizedBox(height: AppSpacing.md),
              _block(32, width: 263, radius: 16),
              const SizedBox(height: AppSpacing.md),
              _block(128, radius: 24),
              _block(64),
              _block(64),
              _block(64),
            ],
          ),
        ),
      ),
    );
  }
}
