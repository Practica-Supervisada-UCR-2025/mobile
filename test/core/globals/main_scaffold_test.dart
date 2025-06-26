import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/globals/main_scaffold.dart';

void main() {
  late GoRouter router;

  Widget createTestApp(Widget child) {
    router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => child,
        ),
        GoRoute(
          path: '/search',
          builder: (context, state) => const Text('Search Page'),
        ),
        GoRoute(
          path: '/create',
          builder: (context, state) => const Text('Create Page'),
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const Text('Notifications Page'),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const Text('Profile Page'),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const Text('Home Page'),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const Text('Settings Page'),
        ),
      ],
    );

    return MaterialApp.router(
      routerConfig: router,
    );
  }

  Future<void> pumpMainScaffold(WidgetTester tester, int currentIndex) async {
    await tester.pumpWidget(
      createTestApp(
        MainScaffold(
          currentIndex: currentIndex,
          child: const SizedBox(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('BottomNavigationBar displays 5 items', (WidgetTester tester) async {
    await pumpMainScaffold(tester, 0);

    expect(find.byType(BottomNavigationBar), findsOneWidget);

    final bottomNavigationBar = tester.widget<BottomNavigationBar>(
      find.byType(BottomNavigationBar),
    );
    expect(bottomNavigationBar.items.length, 5);
  });

  testWidgets('navigates to /search on tap', (WidgetTester tester) async {
    await pumpMainScaffold(tester, 0);

    await tester.tap(find.byIcon(Icons.search_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Search Page'), findsOneWidget);
  });

  testWidgets('navigates to /create on tap', (WidgetTester tester) async {
    await pumpMainScaffold(tester, 1);

    await tester.tap(find.byIcon(Icons.add_box_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Create Page'), findsOneWidget);
  });

  testWidgets('navigates to /notifications on tap', (WidgetTester tester) async {
    await pumpMainScaffold(tester, 2);

    await tester.tap(find.byIcon(Icons.notifications_none));
    await tester.pumpAndSettle();

    expect(find.text('Notifications Page'), findsOneWidget);
  });

  testWidgets('navigates to /profile on tap', (WidgetTester tester) async {
    await pumpMainScaffold(tester, 3);

    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pumpAndSettle();

    expect(find.text('Profile Page'), findsOneWidget);
  });

  testWidgets('navigates to /home on tap', (WidgetTester tester) async {
    await pumpMainScaffold(tester, 4);

    await tester.tap(find.byIcon(Icons.home_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Home Page'), findsOneWidget);
  });

  testWidgets('navigates to /settings when pressing more_vert button', (WidgetTester tester) async {
    await pumpMainScaffold(tester, 0);

    expect(find.byIcon(Icons.more_vert), findsOneWidget);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    expect(find.text('Settings Page'), findsOneWidget);
  });
}
