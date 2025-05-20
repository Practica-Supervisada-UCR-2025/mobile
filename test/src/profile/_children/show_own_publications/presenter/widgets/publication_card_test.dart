import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:mobile/src/profile/profile.dart';

void main() {
  late Publication basePost;

  setUp(() {
    basePost = Publication(
      id: 1,
      username: 'TestUser',
      profileImageUrl: 'https://example.com/avatar.jpg',
      content: 'Base content.',
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      attachment: null,
      likes: 7,
      comments: 3,
    );
  });

  testWidgets('shows user data and counters without attached image',
      (WidgetTester tester) async {
    // Wrap in mockNetworkImagesFor to avoid real HTTP for avatar
    await mockNetworkImagesFor(() async {
      // GIVEN: a PublicationCard with no attachment
      await tester.pumpWidget(
        MaterialApp(home: PublicationCard(publication: basePost)),
      );
      await tester.pump();

      // THEN: username, content and reaction counts appear
      expect(find.text('TestUser'), findsOneWidget);
      expect(find.text('Base content.'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);

      // AND: no ClipRRect for an attachment
      expect(find.byType(ClipRRect), findsNothing);
    });
  });

  testWidgets('shows attached image and truncated text with See more',
      (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      // GIVEN: a long post (>250 chars) with attachment
      final longContent = 'A' * 300;
      final postWithImage = Publication(
        id: basePost.id,
        username: basePost.username,
        profileImageUrl: basePost.profileImageUrl,
        content: longContent,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        attachment: 'https://example.com/image.jpg',
        likes: 15,
        comments: 4,
      );

      await tester.pumpWidget(
        MaterialApp(home: PublicationCard(publication: postWithImage)),
      );
      await tester.pump();

      // THEN: an image is shown inside a ClipRRect
      expect(find.byType(ClipRRect), findsOneWidget);
      expect(find.byType(Image), findsWidgets);

      // AND: content is truncated (ends with '...')
      final truncated = '${longContent.substring(0, 250)}...';
      expect(find.text(truncated), findsOneWidget);

      // AND: a 'See more' button is present
      expect(find.text('See more'), findsOneWidget);
    });
  });

  testWidgets('expands and collapses long text by pressing See more / See less',
      (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      // GIVEN: the same long post with attachment
      final longContent = 'B' * 300;
      final postWithImage = Publication(
        id: basePost.id,
        username: basePost.username,
        profileImageUrl: basePost.profileImageUrl,
        content: longContent,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        attachment: 'https://example.com/image.jpg',
        likes: 15,
        comments: 4,
      );

      await tester.pumpWidget(
        MaterialApp(home: PublicationCard(publication: postWithImage)),
      );
      await tester.pump();

      // Initially truncated + 'See more'
      final truncated = '${longContent.substring(0, 250)}...';
      expect(find.text(truncated), findsOneWidget);
      expect(find.text('See more'), findsOneWidget);

      // WHEN tapping 'See more'
      await tester.tap(find.text('See more'));
      await tester.pump();

      // THEN full content and 'See less'
      expect(find.text(longContent), findsOneWidget);
      expect(find.text('See less'), findsOneWidget);

      // WHEN tapping 'See less'
      await tester.tap(find.text('See less'));
      await tester.pump();

      // THEN back to truncated + 'See more'
      expect(find.text(truncated), findsOneWidget);
      expect(find.text('See more'), findsOneWidget);
    });
  });

  testWidgets('displays and closes PopupMenu with Delete option',
      (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      // GIVEN: a PublicationCard with basePost
      await tester.pumpWidget(
        MaterialApp(home: PublicationCard(publication: basePost)),
      );
      await tester.pump();

      // WHEN tapping the menu icon
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // THEN: the 'Delete' menu item appears
      expect(find.text('Delete'), findsOneWidget);

      // WHEN selecting 'Delete'
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // THEN: the menu is dismissed
      expect(find.text('Delete'), findsNothing);
    });
  });

  // DATE FORMATTING TESTS

  testWidgets('format date as 2 months ago',
      (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      final post = Publication(
        id: basePost.id,
        username: basePost.username,
        profileImageUrl: basePost.profileImageUrl,
        content: basePost.content,
        createdAt: DateTime.now().subtract(const Duration(days: 65)),
        attachment: basePost.attachment,
        likes: basePost.likes,
        comments: basePost.comments,
      );
      await tester.pumpWidget(
        MaterialApp(home: PublicationCard(publication: post)),
      );
      await tester.pump();
      expect(find.text('2 months ago'), findsOneWidget);
    });
  });

  testWidgets('format date as 1 month ago',
      (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      final post = Publication(
        id: basePost.id,
        username: basePost.username,
        profileImageUrl: basePost.profileImageUrl,
        content: basePost.content,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        attachment: basePost.attachment,
        likes: basePost.likes,
        comments: basePost.comments,
      );
      await tester.pumpWidget(
        MaterialApp(home: PublicationCard(publication: post)),
      );
      await tester.pump();
      expect(find.text('1 month ago'), findsOneWidget);
    });
  });

  testWidgets('format date as 1 day ago',
      (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      final post = Publication(
        id: basePost.id,
        username: basePost.username,
        profileImageUrl: basePost.profileImageUrl,
        content: basePost.content,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        attachment: basePost.attachment,
        likes: basePost.likes,
        comments: basePost.comments,
      );
      await tester.pumpWidget(
        MaterialApp(home: PublicationCard(publication: post)),
      );
      await tester.pump();
      expect(find.text('1 day ago'), findsOneWidget);
    });
  });

  testWidgets('format date as 5 days ago',
      (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      final post = Publication(
        id: basePost.id,
        username: basePost.username,
        profileImageUrl: basePost.profileImageUrl,
        content: basePost.content,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        attachment: basePost.attachment,
        likes: basePost.likes,
        comments: basePost.comments,
      );
      await tester.pumpWidget(
        MaterialApp(home: PublicationCard(publication: post)),
      );
      await tester.pump();
      expect(find.text('5 days ago'), findsOneWidget);
    });
  });

  testWidgets('format date as 1 hour ago',
      (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      final post = Publication(
        id: basePost.id,
        username: basePost.username,
        profileImageUrl: basePost.profileImageUrl,
        content: basePost.content,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        attachment: basePost.attachment,
        likes: basePost.likes,
        comments: basePost.comments,
      );
      await tester.pumpWidget(
        MaterialApp(home: PublicationCard(publication: post)),
      );
      await tester.pump();
      expect(find.text('1 hour ago'), findsOneWidget);
    });
  });

  testWidgets('format date as 3 hours ago',
      (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      final post = Publication(
        id: basePost.id,
        username: basePost.username,
        profileImageUrl: basePost.profileImageUrl,
        content: basePost.content,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        attachment: basePost.attachment,
        likes: basePost.likes,
        comments: basePost.comments,
      );
      await tester.pumpWidget(
        MaterialApp(home: PublicationCard(publication: post)),
      );
      await tester.pump();
      expect(find.text('3 hours ago'), findsOneWidget);
    });
  });

  testWidgets('format date as 1 minute ago',
      (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      final post = Publication(
        id: basePost.id,
        username: basePost.username,
        profileImageUrl: basePost.profileImageUrl,
        content: basePost.content,
        createdAt: DateTime.now().subtract(const Duration(minutes: 1)),
        attachment: basePost.attachment,
        likes: basePost.likes,
        comments: basePost.comments,
      );
      await tester.pumpWidget(
        MaterialApp(home: PublicationCard(publication: post)),
      );
      await tester.pump();
      expect(find.text('1 minute ago'), findsOneWidget);
    });
  });

  testWidgets('format date as 10 minutes ago',
      (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      final post = Publication(
        id: basePost.id,
        username: basePost.username,
        profileImageUrl: basePost.profileImageUrl,
        content: basePost.content,
        createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
        attachment: basePost.attachment,
        likes: basePost.likes,
        comments: basePost.comments,
      );
      await tester.pumpWidget(
        MaterialApp(home: PublicationCard(publication: post)),
      );
      await tester.pump();
      expect(find.text('10 minutes ago'), findsOneWidget);
    });
  });

  testWidgets('format date as just now',
      (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      final post = Publication(
        id: basePost.id,
        username: basePost.username,
        profileImageUrl: basePost.profileImageUrl,
        content: basePost.content,
        createdAt: DateTime.now().subtract(const Duration(seconds: 30)),
        attachment: basePost.attachment,
        likes: basePost.likes,
        comments: basePost.comments,
      );
      await tester.pumpWidget(
        MaterialApp(home: PublicationCard(publication: post)),
      );
      await tester.pump();
      expect(find.text('just now'), findsOneWidget);
    });
  });
}
