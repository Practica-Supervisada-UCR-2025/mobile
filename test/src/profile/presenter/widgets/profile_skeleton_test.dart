import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/profile/presenter/widgets/profile_skeleton.dart';

void main() {
  testWidgets('ProfileSkeleton renders without errors', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProfileSkeleton(),
        ),
      ),
    );

    expect(find.byType(ProfileSkeleton), findsOneWidget);
  });

  testWidgets('ProfileSkeleton contains shimmer placeholders', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProfileSkeleton(),
        ),
      ),
    );

    expect(find.byType(Container), findsWidgets);
    expect(find.byType(CircleAvatar), findsOneWidget);
  });

  testWidgets('ProfileSkeleton has two button placeholders', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProfileSkeleton(),
        ),
      ),
    );

    final buttonPlaceholders = tester.widgetList<Container>(
      find.byType(Container),
    ).toList();

    expect(buttonPlaceholders.length, greaterThanOrEqualTo(2));
  });
}
