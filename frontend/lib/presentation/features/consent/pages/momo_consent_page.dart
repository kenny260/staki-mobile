import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/presentation/features/consent/providers/consent_providers.dart';
import 'package:staki_mobile/presentation/features/consent/widgets/action_buttons.dart';
import 'package:staki_mobile/presentation/features/consent/widgets/consent_app_bar.dart';
import 'package:staki_mobile/presentation/features/consent/widgets/consent_layout.dart';
import 'package:staki_mobile/presentation/features/consent/widgets/infrastructure_notice.dart';
import 'package:staki_mobile/presentation/features/consent/widgets/momo_logo.dart';

class MomoConsentPage extends ConsumerWidget {
  const MomoConsentPage({super.key});

  /// Enables the button once the user reaches the end of the content.
  /// The microtask keeps the state change out of the build phase.
  void _markIfAtEnd(ScrollMetrics metrics, WidgetRef ref) {
    if (metrics.extentAfter < 24) {
      final controller = ref.read(consentControllerProvider.notifier);
      unawaited(Future<void>.microtask(controller.markTermsRead));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final termsRead = ref.watch(
      consentControllerProvider.select((s) => s.termsRead),
    );

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const ConsentAppBar(title: 'Connect MTN MoMo'),
      body: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          _markIfAtEnd(n.metrics, ref);
          return false;
        },
        child: NotificationListener<ScrollMetricsNotification>(
          onNotification: (n) {
            _markIfAtEnd(n.metrics, ref);
            return false;
          },
          child: ConsentLayout(
            bottom: PrimaryActionButton(
              label: 'I agree and continue',
              onPressed: termsRead
                  ? () async {
                      await ref
                          .read(consentControllerProvider.notifier)
                          .agreeAndGrantConsent();
                      if (!context.mounted) return;
                      unawaited(context.push('/consent/momo/connect'));
                    }
                  : null,
            ),
            children: const [
              _LinkHeader(),
              SizedBox(height: 24),
              ConsentHeading('Authorization required', center: true),
              SizedBox(height: 12),
              ConsentBody(
                'Staki fund requires your permission to access your MTN '
                'Mobile Money transaction history to build your credit '
                'profile.',
                center: true,
              ),
              SizedBox(height: 24),
              _AccessCard(),
              SizedBox(height: 16),
              InfrastructureNotice(),
            ],
          ),
        ),
      ),
    );
  }
}

class _LinkHeader extends StatelessWidget {
  const _LinkHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const MomoLogo(),
        Container(
          width: 20,
          height: 2,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          color: AppColors.border,
        ),
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: const Icon(
            Icons.verified_user,
            size: 26,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _AccessCard extends StatelessWidget {
  const _AccessCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle(icon: Icons.visibility_outlined, label: 'What we access'),
          SizedBox(height: 14),
          _CheckItem(
            title: 'Transaction History',
            detail: 'Incoming transfers, bill payments, and airtime '
                'purchases (last 6 months).',
          ),
          SizedBox(height: 12),
          _CheckItem(
            title: 'Account Details',
            detail: 'Account status and registration name to verify '
                'identity.',
          ),
          SizedBox(height: 14),
          Divider(color: AppColors.border, height: 1),
          SizedBox(height: 14),
          _CardTitle(icon: Icons.lock_outline, label: 'How we protect you'),
          SizedBox(height: 12),
          _BulletItem(
            'Read-only access. We cannot move your funds or make '
            'payments.',
          ),
          SizedBox(height: 8),
          _BulletItem(
            'Data is encrypted and shared only with partnered lenders '
            'when you apply for a loan.',
          ),
        ],
      ),
    );
  }
}

class _CardTitle extends StatelessWidget {
  const _CardTitle({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _CheckItem extends StatelessWidget {
  const _CheckItem({required this.title, required this.detail});

  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(Icons.check_circle, size: 16, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                detail,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BulletItem extends StatelessWidget {
  const _BulletItem(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 6, right: 10),
          child: Icon(Icons.circle, size: 5, color: AppColors.textMuted),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
