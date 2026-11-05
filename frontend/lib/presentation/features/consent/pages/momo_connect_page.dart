import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/presentation/features/consent/widgets/action_buttons.dart';
import 'package:staki_mobile/presentation/features/consent/widgets/consent_app_bar.dart';
import 'package:staki_mobile/presentation/features/consent/widgets/consent_layout.dart';
import 'package:staki_mobile/presentation/features/consent/widgets/momo_logo.dart';

class MomoConnectPage extends StatelessWidget {
  const MomoConnectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const ConsentAppBar(title: 'MTN MoMo'),
      body: ConsentLayout(
        bottom: PrimaryActionButton(
          label: 'Connect MTN MoMo',
          onPressed: () => unawaited(context.push('/consent/momo/connecting')),
        ),
        children: const [
          MomoLogo(size: 48),
          SizedBox(height: 20),
          ConsentHeading('Connect your MTN MoMo'),
          SizedBox(height: 12),
          ConsentBody(
            'Your transaction history can help us assess your financial '
            'activity and build your Credit Passport.',
          ),
          SizedBox(height: 24),
          _InfoCard(),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard();

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
        children: [
          _InfoRow(
            icon: Icons.smartphone,
            color: AppColors.primary,
            title: 'What we access',
            text: '6 months of transaction history and account status.',
          ),
          SizedBox(height: 18),
          _InfoRow(
            icon: Icons.check_circle,
            color: AppColors.success,
            title: 'Why we need it',
            text: 'To verify your cash flow, prove utility payments, and '
                'generate your score.',
          ),
          SizedBox(height: 18),
          _InfoRow(
            icon: Icons.lock,
            color: AppColors.primary,
            title: 'How consent works',
            text: 'Read-only access. You can revoke this permission at '
                'any time. We never hold or control your funds.',
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.4,
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
