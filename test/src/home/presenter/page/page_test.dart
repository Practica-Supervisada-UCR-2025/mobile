import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/home/presenter/presenter.dart';
import 'package:mobile/src/home/_children/news/news.dart';
import 'package:mobile/src/home/_children/posts/posts.dart';

void main() {
  testWidgets('HomeScreen shows tabs and switches between News and Posts', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: HomeScreen()),
      ),
    );

    expect(find.text('News'), findsOneWidget);
    expect(find.text('Posts'), findsOneWidget);

    expect(find.byType(NewsPage), findsOneWidget);
    expect(find.byType(PostsPage), findsNothing);
    expect(find.text('No news available'), findsOneWidget);

    await tester.tap(find.text('Posts'));
    await tester.pumpAndSettle();

    expect(find.byType(NewsPage), findsNothing);
    expect(find.byType(PostsPage), findsOneWidget);
    expect(find.text('No posts available'), findsOneWidget);
  });
}
