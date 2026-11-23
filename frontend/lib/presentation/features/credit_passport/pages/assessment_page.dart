import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/router/app_routes.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/app_icons.dart';
import 'package:staki_mobile/data/datasources/scoring_datasource.dart';
import 'package:staki_mobile/presentation/features/credit_passport/providers/credit_passport_models.dart';
import 'package:staki_mobile/presentation/features/credit_passport/providers/credit_passport_provider.dart';
import 'package:staki_mobile/presentation/features/credit_passport/providers/scoring_providers.dart';
import 'package:staki_mobile/presentation/features/credit_passport/widgets/passport_app_bar.dart';

/// C01: asks the server for the score once, then moves on by the result.
class AssessmentPage extends ConsumerWidget {
  const AssessmentPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(scoringResultProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PassportAppBar(title: 'Assessment'),
      body: result.when(
        loading: () => const _ProcessingView(),
        error: (error, _) => error is ScoringSessionExpiredException
            ? const _SessionExpiredView()
            : const _FailedView(),
        data: (r) => r.status == AssessmentStatus.needsInfo
            ? const _NeedsInfoView()
            : const _CompleteView(),
      ),
    );
  }
}

/// Scrollable content with an optional pinned bottom area.
class _StatusLayout extends StatelessWidget {
  const _StatusLayout({required this.children, this.bottom});

  final List<Widget> children;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(height: 1, color: AppColors.border),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
        if (bottom != null)
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: bottom,
            ),
          ),
      ],
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(icon, color: color, size: 30),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text, {this.center = false, this.size = 20});

  final String text;
  final bool center;
  final double size;

  @override
  Widget build(BuildContext context) => Text(
        text,
        textAlign: center ? TextAlign.center : TextAlign.start,
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
        ),
      );
}

class _Body extends StatelessWidget {
  const _Body(this.text, {this.center = false});

  final String text;
  final bool center;

  @override
  Widget build(BuildContext context) => Text(
        text,
        textAlign: center ? TextAlign.center : TextAlign.start,
        style: const TextStyle(
          fontSize: 14,
          height: 1.4,
          color: AppColors.textSecondary,
        ),
      );
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onTap, this.icon});

  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        shape: const StadiumBorder(),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

