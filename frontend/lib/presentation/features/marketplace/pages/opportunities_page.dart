import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/router/app_routes.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/presentation/features/marketplace/market_routes.dart';
import 'package:staki_mobile/presentation/features/marketplace/providers/market_models.dart';
import 'package:staki_mobile/presentation/features/marketplace/providers/market_providers.dart';
import 'package:staki_mobile/presentation/features/marketplace/widgets/filter_sheet.dart';
import 'package:staki_mobile/presentation/features/marketplace/widgets/market_widgets.dart';

class OpportunitiesPage extends ConsumerWidget {
  const OpportunitiesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opportunities = ref.watch(filteredOpportunitiesProvider);
    final filter = ref.watch(opportunityFilterProvider);

    final content = opportunities.when<List<Widget>>(
      loading: () => const [
        SizedBox(height: 120),
        Center(child: CircularProgressIndicator()),
      ],
      error: (_, __) => const [
        Text('We could not load opportunities. Please try again.'),
      ],
      data: (items) {
        if (items.isEmpty) {
          return [
            const Text(
              'No opportunities match your filters.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            TextButton(
              onPressed: () => ref
                  .read(opportunityFilterProvider.notifier)
                  .state = const OpportunityFilter(),
              child: const Text('Clear filters'),
            ),
          ];
        }
        return [
          for (final o in items)
            OpportunityCard(
              opportunity: o,
              onTap: () =>
                  unawaited(context.push(MarketRoutes.opportunity(o.id))),
            ),
        ];
      },
    );

    return MarketScaffold(
      title: 'Opportunities',
      backTo: AppRoutes.splash,
      trailing: _FilterButton(
        active: filter.isActive,
        onTap: () => unawaited(showFilterSheet(context)),
      ),
      children: [
        const MarketHeading('Marketplace', size: 22),
        const SizedBox(height: 6),
        const MarketBody(
          'Review abstracted profiles and allocate funds to verified '
          'opportunities.',
        ),
        const SizedBox(height: 20),
        ...content,
      ],
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.active, required this.onTap});

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Filter opportunities',
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.warning.withValues(alpha: 0.15),
              ),
              child: const Icon(
                Icons.filter_alt,
                size: 18,
                color: AppColors.primary,
              ),
            ),
            if (active)
              const Positioned(
                right: 0,
                top: 0,
                child: Icon(Icons.circle, size: 10, color: AppColors.danger),
              ),
          ],
        ),
      ),
    );
  }
}
