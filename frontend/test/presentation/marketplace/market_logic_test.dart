import 'package:flutter_test/flutter_test.dart';
import 'package:staki_mobile/presentation/features/marketplace/providers/market_models.dart';
import 'package:staki_mobile/presentation/features/marketplace/providers/market_repository.dart';

Future<List<Opportunity>> _all() =>
    MockMarketplaceRepository(delay: Duration.zero).fetchOpportunities();

List<String> _ids(List<Opportunity> list, OpportunityFilter filter) =>
    list.where(filter.matches).map((o) => o.id).toList();

void main() {
  test('money and date formats match the Figma style', () {
    expect(moneyRwf(5000000), 'RWF 5,000,000');
    expect(signedRwf(500000), '+RWF 500,000');
    expect(signedRwf(-500000), '-RWF 500,000');
    expect(dateLabel(DateTime(2026, 11, 15)), 'Nov 15, 2026');
  });

  test('the fee matches the Figma sample (500,000 gives 5,000)', () {
    expect(allocationFee(500000), 5000);
  });

  test('the allocation limits are never below the minimum or above max', () {
    expect(minAllocationFor(1500000), 100000);
    expect(minAllocationFor(40000), 40000);
    expect(clampInt(5, 10, 20), 10);
    expect(clampInt(25, 10, 20), 20);
    expect(clampInt(15, 10, 20), 15);
  });

  test('opportunity funding maths', () async {
    final first = (await _all()).first;
    expect(first.remaining, 1500000);
    expect(first.fundedPercent, 70);
    expect(first.rateLabel, '18% p.a.');
    expect(maxFundable(first, 5000000), 1500000);
    expect(maxFundable(first, 800000), 800000);
  });

  test('a fully funded opportunity cannot take more money', () async {
    final second = (await _all())[1];
    expect(second.isFullyFunded, isTrue);
    expect(second.rateLabel, '16.5% p.a.');
  });

  test('filters narrow the list and toggling clears them', () async {
    final all = await _all();
    expect(
      _ids(all, const OpportunityFilter(amount: AmountFilter.mid)),
      ['OPP-1042', 'OPP-0891'],
    );
    expect(
      _ids(all, const OpportunityFilter(term: TermFilter.long)),
      ['OPP-0891'],
    );
    expect(
      _ids(all, const OpportunityFilter(risk: RiskFilter.moderate)),
      ['OPP-1095'],
    );

    const filter = OpportunityFilter(amount: AmountFilter.mid);
    expect(filter.toggleAmount(AmountFilter.mid).isActive, isFalse);
    expect(const OpportunityFilter().isActive, isFalse);
  });

  test('the portfolio totals match the Figma overview', () async {
    final portfolio =
        await MockMarketplaceRepository(delay: Duration.zero).fetchPortfolio();
    expect(portfolio.totalAllocated, 14500000);
    expect(portfolio.activeFunding, 12000000);
    expect(portfolio.repaidPrincipal, 2500000);
    expect(portfolio.pendingRepayments, 850000);
  });
}
