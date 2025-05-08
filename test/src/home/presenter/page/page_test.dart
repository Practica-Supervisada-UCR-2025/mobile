import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/home/presenter/page/page.dart';

void main() {
  testWidgets('HomeScreen displays "Home screen" text', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(),
      ),
    );
    expect(find.text('Home screen'), findsOneWidget);
  });
}
