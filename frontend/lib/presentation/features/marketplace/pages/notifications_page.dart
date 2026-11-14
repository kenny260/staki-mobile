import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/app_icons.dart';
import 'package:staki_mobile/presentation/features/marketplace/market_routes.dart';
import 'package:staki_mobile/presentation/features/marketplace/providers/market_models.dart';
import 'package:staki_mobile/presentation/features/marketplace/providers/market_providers.dart';
import 'package:staki_mobile/presentation/features/marketplace/widgets/market_widgets.dart';

const _title = 'Notifications';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    // UPDATE: opening the screen marks everything as read.
    final actions = ref.read(marketActionsProvider);
    unawaited(Future<void>.microtask(actions.markNotificationsRead));
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(notificationsProvider);

    return items.when(
      loading: () => const MarketScaffold.loading(
        title: _title,
        backTo: MarketRoutes.portfolio,
      ),
      error: (_, __) => const MarketScaffold.failure(
        title: _title,
        backTo: MarketRoutes.portfolio,
      ),
      data: (list) => MarketScaffold(
        title: _title,
        backTo: MarketRoutes.portfolio,
        children: [
          const MarketHeading('Updates', size: 22),
          const SizedBox(height: 16),
          if (list.isEmpty) const MarketBody('You have no notifications.'),
          for (final n in list) _NotificationCard(item: n),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item});

  final NotificationItem item;

  @override
  Widget build(BuildContext context) {
    final (icon, color, background) = switch (item.kind) {
      NotificationKind.success => (
          AppIcons.checkCircle,
          AppColors.success,
          AppColors.successBg,
        ),
      NotificationKind.info => (
          AppIcons.checkCircle,
          AppColors.info,
          AppColors.infoBg,
        ),
      NotificationKind.warning => (
          AppIcons.warning,
          AppColors.warning,
          AppColors.warningBg,
        ),
      NotificationKind.neutral => (
          AppIcons.chartLineUp,
          AppColors.textSecondary,
          AppColors.surface,
        ),
      NotificationKind.kyc => (
          AppIcons.buildings,
          AppColors.info,
          AppColors.infoBg,
        ),
    };
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.body,
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.timeLabel,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
