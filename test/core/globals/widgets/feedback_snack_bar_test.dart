import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/core.dart';

void main() {
  testWidgets('showSuccess displays a SnackBar with success icon and message', (
    WidgetTester tester,
  ) async {
    const testMessage = 'Success!';

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed:
                      () => FeedbackSnackBar.showSuccess(context, testMessage),
                  child: const Text('Show Success'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Show Success'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text(testMessage), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
  });

  testWidgets('showError displays a SnackBar with error icon and message', (
    WidgetTester tester,
  ) async {
    const testMessage = 'Error occurred';

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed:
                      () => FeedbackSnackBar.showError(context, testMessage),
                  child: const Text('Show Error'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Show Error'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text(testMessage), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });

  testWidgets('showWarning displays a SnackBar with warning icon and message', (
    WidgetTester tester,
  ) async {
    const testMessage = 'Warning!';

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed:
                      () => FeedbackSnackBar.showWarning(context, testMessage),
                  child: const Text('Show Warning'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Show Warning'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text(testMessage), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber_outlined), findsOneWidget);
  });
}
