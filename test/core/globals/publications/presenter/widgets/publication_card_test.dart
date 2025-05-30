import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';

import 'package:mobile/core/globals/publications/publications.dart'
    show Publication, PublicationCard;

void main() {
  Future<void> pumpCard(
      WidgetTester tester, Publication publication) async {
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PublicationCard(publication: publication),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    });
  }

  testWidgets(
    'displays avatar, username, relative minutes ago, likes & comments',
    (WidgetTester tester) async {
      final createdAt =
          DateTime.now().subtract(const Duration(minutes: 5));
      final pub = Publication(
        id: 1,
        username: 'testuser',
        profileImageUrl: 'https://example.com/avatar.png',
        content: 'Short content',
        createdAt: createdAt,
        attachment: null,
        likes: 42,
        comments: 7,
      );

      await pumpCard(tester, pub);

      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.text('testuser'), findsOneWidget);
      expect(find.text('5 minutes ago'), findsOneWidget);
      expect(find.text('Short content'), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
      expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
    },
  );

  testWidgets(
    'subtle bottom border is applied',
    (WidgetTester tester) async {
      final pub = Publication(
        id: 2,
        username: 'border',
        profileImageUrl: 'url',
        content: 'Border test',
        createdAt: DateTime.now(),
        attachment: null,
        likes: 0,
        comments: 0,
      );

      await pumpCard(tester, pub);

      final container = tester.widget<Container>(
        find.byType(Container).first,
      );
      final decoration = container.decoration as BoxDecoration;
      final borderSide = decoration.border!.bottom;

      expect(borderSide.color, Colors.grey.shade300);
      expect(borderSide.width, 0.3);
    },
  );

  testWidgets(
    'renders attachment inside ClipRRect when URL is provided',
    (WidgetTester tester) async {
      final pub = Publication(
        id: 3,
        username: 'imguser',
        profileImageUrl: 'https://example.com/avatar.png',
        content: 'With image',
        createdAt: DateTime.now(),
        attachment: 'https://example.com/file.jpg',
        likes: 0,
        comments: 0,
      );

      await pumpCard(tester, pub);

      expect(find.byType(ClipRRect), findsOneWidget);
      final imageFinder = find.descendant(
        of: find.byType(ClipRRect),
        matching: find.byType(Image),
      );
      expect(imageFinder, findsOneWidget);
      final image = tester.widget<Image>(imageFinder);
      expect((image.image as NetworkImage).url,
          'https://example.com/file.jpg');
    },
  );

  testWidgets(
    'popup menu has Delete option and onSelected can be tapped',
    (WidgetTester tester) async {
      final pub = Publication(
        id: 4,
        username: 'menuuser',
        profileImageUrl: 'https://example.com/avatar.png',
        content: 'Menu test',
        createdAt: DateTime.now(),
        attachment: null,
        likes: 0,
        comments: 0,
      );

      await pumpCard(tester, pub);

      // Open the popup menu
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      // The menu item should appear
      expect(find.text('Delete'), findsOneWidget);

      // Tap the Delete item
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // It should close without error
      expect(find.text('Delete'), findsNothing);
    },
  );

  testWidgets(
    'Expandable text: short content does not show See more',
    (WidgetTester tester) async {
      final pub = Publication(
        id: 5,
        username: 'short',
        profileImageUrl: 'https://example.com/avatar.png',
        content: 'A' * 50, // less than 250 chars
        createdAt: DateTime.now(),
        attachment: null,
        likes: 0,
        comments: 0,
      );

      await pumpCard(tester, pub);

      expect(find.textContaining('...'), findsNothing);
      expect(find.text('See more'), findsNothing);
    },
  );

  testWidgets(
    'Expandable text: long content shows See more, toggles to See less',
    (WidgetTester tester) async {
      final longText = 'X' * 300;
      final pub = Publication(
        id: 6,
        username: 'longuser',
        profileImageUrl: 'https://example.com/avatar.png',
        content: longText,
        createdAt: DateTime.now(),
        attachment: null,
        likes: 0,
        comments: 0,
      );

      await pumpCard(tester, pub);

      final truncated = '${longText.substring(0, 250)}...';
      expect(find.text(truncated), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('See more'),
        200,
        scrollable: find.byType(Scrollable),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('See more'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.text(longText), findsOneWidget);
      expect(find.text('See less'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('See less'),
        200,
        scrollable: find.byType(Scrollable),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('See less'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.text(truncated), findsOneWidget);
      expect(find.text('See more'), findsOneWidget);
    },
  );

  testWidgets(
    'formats minutes, hours, days and months correctly',
    (WidgetTester tester) async {
      final now = DateTime.now();

      // just now
      final pubJustNow = Publication(
        id: 7,
        username: 'just',
        profileImageUrl: 'url',
        content: '',
        createdAt: now,
        attachment: null,
        likes: 0,
        comments: 0,
      );
      await pumpCard(tester, pubJustNow);
      expect(find.text('just now'), findsOneWidget);

      // minutes ago
      final pubMin = Publication(
        id: 8,
        username: 'min',
        profileImageUrl: 'url',
        content: '',
        createdAt: now.subtract(const Duration(minutes: 2)),
        attachment: null,
        likes: 0,
        comments: 0,
      );
      await pumpCard(tester, pubMin);
      expect(find.text('2 minutes ago'), findsOneWidget);

      // hours ago
      final pubHour = Publication(
        id: 9,
        username: 'hour',
        profileImageUrl: 'url',
        content: '',
        createdAt: now.subtract(const Duration(hours: 3)),
        attachment: null,
        likes: 0,
        comments: 0,
      );
      await pumpCard(tester, pubHour);
      expect(find.text('3 hours ago'), findsOneWidget);

      // days ago
      final pubDay = Publication(
        id: 10,
        username: 'day',
        profileImageUrl: 'url',
        content: '',
        createdAt: now.subtract(const Duration(days: 2)),
        attachment: null,
        likes: 0,
        comments: 0,
      );
      await pumpCard(tester, pubDay);
      expect(find.text('2 days ago'), findsOneWidget);

      // months ago (65 days)
      final pubMonth = Publication(
        id: 11,
        username: 'month',
        profileImageUrl: 'url',
        content: '',
        createdAt: now.subtract(const Duration(days: 65)),
        attachment: null,
        likes: 0,
        comments: 0,
      );
      await pumpCard(tester, pubMonth);
      expect(find.text('2 months ago'), findsOneWidget);
    },
  );
}
