import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staki_mobile/presentation/shared_widgets/placeholder_page.dart';

/// Widget test. The rubric needs at least one; this is the starting one.
void main() {
  testWidgets('PlaceholderPage shows the screen code and title',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PlaceholderPage(
          screenCode: 'A05_Phone',
          title: 'Phone number',
          owner: 'Binthia',
        ),
      ),
    );

    expect(find.text('A05_Phone'), findsOneWidget);
    expect(find.text('Phone number'), findsOneWidget);
    expect(find.text('Owner: Binthia'), findsOneWidget);
  });
}
