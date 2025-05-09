import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/profile/profile.dart';

void main() {
  group('PublicationCard Widget Tests', () {
    testWidgets('renders post data correctly', (WidgetTester tester) async {
      final post = {
        'username': 'TestUser',
        'createdAt': DateTime.now().subtract(const Duration(hours: 2)),
        'text': 'This is a test post.',
        'attachments': [],
        'reactions': 5,
        'comments': 2,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PublicationCard(post: post),
          ),
        ),
      );

      expect(find.text('TestUser'), findsOneWidget);
      expect(find.text('This is a test post.'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('displays image if attachment exists', (WidgetTester tester) async {
      final post = {
        'username': 'TestUser',
        'createdAt': DateTime.now(),
        'text': 'With image',
        'attachments': ['https://via.placeholder.com/150'],
        'reactions': 0,
        'comments': 0,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PublicationCard(post: post),
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('calls onDelete when menu item is selected', (WidgetTester tester) async {
      bool wasDeleted = false;

      final post = {
        'username': 'TestUser',
        'createdAt': DateTime.now(),
        'text': 'Test',
        'attachments': [],
        'reactions': 0,
        'comments': 0,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PublicationCard(
              post: post,
              onDelete: () {
                wasDeleted = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(wasDeleted, isTrue);
    });
  });
}
