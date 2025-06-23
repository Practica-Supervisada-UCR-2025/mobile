import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/core.dart';

void main() {
  testWidgets('displays correct message text', (WidgetTester tester) async {
    // Arrange
    final snackBar = SessionExpiredSnackBar();

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
                child: const Text('Show SnackBar'),
              );
            },
          ),
        ),
      ),
    );

    // Show SnackBar
    await tester.tap(find.text('Show SnackBar'));
    await tester.pump(); // Start animation

    // Assert
    expect(
      find.text('Your session has expired. Please log in again.'),
      findsOneWidget,
    );
  });

  testWidgets('has correct background color and shape', (
    WidgetTester tester,
  ) async {
    final snackBar = SessionExpiredSnackBar();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
                child: const Text('Show SnackBar'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show SnackBar'));
    await tester.pump();

    // Busca el SnackBar por tipo
    final snackBarWidget = tester.widget<SnackBar>(find.byType(SnackBar));

    expect(snackBarWidget.backgroundColor, AppColors.warning);
    expect(snackBarWidget.behavior, SnackBarBehavior.floating);
    expect(snackBarWidget.shape, isA<RoundedRectangleBorder>());
  });
}
