import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/presentation/features/consent/providers/consent_providers.dart';
import 'package:staki_mobile/presentation/features/consent/widgets/action_buttons.dart';
import 'package:staki_mobile/presentation/features/consent/widgets/consent_app_bar.dart';
import 'package:staki_mobile/presentation/features/consent/widgets/consent_layout.dart';
import 'package:staki_mobile/presentation/features/consent/widgets/data_source_card.dart';
import 'package:staki_mobile/presentation/features/consent/widgets/infrastructure_notice.dart';
import 'package:staki_mobile/presentation/features/consent/widgets/momo_logo.dart';

class ConsentIntroPage extends ConsumerWidget {
  const ConsentIntroPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final momoConnected = ref.watch(
      consentControllerProvider.select((s) => s.momoConnected),
    );

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const ConsentAppBar(),
      body: ConsentLayout(
        bottom: PrimaryActionButton(
          label: 'Continue',
          trailingIcon: Icons.chevron_right,
          onPressed: () => unawaited(context.push('/consent/momo')),
        ),
        children: [
          const _ShieldBadge(),
          const SizedBox(height: 20),
          const ConsentHeading(
            'Build your Credit Passport with your financial data',
          ),
          const SizedBox(height: 12),
          const ConsentBody(
            'We use financial information you authorize to understand '
            'cash flow, affordability and repayment behavior.',
          ),
          const SizedBox(height: 20),
          const InfrastructureNotice(),
          const SizedBox(height: 20),
          DataSourceCard(
            leading: const MomoLogo(size: 40),
            title: 'MTN MoMo',
            connected: momoConnected,
            dataUsed: 'Transaction history (6 months)',
            whyNeeded: 'Proves consistent cash flow and payment of '
                'utility bills.',
            onTap: () => unawaited(context.push('/consent/momo')),
          ),
          // TODO(chris): the Figma frame is cut off here. Confirm the real
          // text of the Bank Account card and any cards below it.
          DataSourceCard(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.account_balance,
                size: 20,
                color: AppColors.primary,
              ),
            ),
            title: 'Bank Account',
            connected: false,
            dataUsed: 'Account statements (6 months)',
            whyNeeded: 'Confirms income and savings patterns.',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Bank account connection is coming soon.'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShieldBadge extends StatelessWidget {
  const _ShieldBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border),
      ),
      child: const Icon(
        Icons.verified_user,
        size: 20,
        color: AppColors.primary,
      ),
    );
  }
}
