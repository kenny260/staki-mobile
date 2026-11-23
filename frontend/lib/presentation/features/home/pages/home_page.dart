import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/constants/spacing.dart';
import 'package:staki_mobile/core/router/app_routes.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/app_icons.dart';
import 'package:staki_mobile/core/theme/text_styles.dart';
import 'package:staki_mobile/presentation/features/credit_passport/providers/credit_passport_provider.dart';
import 'package:staki_mobile/presentation/features/home/widgets/home_widgets.dart';
import 'package:staki_mobile/presentation/features/loan_lifecycle/providers/lifecycle_models.dart';
import 'package:staki_mobile/presentation/features/loan_lifecycle/providers/lifecycle_providers.dart';
import 'package:staki_mobile/presentation/features/profile/providers/account_providers.dart';

/// Borrower Home tab: greeting, score, current loan and shortcuts.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(accountProfileProvider).valueOrNull;
    final score = ref.watch(creditScoreProvider).valueOrNull;
    final loan = ref.watch(loanAccountProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref
              ..invalidate(accountProfileProvider)
              ..invalidate(loanAccountProvider);
          },
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            children: [
              Text(
                'Hello, ${account?.firstName ?? ''}',
                style: AppTextStyles.h2.copyWith(color: AppColors.primary),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Here is where your Staki fund account stands today.',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.lg),
              HomeCard(
                icon: AppIcons.gauge,
                title: 'Credit Passport',
                headline: score == null ? 'Not ready yet' : '${score.value}',
                detail: score == null
                    ? 'Connect your data to get your score.'
                    : '${score.bandLabel} · ${score.updatedLabel}',
                actionLabel: 'View my score',
                onTap: () => context.go(AppRoutes.creditPassport),
              ),
              const SizedBox(height: AppSpacing.md),
              loan.when(
                loading: () => const HomeCard(
                  icon: AppIcons.money,
                  title: 'My loan',
                  headline: 'Loading...',
                  detail: '',
                ),
                error: (_, __) => HomeCard(
                  icon: AppIcons.money,
                  title: 'My loan',
                  headline: 'No loan yet',
                  detail: 'See which offers your Credit Passport unlocks.',
                  actionLabel: 'Apply for a loan',
                  onTap: () => unawaited(context.push('/loans')),
                ),
                data: (l) => HomeCard(
                  icon: AppIcons.money,
                  title: 'My loan',
                  headline: formatMoney(l.approvedAmount),
                  detail: loanStageLabel(l.stage),
                  actionLabel: 'View my loan',
                  onTap: () => context.go(AppRoutes.myLoans),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'QUICK ACTIONS',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              // Same height for all three shortcuts.
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: QuickAction(
                        icon: AppIcons.folderOpen,
                        label: 'My documents',
                        onTap: () =>
                            unawaited(context.push(AppRoutes.documents)),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s3),
                    Expanded(
                      child: QuickAction(
                        icon: AppIcons.shieldCheck,
                        label: 'Data permissions',
                        onTap: () =>
                            unawaited(context.push(AppRoutes.dataPermissions)),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s3),
                    Expanded(
                      child: QuickAction(
                        icon: AppIcons.trendUp,
                        label: 'Improve my score',
                        onTap: () => context.go(AppRoutes.creditImprove),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
