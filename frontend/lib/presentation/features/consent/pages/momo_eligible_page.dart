import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/presentation/features/consent/widgets/action_buttons.dart';
import 'package:staki_mobile/presentation/features/consent/widgets/consent_app_bar.dart';
import 'package:staki_mobile/presentation/features/consent/widgets/consent_layout.dart';
import 'package:staki_mobile/presentation/features/consent/widgets/status_badge.dart';

class MomoEligiblePage extends StatelessWidget {
  const MomoEligiblePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const ConsentAppBar(title: 'Account Assessment'),
      body: ConsentLayout(
        centered: true,
        bottom: PrimaryActionButton(
          label: 'Continue to Passport',
          // Needs PR #1 (Section 05) merged into staging.
          onPressed: () =>
              unawaited(context.push('/credit-passport/assessment')),
        ),
        children: const [
          StatusBadge(icon: Icons.check_circle, color: AppColors.success),
          SizedBox(height: 24),
          ConsentHeading('Your account is ready for assessment', center: true),
          SizedBox(height: 12),
          ConsentBody(
            'We have verified that enough usable information is available '
            'to continue building your Credit Passport.',
            center: true,
          ),
        ],
      ),
    );
  }
}
