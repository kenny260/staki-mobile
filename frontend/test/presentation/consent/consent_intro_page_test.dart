import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staki_mobile/presentation/features/consent/pages/consent_intro_page.dart';

void main() {
  testWidgets('ConsentIntroPage shows the heading and MoMo card', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: ConsentIntroPage())),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Build your Credit Passport with your financial data'),
      findsOneWidget,
    );
    expect(find.text('MTN MoMo'), findsOneWidget);
    expect(find.text('Not connected'), findsWidgets);
  });
}
