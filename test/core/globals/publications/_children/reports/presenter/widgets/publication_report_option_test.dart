import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/core.dart';

void main() {
  group('ReportOption', () {
    testWidgets('muestra el texto proporcionado', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReportOption(label: 'Spam', isSelected: false, onTap: () {}),
          ),
        ),
      );

      expect(find.text('Spam'), findsOneWidget);
    });

    testWidgets('muestra el ícono deseleccionado cuando isSelected es false', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReportOption(label: 'Spam', isSelected: false, onTap: () {}),
          ),
        ),
      );

      expect(find.byIcon(Icons.radio_button_off), findsOneWidget);
      expect(find.byIcon(Icons.radio_button_checked), findsNothing);
    });

    testWidgets('muestra el ícono seleccionado cuando isSelected es true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReportOption(
              label: 'Inapropiated',
              isSelected: true,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.radio_button_checked), findsOneWidget);
      expect(find.byIcon(Icons.radio_button_off), findsNothing);
    });

    testWidgets('llama a onTap al tocar la opción', (
      WidgetTester tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReportOption(
              label: 'Other',
              isSelected: true,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ReportOption));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
