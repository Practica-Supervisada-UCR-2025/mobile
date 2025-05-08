import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/create/presenter/page/page.dart'; 

void main() {
  testWidgets('CreateScreen displays "Create screen" text', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CreateScreen(),
      ),
    );
    expect(find.text('Create screen'), findsOneWidget);
  });
}
