import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/profile/profile.dart';
void main() {
  group('PublicationsList Widget Tests', () {
    testWidgets('loads initial posts and renders list', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PublicationsList(),
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 2)); // espera por _loadMore

      expect(find.byType(PublicationCard), findsWidgets);
    });

    testWidgets('shows loading indicator when loading', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PublicationsList(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
