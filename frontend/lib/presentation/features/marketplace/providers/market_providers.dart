import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staki_mobile/presentation/features/marketplace/providers/market_models.dart';
import 'package:staki_mobile/presentation/features/marketplace/providers/market_repository.dart';

// TEMP mock. To preview the allocation error, use:
// MockMarketplaceRepository(failAllocate: true)
final marketplaceRepositoryProvider = Provider<MarketplaceRepository>(
  (ref) => MockMarketplaceRepository(),
);

final opportunitiesProvider = FutureProvider<List<Opportunity>>(
  (ref) => ref.watch(marketplaceRepositoryProvider).fetchOpportunities(),
);

final balanceProvider = FutureProvider<int>(
  (ref) => ref.watch(marketplaceRepositoryProvider).fetchBalance(),
);

final portfolioProvider = FutureProvider<Portfolio>(
  (ref) => ref.watch(marketplaceRepositoryProvider).fetchPortfolio(),
);

final ledgerProvider = FutureProvider<List<LedgerEntry>>(
  (ref) => ref.watch(marketplaceRepositoryProvider).fetchLedger(),
);

final notificationsProvider = FutureProvider<List<NotificationItem>>(
  (ref) => ref.watch(marketplaceRepositoryProvider).fetchNotifications(),
);

final opportunityFilterProvider = StateProvider<OpportunityFilter>(
  (ref) => const OpportunityFilter(),
);

final filteredOpportunitiesProvider =
    Provider<AsyncValue<List<Opportunity>>>((ref) {
  final filter = ref.watch(opportunityFilterProvider);
  return ref
      .watch(opportunitiesProvider)
      .whenData((items) => items.where(filter.matches).toList());
});

final opportunityProvider = Provider.family<Opportunity?, String>((ref, id) {
  final items = ref.watch(opportunitiesProvider).valueOrNull;
  if (items == null) return null;
  for (final item in items) {
    if (item.id == id) return item;
  }
  return null;
});

final allocationProvider = Provider.family<Allocation?, String>((ref, id) {
  final portfolio = ref.watch(portfolioProvider).valueOrNull;
  if (portfolio == null) return null;
  for (final item in portfolio.allocations) {
    if (item.id == id) return item;
  }
  return null;
});

final hasUnreadProvider = Provider<bool>((ref) {
  final items = ref.watch(notificationsProvider).valueOrNull;
  return items?.any((n) => !n.read) ?? false;
});

class MarketActions {
  MarketActions(this._ref);

  final Ref _ref;

  /// UPDATE: mark every notification as read.
  Future<void> markNotificationsRead() async {
    await _ref.read(marketplaceRepositoryProvider).markNotificationsRead();
    _ref.invalidate(notificationsProvider);
  }
}

final marketActionsProvider = Provider<MarketActions>(MarketActions.new);

class FundingFlow {
  const FundingFlow({
    this.opportunityId,
    this.amount = defaultAllocation,
    this.confirmed = false,
    this.receipt,
  });

  final String? opportunityId;
  final int amount;
  final bool confirmed;
  final AllocationReceipt? receipt;

  FundingFlow copyWith({
    int? amount,
    bool? confirmed,
    AllocationReceipt? receipt,
  }) {
    return FundingFlow(
      opportunityId: opportunityId,
      amount: amount ?? this.amount,
      confirmed: confirmed ?? this.confirmed,
      receipt: receipt ?? this.receipt,
    );
  }
}

class FundingController extends Notifier<FundingFlow> {
  MarketplaceRepository get _repository =>
      ref.read(marketplaceRepositoryProvider);

  @override
  FundingFlow build() => const FundingFlow();

  void start(String opportunityId, {required int maxAmount}) {
    state = FundingFlow(
      opportunityId: opportunityId,
      amount: clampInt(
        defaultAllocation,
        minAllocationFor(maxAmount),
        maxAmount,
      ),
    );
  }

  void setAmount(int amount) => state = state.copyWith(amount: amount);

  void toggleConfirmed() => state = state.copyWith(confirmed: !state.confirmed);

  /// CREATE the allocation. Returns null if it failed.
  Future<AllocationReceipt?> allocate() async {
    final id = state.opportunityId;
    if (id == null || !state.confirmed) return null;
    try {
      final receipt = await _repository.allocate(id, state.amount);
      state = state.copyWith(receipt: receipt);
      ref
        ..invalidate(opportunitiesProvider)
        ..invalidate(balanceProvider)
        ..invalidate(portfolioProvider)
        ..invalidate(ledgerProvider)
        ..invalidate(notificationsProvider);
      return receipt;
    } on Exception {
      return null;
    }
  }
}

final fundingControllerProvider =
    NotifierProvider<FundingController, FundingFlow>(FundingController.new);
