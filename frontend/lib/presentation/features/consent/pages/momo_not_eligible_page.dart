import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/presentation/features/consent/widgets/action_buttons.dart';
import 'package:staki_mobile/presentation/features/consent/widgets/consent_app_bar.dart';
import 'package:staki_mobile/presentation/features/consent/widgets/consent_layout.dart';
import 'package:staki_mobile/presentation/features/consent/widgets/status_badge.dart';

class MomoNotEligiblePage extends StatelessWidget {
  const MomoNotEligiblePage({super.key});

  static const _reasons = <(IconData, String)>[
    (Icons.history, 'Not enough account history may be available.'),
    (Icons.show_chart, 'There may not be enough transaction activity.'),
    (
      Icons.shield_outlined,
      'Account information may not have been fully verified.',
    ),
    (
      Icons.smartphone,
      'The connection may have been incomplete, or required '
          'information is missing.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const ConsentAppBar(title: 'Account Assessment'),
      body: ConsentLayout(
        bottom: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PrimaryActionButton(
              label: 'Upload a MoMo statement',
              leadingIcon: Icons.description_outlined,
              onPressed: () => unawaited(context.push('/documents')),
            ),
            const SizedBox(height: 12),
            SecondaryActionButton(
              label: 'Try again',
              leadingIcon: Icons.refresh,
              onPressed: () =>
                  context.pushReplacement('/consent/momo/connecting'),
            ),
          ],
        ),
        children: [
          const StatusBadge(icon: Icons.error, color: AppColors.warning),
          const SizedBox(height: 24),
          const ConsentHeading("We can't assess this MTN MoMo account yet."),
          const SizedBox(height: 12),
          const ConsentBody(
            "We've securely reviewed the connected account, but there may "
            'not be enough usable data right now to generate a reliable '
            'score.',
          ),
          const SizedBox(height: 20),
          const Text(
            'Possible reasons',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          ..._reasons.map((r) => _ReasonTile(icon: r.$1, text: r.$2)),
        ],
      ),
    );
  }
}

class _ReasonTile extends StatelessWidget {
  const _ReasonTile({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
