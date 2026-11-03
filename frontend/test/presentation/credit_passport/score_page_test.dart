import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staki_mobile/presentation/features/credit_passport/pages/score_page.dart';

void main() {
  testWidgets('ScorePage shows the score and factor cards', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: ScorePage())),
    );
    await tester.pumpAndSettle();

    expect(find.text('780'), findsOneWidget);
    expect(find.text('STRONG'), findsOneWidget);
    expect(find.text('Cash-flow strength'), findsOneWidget);
  });
}
