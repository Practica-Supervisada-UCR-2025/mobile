import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/search/presenter/page/page.dart';

void main() {
  testWidgets('SearchScreen displays "Search" text', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SearchScreen(),
      ),
    );
    expect(find.text('Search screen'), findsOneWidget);
  });
}
