import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:mobile/core/core.dart' show DEFAULT_PROFILE_PIC;
import 'package:mobile/core/globals/publications/publications.dart'
    show Publication, PublicationCard;

void main() {
  Future<void> pumpCard(
    WidgetTester tester,
    Publication pub, {
    ThemeData? theme,
  }) async {
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme ?? ThemeData.light(),
          darkTheme: ThemeData.dark(),
          home: Scaffold(body: PublicationCard(publication: pub)),
        ),
      );
      await tester.pumpAndSettle();
    });
  }

  testWidgets(
    'displays avatar, username, relative minutes ago, likes & comments',
    (WidgetTester tester) async {
      final createdAt = DateTime.now().subtract(const Duration(minutes: 5));
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

  testWidgets('subtle bottom border is applied', (WidgetTester tester) async {
    final pub = Publication(
      id: 2,
      username: 'border',
      profileImageUrl: '',
      content: 'Border test',
      createdAt: DateTime.now(),
      attachment: null,
      likes: 0,
      comments: 0,
    );

    final lightTheme = ThemeData.light();
    await pumpCard(tester, pub, theme: lightTheme);

    final container = tester.widget<Container>(find.byType(Container).first);
    final decoration = container.decoration as BoxDecoration;
    final borderSide = decoration.border!.bottom;

    expect(borderSide.width, 0.3);
    expect(borderSide.color, lightTheme.colorScheme.outline);
  });

  testWidgets('CircleAvatar uses default + foreground images',
      (WidgetTester tester) async {
    const avatarUrl = 'https://example.com/user.png';
    final pub = Publication(
      id: 99,
      username: 'avataruser',
      profileImageUrl: avatarUrl,
      content: 'Irrelevant',
      createdAt: DateTime.now(),
      attachment: null,
      likes: 0,
      comments: 0,
    );

    await pumpCard(tester, pub);

    final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
    final bg = avatar.backgroundImage as NetworkImage;
    expect(bg.url, DEFAULT_PROFILE_PIC);

    final fg = avatar.foregroundImage as NetworkImage;
    expect(fg.url, avatarUrl);
  });

  testWidgets('renders attachment inside ClipRRect when URL is provided',
      (WidgetTester tester) async {
    const fileUrl = 'https://example.com/file.jpg';
    final pub = Publication(
      id: 3,
      username: 'imguser',
      profileImageUrl: '',
      content: 'With image',
      createdAt: DateTime.now(),
      attachment: fileUrl,
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
    final network = image.image as NetworkImage;
    expect(network.url, fileUrl);
  });

  testWidgets('popup menu has Delete option and can be tapped',
      (WidgetTester tester) async {
    final pub = Publication(
      id: 4,
      username: 'menuuser',
      profileImageUrl: '',
      content: 'Menu test',
      createdAt: DateTime.now(),
      attachment: null,
      likes: 0,
      comments: 0,
    );

    await pumpCard(tester, pub);

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    expect(find.text('Delete'), findsOneWidget);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Delete'), findsNothing);
  });

  testWidgets('Expandable text: short content does not show See more',
      (WidgetTester tester) async {
    final pub = Publication(
      id: 5,
      username: 'short',
      profileImageUrl: '',
      content: 'A' * 50,
      createdAt: DateTime.now(),
      attachment: null,
      likes: 0,
      comments: 0,
    );

    await pumpCard(tester, pub);

    expect(find.textContaining('...'), findsNothing);
    expect(find.text('See more'), findsNothing);
  });

  testWidgets(
    'Expandable text: long content shows See more, toggles to See less',
    (WidgetTester tester) async {
      final longText = 'X' * 300;
      final pub = Publication(
        id: 6,
        username: 'longuser',
        profileImageUrl: '',
        content: longText,
        createdAt: DateTime.now(),
        attachment: null,
        likes: 0,
        comments: 0,
      );

      await pumpCard(tester, pub);

      final truncated = '${longText.substring(0, 250)}...';
      expect(find.text(truncated), findsOneWidget);
      expect(find.text('See more'), findsOneWidget);

      await tester.tap(find.text('See more'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.text(longText), findsOneWidget);
      expect(find.text('See less'), findsOneWidget);

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

      final pubJust = Publication(
        id: 7,
        username: 'just',
        profileImageUrl: '',
        content: '',
        createdAt: now,
        attachment: null,
        likes: 0,
        comments: 0,
      );
      await pumpCard(tester, pubJust);
      expect(find.text('just now'), findsOneWidget);

      final pubMin = Publication(
        id: 8,
        username: 'min',
        profileImageUrl: '',
        content: '',
        createdAt: now.subtract(const Duration(minutes: 2)),
        attachment: null,
        likes: 0,
        comments: 0,
      );
      await pumpCard(tester, pubMin);
      expect(find.text('2 minutes ago'), findsOneWidget);

      final pubHour = Publication(
        id: 9,
        username: 'hour',
        profileImageUrl: '',
        content: '',
        createdAt: now.subtract(const Duration(hours: 3)),
        attachment: null,
        likes: 0,
        comments: 0,
      );
      await pumpCard(tester, pubHour);
      expect(find.text('3 hours ago'), findsOneWidget);

      final pubDay = Publication(
        id: 10,
        username: 'day',
        profileImageUrl: '',
        content: '',
        createdAt: now.subtract(const Duration(days: 2)),
        attachment: null,
        likes: 0,
        comments: 0,
      );
      await pumpCard(tester, pubDay);
      expect(find.text('2 days ago'), findsOneWidget);

      final pubMon = Publication(
        id: 11,
        username: 'month',
        profileImageUrl: '',
        content: '',
        createdAt: now.subtract(const Duration(days: 65)),
        attachment: null,
        likes: 0,
        comments: 0,
      );
      await pumpCard(tester, pubMon);
      expect(find.text('2 months ago'), findsOneWidget);
    },
  );
}
