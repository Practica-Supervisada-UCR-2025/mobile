import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
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
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(body: Text('Home')),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) => const CreatePage(),
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      router.push('/create');
      await tester.pumpAndSettle();

      final cancelButton = find.text('Cancel');
      expect(cancelButton, findsOneWidget);

      await tester.tap(cancelButton);
      await tester.pumpAndSettle();
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
