import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/core.dart';

void main() {
  group('FeedbackContent', () {
    const icon = Icons.info;
    const color = Colors.blue;
    const title = 'Test Title';
    const message = 'This is a test message.';

    testWidgets(
      'renders icon, title, message, and button with correct styles',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FeedbackContent(
                icon: icon,
                color: color,
                title: title,
                message: message,
                onClose: () {},
              ),
            ),
          ),
        );

        expect(find.byIcon(icon), findsOneWidget);
        expect(find.text(title), findsOneWidget);
        expect(find.text(message), findsOneWidget);
        expect(find.text('Close'), findsOneWidget);

        final titleWidget = tester.widget<Text>(find.text(title));
        expect(titleWidget.style?.fontWeight, FontWeight.bold);
        expect(titleWidget.style?.fontSize, 20);

        final messageWidget = tester.widget<Text>(find.text(message));
        expect(messageWidget.style?.fontSize, 15);
      },
    );

    testWidgets('calls onClose callback when button is tapped', (tester) async {
      bool wasClosed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedbackContent(
              icon: icon,
              color: color,
              title: title,
              message: message,
              onClose: () {
                wasClosed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Close'));
      await tester.pump();

      expect(wasClosed, isTrue);
    });
  });
}
