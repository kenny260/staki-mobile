import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staki_mobile/presentation/features/marketplace/pages/opportunities_page.dart';
import 'package:staki_mobile/presentation/features/marketplace/pages/portfolio_page.dart';
import 'package:staki_mobile/presentation/features/marketplace/providers/market_providers.dart';
import 'package:staki_mobile/presentation/features/marketplace/providers/market_repository.dart';

Future<void> _show(WidgetTester tester, Widget page) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        marketplaceRepositoryProvider.overrideWithValue(
          MockMarketplaceRepository(delay: Duration.zero),
        ),
      ],
      child: MaterialApp(home: page),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the marketplace lists the opportunities', (tester) async {
    await _show(tester, const OpportunitiesPage());

    expect(find.text('Marketplace'), findsOneWidget);
    expect(find.text('Inventory Expansion'), findsOneWidget);
    expect(find.text('Equipment Purchase'), findsOneWidget);
    expect(find.text('Working Capital'), findsOneWidget);
    expect(find.text('70% funded'), findsOneWidget);
  });

  testWidgets('the portfolio shows the overview and allocations', (
    tester,
  ) async {
    await _show(tester, const PortfolioPage());

    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('RWF 14,500,000'), findsOneWidget);
    expect(find.text('RWF 12,000,000'), findsOneWidget);
    expect(find.text('VIEW LEDGER'), findsOneWidget);
    expect(find.text('MSME Retail'), findsOneWidget);
  });
}
