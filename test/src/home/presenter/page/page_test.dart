
// void main() {
  // testWidgets('HomeScreen shows tabs "Posts" and "News" and switches between them',
  //     (WidgetTester tester) async {
  //   await tester.pumpWidget(
  //     MaterialApp(
  //       home: const HomeScreen(isFeed: true),
  //     ),
  //   );

  //   expect(find.byType(PostsPage), findsOneWidget);
  //   expect(find.byType(PublicationsList), findsOneWidget);

  //   expect(find.byType(NewsPage), findsNothing);
  //   expect(find.text('No news available'), findsNothing);

  //   await tester.tap(find.text('News'));
  //   await tester.pumpAndSettle();

  //   expect(find.byType(NewsPage), findsOneWidget);
  //   expect(find.text('No news available'), findsOneWidget);

  //   await tester.tap(find.text('Posts'));
  //   await tester.pumpAndSettle();

  //   expect(find.byType(PostsPage), findsOneWidget);
  //   expect(find.byType(PublicationsList), findsOneWidget);
  // });
// }
