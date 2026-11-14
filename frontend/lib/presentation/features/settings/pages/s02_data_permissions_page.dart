import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staki_mobile/core/constants/spacing.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/app_icons.dart';
import 'package:staki_mobile/core/theme/text_styles.dart';
import 'package:staki_mobile/presentation/features/settings/providers/settings_providers.dart';
import 'package:staki_mobile/presentation/shared_widgets/shared_widgets.dart';

/// S02_DataPermissions
class S02DataPermissionsPage extends ConsumerWidget {
  const S02DataPermissionsPage({super.key});

  Future<void> _confirmRevoke(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Revoke MTN MoMo access?'),
        content: const Text(
          'Staki fund will stop reading your MoMo data. Your score may '
          'become less accurate.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep access'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Revoke'),
          ),
        ],
      ),
    );
    if (ok ?? false) {
      // TODO(Uche): write the revoke to the consent ledger (timestamped).
      ref.read(dataPermissionsProvider.notifier).setMomo(connected: false);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(dataPermissionsProvider);
    final n = ref.read(dataPermissionsProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            ScreenHeader(
              title: 'Data Permissions',
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Connected Data',
                    style: AppTextStyles.h2.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Manage the financial information authorized for '
                    'your Credit Passport.',
                    style: AppTextStyles.subtitle,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _SourceCard(
                    icon: AppIcons.deviceMobile,
                    tint: AppColors.warningBg,
                    iconColor: AppColors.warning,
                    title: 'MTN MoMo',
                    status: p.momoConnected ? 'Connected' : 'Not connected',
                    isOk: p.momoConnected,
                    description: p.momoConnected
                        ? 'Staki fund has read-only access to '
                            'transaction history and account details to '
                            'assess cash flow.'
                        : 'Connect MTN MoMo so we can read your '
                            'transaction history for your score.',
                    actionLabel:
                        p.momoConnected ? 'Revoke Access' : 'Connect MoMo',
                    isDestructive: p.momoConnected,
                    onAction: p.momoConnected
                        ? () => _confirmRevoke(context, ref)
                        : () => n.setMomo(connected: true),
                  ),
                  _SourceCard(
                    icon: AppIcons.bank,
                    tint: AppColors.infoBg,
                    iconColor: AppColors.info,
                    title: 'Bank Account',
                    status: p.bankConnected ? 'Connected' : 'Not connected',
                    isOk: p.bankConnected,
                    description: 'Connect your bank to boost your score with '
                        'verifiable salary or business revenue data.',
                    actionLabel:
                        p.bankConnected ? 'Disconnect Bank' : 'Connect Bank',
                    isDestructive: p.bankConnected,
                    onAction: () => n.setBank(connected: !p.bankConnected),
                  ),
                  _SourceCard(
                    icon: AppIcons.fileText,
                    tint: AppColors.primarySoft,
                    iconColor: AppColors.primary,
                    title: 'Documents',
                    status: p.documentsUploaded > 0
                        ? 'Available (${p.documentsUploaded} uploaded)'
                        : 'None uploaded',
                    isOk: p.documentsUploaded > 0,
                    description: 'RDB Certificates and tax clearance are used '
                        'for identity and business verification.',
                    actionLabel: 'Manage Documents',
                    // TODO(Chris): open the document list (Section 04).
                    onAction: null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceCard extends StatelessWidget {
  const _SourceCard({
    required this.icon,
    required this.tint,
    required this.iconColor,
    required this.title,
    required this.status,
    required this.isOk,
    required this.description,
    required this.actionLabel,
    required this.onAction,
    this.isDestructive = false,
  });

  final IconData icon;
  final Color tint;
  final Color iconColor;
  final String title;
  final String status;
  final bool isOk;
  final String description;
  final String actionLabel;
  final VoidCallback? onAction;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: AppSpacing.s3),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style:
                        AppTextStyles.title.copyWith(color: AppColors.primary),
                  ),
                  Text(
                    status,
                    style: AppTextStyles.caption.copyWith(
                      color: isOk ? AppColors.success : AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s3),
          Text(
            description,
            style: AppTextStyles.subtitle.copyWith(fontSize: 12),
          ),
          const SizedBox(height: AppSpacing.s3),
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 32),
              alignment: Alignment.centerLeft,
              foregroundColor:
                  isDestructive ? AppColors.danger : AppColors.primary,
            ),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}
