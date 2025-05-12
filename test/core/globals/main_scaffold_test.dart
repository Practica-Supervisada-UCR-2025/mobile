import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/core/globals/main_scaffold.dart';

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  late MockGoRouter mockRouter;

  setUp(() {
    mockRouter = MockGoRouter();
    when(() => mockRouter.go(any())).thenAnswer((_) async {});
    when(() => mockRouter.push(any())).thenAnswer((_) async => null);
  });

  Widget wrapWithGoRouter(Widget child) {
    return InheritedGoRouter(
      goRouter: mockRouter,
      child: MaterialApp(home: child),
    );
  }

  Future<void> pumpMainScaffold(WidgetTester tester, int currentIndex) async {
    await tester.pumpWidget(
      wrapWithGoRouter(
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

  testWidgets('navigates to correct route on BottomNavigationBar tap', (WidgetTester tester) async {
    await pumpMainScaffold(tester, 0);

    await tester.tap(find.byIcon(Icons.search_outlined));
    await tester.pumpAndSettle();
    verify(() => mockRouter.go('/search')).called(1);

    await pumpMainScaffold(tester, 1);
    await tester.tap(find.byIcon(Icons.add_box_outlined));
    await tester.pumpAndSettle();
    verify(() => mockRouter.push('/create')).called(1);

    await pumpMainScaffold(tester, 2);
    await tester.tap(find.byIcon(Icons.notifications_none));
    await tester.pumpAndSettle();
    verify(() => mockRouter.go('/notifications')).called(1);

    await pumpMainScaffold(tester, 3);
    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pumpAndSettle();
    verify(() => mockRouter.go('/profile')).called(1);

    await pumpMainScaffold(tester, 4);
    await tester.tap(find.byIcon(Icons.home_outlined));
    await tester.pumpAndSettle();
    verify(() => mockRouter.go('/home')).called(1);
  });

  testWidgets('navigates to settings when pressing more_vert button', (WidgetTester tester) async {
    await pumpMainScaffold(tester, 0);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    verify(() => mockRouter.push('/settings')).called(1);
  });
}
