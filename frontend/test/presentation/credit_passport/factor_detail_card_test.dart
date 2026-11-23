import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staki_mobile/core/theme/app_icons.dart';
import 'package:staki_mobile/presentation/features/credit_passport/providers/credit_passport_models.dart';
import 'package:staki_mobile/presentation/features/credit_passport/widgets/factor_detail_card.dart';

ScoreFactor _factor({int? points}) => ScoreFactor(
      title: 'Cash-flow strength',
      levelLabel: 'HIGH',
      progress: 0.82,
      summary: 'Money comes in steadily.',
      helped: 'Regular income.',
      improve: 'Keep income flowing in.',
      icon: AppIcons.chartLineUp,
      points: points,
    );

Future<void> _pump(WidgetTester tester, ScoreFactor factor) =>
    tester.pumpWidget(
      MaterialApp(home: Scaffold(body: FactorDetailCard(factor: factor))),
    );

void main() {
  testWidgets('shows the points a factor adds next to its level',
      (tester) async {
    await _pump(tester, _factor(points: 164));
    expect(find.text('+164 pts'), findsOneWidget);
    expect(find.text('HIGH'), findsOneWidget);
    expect(find.text('Regular income.'), findsOneWidget);
    expect(find.text('Keep income flowing in.'), findsOneWidget);
  });

  testWidgets('shows no points when the factor has none', (tester) async {
    await _pump(tester, _factor());
    expect(find.textContaining('pts'), findsNothing);
    expect(find.text('HIGH'), findsOneWidget);
  });
}
