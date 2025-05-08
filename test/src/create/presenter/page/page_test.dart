import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/create/create.dart';

void main() {
  group('CreatePage', () {
    testWidgets('renders CreatePage and subcomponents', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreatePage(),
        ),
      );

      expect(find.byType(CreatePage), findsOneWidget);
      expect(find.byType(TopActions), findsOneWidget);
      expect(find.byType(PostTextField), findsOneWidget);
      expect(find.byType(BottomBar), findsOneWidget);
    });

    testWidgets('renders a TextField with placeholder', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreatePage(),
        ),
      );

      // Verifica el placeholder del TextField
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('What’s on your mind?'), findsOneWidget);
    });

    testWidgets('can enter text in PostTextField', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreatePage(),
        ),
      );

      final field = find.byType(TextField);
      expect(field, findsOneWidget);

      await tester.enterText(field, 'Hello world!');
      await tester.pump();

      expect(find.text('Hello world!'), findsOneWidget);
    });

    testWidgets('Cancel button exists and can be tapped', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreatePage(),
        ),
      );

      final cancelButton = find.text('Cancel');
      expect(cancelButton, findsOneWidget);

      await tester.tap(cancelButton);
      await tester.pumpAndSettle(); // No hay navegación ahora, pero se puede extender
    });

    testWidgets('Post button exists', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreatePage(),
        ),
      );

      final postButton = find.text('Post');
      expect(postButton, findsOneWidget);
    });

    testWidgets('BottomBar contains image button icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreatePage(),
        ),
      );

      expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    });
  });
}
