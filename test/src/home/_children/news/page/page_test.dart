import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/home/_children/news/news.dart';

void main() {
  testWidgets('NewsPage shows "No news available" message', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: NewsPage(),
      ),
    );

    expect(find.text('No news available'), findsOneWidget);
  });
}
