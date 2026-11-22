import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/app_icons.dart';
import 'package:staki_mobile/presentation/features/consent/providers/consent_providers.dart';
import 'package:staki_mobile/presentation/features/consent/widgets/action_buttons.dart';
import 'package:staki_mobile/presentation/features/consent/widgets/consent_app_bar.dart';
import 'package:staki_mobile/presentation/features/consent/widgets/consent_layout.dart';
import 'package:staki_mobile/presentation/features/consent/widgets/momo_logo.dart';
import 'package:staki_mobile/presentation/features/consent/widgets/status_badge.dart';

class MomoConnectedPage extends ConsumerWidget {
  const MomoConnectedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(consentControllerProvider);
    final eligible = state.eligible ?? false;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const ConsentAppBar(title: 'MTN MoMo'),
      body: ConsentLayout(
        centered: true,
        bottom: PrimaryActionButton(
          label: 'Continue',
          onPressed: () => unawaited(
            context.push(
              eligible
                  ? '/consent/momo/eligible'
                  : '/consent/momo/not-eligible',
            ),
          ),
        ),
        children: [
          const StatusBadge(
            icon: AppIcons.shieldCheck,
            color: AppColors.success,
          ),
          const SizedBox(height: 24),
          const ConsentHeading('MTN MoMo connected', center: true),
          const SizedBox(height: 8),
          const ConsentBody(
            'Your account was successfully verified.',
            center: true,
          ),
          const SizedBox(height: 24),
          _AccountTile(maskedNumber: state.account?.maskedNumber ?? ''),
        ],
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({required this.maskedNumber});

  final String maskedNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const MomoLogo(size: 36),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                maskedNumber,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const Row(
                children: [
                  Icon(AppIcons.circle, size: 6, color: AppColors.success),
                  SizedBox(width: 4),
                  Text(
                    'Connected',
                    style: TextStyle(fontSize: 11, color: AppColors.success),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
