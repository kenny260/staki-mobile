import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/presentation/features/consent/widgets/action_buttons.dart';
import 'package:staki_mobile/presentation/features/consent/widgets/consent_app_bar.dart';
import 'package:staki_mobile/presentation/features/consent/widgets/consent_layout.dart';
import 'package:staki_mobile/presentation/features/consent/widgets/status_badge.dart';

class MomoErrorPage extends StatelessWidget {
  const MomoErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const ConsentAppBar(title: 'MTN MoMo'),
      body: ConsentLayout(
        centered: true,
        bottom: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PrimaryActionButton(
              label: 'Try again',
              leadingIcon: Icons.refresh,
              onPressed: () =>
                  context.pushReplacement('/consent/momo/connecting'),
            ),
            const SizedBox(height: 12),
            SecondaryActionButton(
              label: 'Upload a statement instead',
              leadingIcon: Icons.description_outlined,
              onPressed: () => unawaited(context.push('/documents')),
            ),
          ],
        ),
        children: const [
          StatusBadge(icon: Icons.error, color: AppColors.danger),
          SizedBox(height: 24),
          ConsentHeading("We couldn't connect your MTN MoMo", center: true),
          SizedBox(height: 12),
          ConsentBody(
            'The connection timed out or the authorization was declined. '
            'Please ensure you approve the prompt on your phone.',
            center: true,
          ),
        ],
      ),
    );
  }
}
