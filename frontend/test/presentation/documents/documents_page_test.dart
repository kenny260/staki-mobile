import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staki_mobile/presentation/features/documents/pages/documents_page.dart';

void main() {
  testWidgets('DocumentsPage lists documents with their status', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: DocumentsPage())),
    );
    await tester.pumpAndSettle();

    expect(find.text('My Documents'), findsOneWidget);
    expect(find.text('National ID'), findsOneWidget);
    expect(find.text('Verified'), findsOneWidget);
    expect(find.text('MTN MoMo Statement'), findsOneWidget);
    expect(find.text('Needs attention'), findsOneWidget);
    expect(find.text('Document is blurry. Please retake.'), findsOneWidget);
  });
}
