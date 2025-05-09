import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/home/_children/posts/posts.dart';

void main() {
  testWidgets('PostsPage shows "No posts available" message', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PostsPage(),
      ),
    );

    expect(find.text('No posts available'), findsOneWidget);
  });
}