// ---------- C01_Processing (while the server works) ----------
class _ProcessingView extends ConsumerWidget {
  const _ProcessingView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checks = ref.watch(dataChecksProvider);
    return _StatusLayout(
      bottom: const Text(
        'This typically takes a few moments. Please do not close the app.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
      children: [
        const SizedBox(height: 16),
        Center(
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: const Icon(
              AppIcons.pulse,
              size: 36,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Center(
          child: _Heading(
            'Building your Credit\nPassport',
            center: true,
            size: 24,
          ),
        ),
        const SizedBox(height: 12),
        const _Body(
          "We're analyzing the financial information you've authorized to "
          'understand cash flow, consistency and affordability.',
          center: true,
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'DATA CHECKS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 14),
              ...checks.map((c) => _CheckRow(check: c)),
            ],
          ),
        ),
      ],
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({required this.check});

  final DataCheck check;

  @override
  Widget build(BuildContext context) {
    final Widget leading;
    switch (check.state) {
      case CheckState.done:
        leading = const Icon(
          AppIcons.checkCircle,
          size: 18,
          color: AppColors.success,
        );
      case CheckState.active:
        leading = const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        );
      case CheckState.pending:
        leading = const Icon(AppIcons.circle, size: 8, color: AppColors.border);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(width: 20, child: Center(child: leading)),
          const SizedBox(width: 12),
          Text(
            check.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: check.state == CheckState.active
                  ? FontWeight.w700
                  : FontWeight.w400,
              color: check.state == CheckState.pending
                  ? AppColors.textMuted
                  : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- C01b_NeedsInfo ----------
class _NeedsInfoView extends ConsumerWidget {
  const _NeedsInfoView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The API does not say which document is the problem yet.
    final issue = ref.watch(needsInfoIssueProvider);
    return _StatusLayout(
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PrimaryButton(
            label: 'Update Document',
            onTap: () => context.go(AppRoutes.documents),
          ),
          // Dev-only escape hatch: kDebugMode is false in release builds, so
          // real users never see this and cannot skip a paused assessment.
          if (kDebugMode) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                // No real score was saved, so the loan screens would show
                // "no offers". This makes them use sample data instead.
                ref.read(assessmentSkippedProvider.notifier).state = true;
                context.go(AppRoutes.creditPassport);
              },
              child: const Text('Next'),
            ),
          ],
        ],
      ),
      children: [
        const SizedBox(height: 16),
        const _IconBadge(
          icon: AppIcons.warningCircle,
          color: AppColors.warning,
        ),
        const SizedBox(height: 24),
        const _Heading('Additional information required', size: 18),
        const SizedBox(height: 12),
        const _Body(
          'We paused your assessment because one of your documents could '
          'not be verified. We need a clear, updated copy to proceed.',
        ),
        const SizedBox(height: 24),
        if (issue != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warningBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  AppIcons.fileText,
                  size: 18,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        issue.documentName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.dangerText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        issue.message,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.dangerText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ---------- C01d_Failed ----------
class _FailedView extends ConsumerWidget {
  const _FailedView();

  static const _tips = [
    'Try reconnecting your MTN MoMo account.',
    'Upload additional alternative data, such as utility bills.',
    'Check back later when more financial activity is available.',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _StatusLayout(
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PrimaryButton(
            label: 'Try Again',
            icon: AppIcons.arrowsClockwise,
            onTap: () => ref.invalidate(scoringResultProvider),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => context.go(AppRoutes.support),
            icon: const Icon(AppIcons.question, size: 18),
            label: const Text('Contact Support'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: const StadiumBorder(),
              side: const BorderSide(color: AppColors.border),
              foregroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
      children: [
        const SizedBox(height: 16),
        const _IconBadge(icon: AppIcons.warningCircle, color: AppColors.danger),
        const SizedBox(height: 24),
        const _Heading('Assessment could not be\ncompleted'),
        const SizedBox(height: 12),
        const _Body(
          "We couldn't finish generating your Credit Passport right now. This "
          "usually happens when the connected data sources don't have enough "
          'recent history, or the connection timed out.',
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'What you can do',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),
              ..._tips.map(
                (t) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 6, right: 10),
                        child: Icon(
                          AppIcons.circle,
                          size: 5,
                          color: AppColors.textMuted,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          t,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------- E06 session expired ----------
// TODO(chris): swap for Binthia's shared E06 state screen once I have seen
// state_screen.dart.
class _SessionExpiredView extends StatelessWidget {
  const _SessionExpiredView();

  @override
  Widget build(BuildContext context) {
    return _StatusLayout(
      bottom: _PrimaryButton(
        label: 'Sign in',
        onTap: () => context.go(AppRoutes.login),
      ),
      children: const [
        SizedBox(height: 16),
        _IconBadge(icon: AppIcons.clock, color: AppColors.warning),
        SizedBox(height: 24),
        _Heading('Session expired'),
        SizedBox(height: 12),
        _Body(
          'For your security, please sign in again to continue building '
          'your Credit Passport.',
        ),
      ],
    );
  }
}

// ---------- C01c_Complete ----------
class _CompleteView extends StatelessWidget {
  const _CompleteView();

  @override
  Widget build(BuildContext context) {
    return _StatusLayout(
      bottom: _PrimaryButton(
        label: 'View my Passport',
        icon: AppIcons.arrowRight,
        onTap: () => context.go(AppRoutes.creditPassport),
      ),
      children: [
        const SizedBox(height: 48),
        Center(
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.success.withValues(alpha: 0.12),
            ),
            child: const Icon(
              AppIcons.shieldCheck,
              size: 40,
              color: AppColors.success,
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Center(child: _Heading('Assessment Complete', center: true)),
        const SizedBox(height: 12),
        const _Body(
          'Your financial data has been successfully verified. Your Credit '
          'Passport is ready.',
          center: true,
        ),
      ],
    );
  }
}
