import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staki_mobile/presentation/features/marketplace/market_routes.dart';
import 'package:staki_mobile/presentation/features/marketplace/providers/market_providers.dart';
import 'package:staki_mobile/presentation/features/marketplace/widgets/market_widgets.dart';

const _title = 'Ledger';

class LedgerPage extends ConsumerWidget {
  const LedgerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ledger = ref.watch(ledgerProvider);

    return ledger.when(
      loading: () => const MarketScaffold.loading(
        title: _title,
        backTo: MarketRoutes.portfolio,
      ),
      error: (_, __) => const MarketScaffold.failure(
        title: _title,
        backTo: MarketRoutes.portfolio,
      ),
      data: (entries) => MarketScaffold(
        title: _title,
        backTo: MarketRoutes.portfolio,
        children: [
          const MarketHeading('Portfolio Activity', size: 22),
          const SizedBox(height: 12),
          if (entries.isEmpty) const MarketBody('No activity yet.'),
          for (final entry in entries) LedgerRow(entry: entry),
        ],
      ),
    );
  }
}
