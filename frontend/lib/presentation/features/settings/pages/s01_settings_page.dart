import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/constants/spacing.dart';
import 'package:staki_mobile/core/router/app_routes.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/app_icons.dart';
import 'package:staki_mobile/core/theme/text_styles.dart';
import 'package:staki_mobile/core/utils/validators.dart';
import 'package:staki_mobile/presentation/features/onboarding/providers/onboarding_providers.dart';
import 'package:staki_mobile/presentation/features/profile/providers/account_providers.dart';
import 'package:staki_mobile/presentation/features/settings/providers/settings_providers.dart';
import 'package:staki_mobile/presentation/features/settings/widgets/log_out.dart';
import 'package:staki_mobile/presentation/features/settings/widgets/settings_widgets.dart';
import 'package:staki_mobile/presentation/shared_providers/preferences_providers.dart';
import 'package:staki_mobile/presentation/shared_widgets/shared_widgets.dart';

/// S01_Settings
class S01SettingsPage extends ConsumerWidget {
  const S01SettingsPage({super.key});

  Future<void> _pickLanguage(BuildContext context, WidgetRef ref) async {
    final current = ref.read(languageProvider);
    final picked = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final entry in supportedLanguages.entries)
              ListTile(
                title: Text(entry.value),
                trailing: entry.key == current
                    ? const Icon(AppIcons.check, color: AppColors.primary)
                    : null,
                onTap: () => Navigator.of(context).pop(entry.key),
              ),
          ],
        ),
      ),
    );
    if (picked != null) await ref.read(languageProvider.notifier).set(picked);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(accountProfileProvider).valueOrNull;
    // Saved phone first; the sign-up draft until the profile loads.
    final draftPhone = ref.watch(phoneNumberProvider);
    final phone = account?.phone ?? draftPhone;
    final notifications = ref.watch(notificationsEnabledProvider);
    final biometrics = ref.watch(biometricsEnabledProvider);
    final language =
        supportedLanguages[ref.watch(languageProvider)] ?? 'English';

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xl),
          children: [
            ScreenHeader(
              title: 'Settings',
              onBack: Navigator.of(context).canPop()
                  ? () => Navigator.of(context).maybePop()
                  : null,
            ),
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
                      Container(
                        width: 48,
                        height: 48,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          AppIcons.user,
                          color: AppColors.onPrimary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              account?.displayName ?? 'Your account',
                              style: AppTextStyles.title.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                              ),
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
                  const AppBadge(
                    label: 'KYC VERIFIED',
                    tone: BadgeTone.success,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SettingsGroup(
                    children: [
                      SettingsRow(
                        label: 'Personal information',
                        onTap: () => context.push(AppRoutes.personalInfo),
                      ),
                      const SettingsRow(
                        label: 'Verification status',
                        value: 'Verified',
                      ),
                    ],
                  ),
                  const SettingsSectionLabel('SECURITY'),
                  SettingsGroup(
                    children: [
                      const SettingsRow(label: 'Change PIN'),
                      SettingsRow(
                        label: 'Biometrics',
                        value: biometrics ? 'On' : 'Off',
                        onTap: () => ref
                            .read(biometricsEnabledProvider.notifier)
                            .set(enabled: !biometrics),
                      ),
                    ],
                  ),
                  const SettingsSectionLabel('DATA & PERMISSIONS'),
                  SettingsGroup(
                    children: [
                      const SettingsRow(label: 'Connected accounts'),
                      SettingsRow(
                        label: 'Data permissions',
                        onTap: () => context.push(AppRoutes.dataPermissions),
                      ),
                      SettingsRow(
                        label: 'Documents',
                        onTap: () => context.push(AppRoutes.documents),
                      ),
                    ],
                  ),
                  const SettingsSectionLabel('PREFERENCES & SUPPORT'),
                  SettingsGroup(
                    children: [
                      // Not in Figma: added so the SharedPreferences language
                      // setting can be shown and survives a restart.
                      SettingsRow(
                        label: 'Language',
                        value: language,
                        onTap: () => _pickLanguage(context, ref),
                      ),
                      SettingsRow(
                        label: 'Notifications',
                        value: notifications ? 'On' : 'Off',
                        onTap: () => ref
                            .read(notificationsEnabledProvider.notifier)
                            .set(enabled: !notifications),
                      ),
                      SettingsRow(
                        label: 'Privacy',
                        onTap: () => context.push(AppRoutes.privacy),
                      ),
                      SettingsRow(
                        label: 'Help and support',
                        onTap: () => context.push(AppRoutes.support),
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
      ),
    );
  }
}
