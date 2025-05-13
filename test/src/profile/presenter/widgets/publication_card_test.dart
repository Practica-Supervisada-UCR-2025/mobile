import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/profile/profile.dart';
import 'package:network_image_mock/network_image_mock.dart';

void main() {
  group('PublicationCard Widget', () {
    late Publication shortPost;
    late Publication longPostWithImage;

    setUp(() {
      shortPost = Publication(
        id: 1,
        username: 'TestUser',
        profileImageUrl: 'https://example.com/avatar.jpg',
        content: 'Short content.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        attachment: null,
        likes: 10,
        comments: 5,
      );

      longPostWithImage = Publication(
        id: 2,
        username: 'LongPoster',
        profileImageUrl: 'https://example.com/avatar2.jpg',
        content: 'L' * 300,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        attachment: 'https://example.com/image.jpg',
        likes: 42,
        comments: 9,
      );
    });

    testWidgets('renders username, content and counters correctly', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(MaterialApp(home: PublicationCard(publication: shortPost)));

        expect(find.text('TestUser'), findsOneWidget);
        expect(find.text('Short content.'), findsOneWidget);
        expect(find.text('10'), findsOneWidget);
        expect(find.text('5'), findsOneWidget);
      });
    });

    testWidgets('displays image if attachment is provided', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(MaterialApp(home: PublicationCard(publication: longPostWithImage)));

        expect(find.byType(Image), findsWidgets);
      });
    });

    testWidgets('shows and toggles See more / See less on long content', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(MaterialApp(home: PublicationCard(publication: longPostWithImage)));

        expect(find.textContaining('See more'), findsOneWidget);
        await tester.tap(find.text('See more'));
        await tester.pumpAndSettle();
        expect(find.text('See less'), findsOneWidget);
      });
    });

    testWidgets('shows PopupMenuButton with "Delete" option', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(MaterialApp(home: PublicationCard(publication: shortPost)));

        await tester.tap(find.byIcon(Icons.more_vert));
        await tester.pumpAndSettle();
        expect(find.text('Delete'), findsOneWidget);
      });
    });

    testWidgets('executes onSelected callback from PopupMenuButton', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(MaterialApp(home: PublicationCard(publication: shortPost)));

        await tester.tap(find.byIcon(Icons.more_vert));
        await tester.pumpAndSettle();
        await tester.tap(find.byWidgetPredicate(
          (widget) => widget is PopupMenuItem<String> && widget.value == 'delete',
        ));
        await tester.pumpAndSettle(); // Ejecuta onSelected
      });
    });

    testWidgets('shows correct relative time (1 month ago)', (tester) async {
      final postWithOldDate = Publication(
        id: shortPost.id,
        username: shortPost.username,
        profileImageUrl: shortPost.profileImageUrl,
        content: shortPost.content,
        createdAt: DateTime.now().subtract(const Duration(days: 40)),
        attachment: shortPost.attachment,
        likes: shortPost.likes,
        comments: shortPost.comments,
      );

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(MaterialApp(home: PublicationCard(publication: postWithOldDate)));
        expect(find.textContaining('1 month'), findsOneWidget);
      });
    });

    testWidgets('shows correct relative time (3 hours ago)', (tester) async {
      final postWithHours = Publication(
        id: shortPost.id,
        username: shortPost.username,
        profileImageUrl: shortPost.profileImageUrl,
        content: shortPost.content,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        attachment: shortPost.attachment,
        likes: shortPost.likes,
        comments: shortPost.comments,
      );

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(MaterialApp(home: PublicationCard(publication: postWithHours)));
        expect(find.textContaining('3 hour'), findsOneWidget);
      });
    });

    testWidgets('shows "just now" for recent post', (tester) async {
      final postJustNow = Publication(
        id: shortPost.id,
        username: shortPost.username,
        profileImageUrl: shortPost.profileImageUrl,
        content: shortPost.content,
        createdAt: DateTime.now().subtract(const Duration(seconds: 30)),
        attachment: shortPost.attachment,
        likes: shortPost.likes,
        comments: shortPost.comments,
      );

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(MaterialApp(home: PublicationCard(publication: postJustNow)));
        expect(find.text('just now'), findsOneWidget);
      });
    });
  });
}
