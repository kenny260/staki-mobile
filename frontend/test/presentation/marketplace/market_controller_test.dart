import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staki_mobile/presentation/features/marketplace/providers/market_models.dart';
import 'package:staki_mobile/presentation/features/marketplace/providers/market_providers.dart';
import 'package:staki_mobile/presentation/features/marketplace/providers/market_repository.dart';

ProviderContainer _container({bool failAllocate = false}) {
  final container = ProviderContainer(
    overrides: [
      marketplaceRepositoryProvider.overrideWithValue(
        MockMarketplaceRepository(
          delay: Duration.zero,
          failAllocate: failAllocate,
        ),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('allocating creates a receipt and updates every list', () async {
    final container = _container();
    await container.read(opportunitiesProvider.future);
    final controller = container.read(fundingControllerProvider.notifier)
      ..start('OPP-1042', maxAmount: 1500000)
      ..toggleConfirmed();

    final receipt = await controller.allocate();
    expect(receipt, isNotNull);
    expect(receipt!.amount, 500000);
    expect(receipt.opportunityId, 'OPP-1042');

    final opportunities = await container.read(opportunitiesProvider.future);
    expect(opportunities.first.funded, 4000000);
    expect(opportunities.first.remaining, 1000000);

    expect(await container.read(balanceProvider.future), 4500000);

    final portfolio = await container.read(portfolioProvider.future);
    expect(portfolio.allocations, hasLength(4));
    expect(portfolio.totalAllocated, 15000000);

    final ledger = await container.read(ledgerProvider.future);
    expect(ledger.first.title, 'Allocation: OPP-1042');
    expect(ledger.first.amount, -500000);
  });

  test('allocating needs the confirmation box ticked', () async {
    final container = _container();
    final controller = container.read(fundingControllerProvider.notifier)
      ..start('OPP-1042', maxAmount: 1500000);
    expect(await controller.allocate(), isNull);
  });

  test('an amount above what is left is refused', () async {
    final container = _container();
    final controller = container.read(fundingControllerProvider.notifier)
      ..start('OPP-1042', maxAmount: 1500000)
      ..setAmount(2000000)
      ..toggleConfirmed();
    expect(await controller.allocate(), isNull);
    expect(await container.read(balanceProvider.future), 5000000);
  });

  test('a failing backend makes allocate return null', () async {
    final container = _container(failAllocate: true);
    final controller = container.read(fundingControllerProvider.notifier)
      ..start('OPP-1042', maxAmount: 1500000)
      ..toggleConfirmed();
    expect(await controller.allocate(), isNull);
  });

  test('start keeps the default inside the allowed range', () {
    final container = _container();
    final controller = container.read(fundingControllerProvider.notifier)
      ..start('OPP-1095', maxAmount: 300000);
    expect(container.read(fundingControllerProvider).amount, 300000);
    controller.start('OPP-1042', maxAmount: 1500000);
    expect(container.read(fundingControllerProvider).amount, 500000);
  });

  test('opening notifications marks them all as read', () async {
    final container = _container();
    await container.read(notificationsProvider.future);
    expect(container.read(hasUnreadProvider), isTrue);

    await container.read(marketActionsProvider).markNotificationsRead();
    final items = await container.read(notificationsProvider.future);
    expect(items.every((n) => n.read), isTrue);
    expect(container.read(hasUnreadProvider), isFalse);
  });

  test('the filter provider narrows the opportunity list', () async {
    final container = _container();
    await container.read(opportunitiesProvider.future);
    container.read(opportunityFilterProvider.notifier).state =
        const OpportunityFilter(term: TermFilter.medium);

    final filtered = container.read(filteredOpportunitiesProvider);
    expect(filtered.requireValue.map((o) => o.id), ['OPP-1042', 'OPP-1095']);
  });
}
