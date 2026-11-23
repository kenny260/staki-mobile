import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/constants/spacing.dart';
import 'package:staki_mobile/core/router/app_routes.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/text_styles.dart';
import 'package:staki_mobile/core/utils/validators.dart';
import 'package:staki_mobile/presentation/features/marketplace/market_routes.dart';
import 'package:staki_mobile/presentation/features/profile/providers/account_providers.dart';
import 'package:staki_mobile/presentation/features/settings/widgets/log_out.dart';
import 'package:staki_mobile/presentation/features/settings/widgets/settings_widgets.dart';
import 'package:staki_mobile/presentation/shared_widgets/shared_widgets.dart';

/// Profile tab for borrowers and lenders: who you are, then links to
/// documents, data permissions, settings and log out.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(accountProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: account.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(
            child: Text('We could not load your profile. Please try again.'),
          ),
          data: (a) =>
              a == null ? const SizedBox.shrink() : _ProfileBody(account: a),
        ),
      ),
    );
  }
}

class _ProfileBody extends ConsumerWidget {
  const _ProfileBody({required this.account});

  final AccountProfile account;

  void _push(BuildContext context, String route) =>
      unawaited(context.push(route));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = account;
    final phone = a.phone ?? '';

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(accountProfileProvider),
      child: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        children: [
          const ScreenHeader(title: 'Profile'),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        a.initials,
                        style: AppTextStyles.title
                            .copyWith(color: AppColors.onPrimary),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a.displayName ?? a.firstName,
                            style: AppTextStyles.title.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (a.email != null)
                            Text(
                              a.email!,
                              style: AppTextStyles.caption
                                  .copyWith(color: AppColors.textSecondary),
                            ),
                          if (phone.isNotEmpty)
                            Text(
                              Validators.displayRwandaPhone(phone),
                              style: AppTextStyles.caption
                                  .copyWith(color: AppColors.textSecondary),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s3),
                AppBadge(
                  label: a.isLender ? 'LENDER' : 'BORROWER',
                  tone: BadgeTone.primary,
                ),
                if (!a.isLender) ...[
                  const SettingsSectionLabel('MY PROFILE'),
                  SettingsGroup(
                    children: [
                      SettingsRow(
                        label: 'Borrower type',
                        value: a.borrowerTypeLabel,
                        onTap: a.borrowerType == null
                            ? () => _push(context, AppRoutes.profileRole)
                            : null,
                      ),
                      for (final entry in a.answers.entries.take(4))
                        SettingsRow(
                          label: _labelFor(entry.key),
                          value: '${entry.value}',
                        ),
                    ],
                  ),
                  const SettingsSectionLabel('MY DATA'),
                  SettingsGroup(
                    children: [
                      SettingsRow(
                        label: 'My documents',
                        onTap: () => _push(context, AppRoutes.documents),
                      ),
                      SettingsRow(
                        label: 'Data permissions',
                        onTap: () => _push(context, AppRoutes.dataPermissions),
                      ),
                    ],
                  ),
                ] else ...[
                  const SettingsSectionLabel('MY ACCOUNT'),
                  SettingsGroup(
                    children: [
                      SettingsRow(
                        label: 'Wallet and ledger',
                        onTap: () => context.go(MarketRoutes.ledger),
                      ),
                      SettingsRow(
                        label: 'Notifications',
                        onTap: () => _push(context, MarketRoutes.notifications),
                      ),
                    ],
                  ),
                ],
                const SettingsSectionLabel('GENERAL'),
                SettingsGroup(
                  children: [
                    SettingsRow(
                      label: 'Settings',
                      onTap: () => _push(context, AppRoutes.settings),
                    ),
                    SettingsRow(
                      label: 'Privacy',
                      onTap: () => _push(context, AppRoutes.privacy),
                    ),
                    SettingsRow(
                      label: 'Help and support',
                      onTap: () => _push(context, AppRoutes.support),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                SettingsGroup(
                  children: [
                    SettingsRow(
                      label: 'Log out',
                      isDestructive: true,
                      onTap: () => confirmLogOut(context, ref),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "businessName" -> "Business name".
String _labelFor(String key) {
  final words = key.replaceAllMapped(
    RegExp('([a-z])([A-Z])'),
    (m) => '${m[1]} ${m[2]!.toLowerCase()}',
  );
  return words.isEmpty ? key : words[0].toUpperCase() + words.substring(1);
}
