import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/notifications/presenter/page/page.dart'; 

void main() {
  testWidgets('NotificationsScreen displays "Notifications" text', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: NotificationsScreen(),
      ),
    );
    expect(find.text('Notifications screen'), findsOneWidget);
  });
}
