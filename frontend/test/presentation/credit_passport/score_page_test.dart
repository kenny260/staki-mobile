import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staki_mobile/presentation/features/credit_passport/pages/score_page.dart';
import 'package:staki_mobile/presentation/features/credit_passport/providers/credit_passport_provider.dart';

void main() {
  testWidgets('ScorePage shows the score and factor cards', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          creditPassportRepositoryProvider
              .overrideWithValue(const MockCreditPassportRepository()),
        ],
        child: const MaterialApp(home: ScorePage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('742'), findsOneWidget);
    expect(find.text('VERY GOOD'), findsOneWidget);
    expect(find.text('Cash-flow strength'), findsOneWidget);
  });
}
