import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/router/app_routes.dart';
import 'package:mobile/core/router/paths.dart';

void main() {
  
  test('appRoutes contains all expected paths', () {
    final paths = appRoutes.expand((r) {
      if (r is ShellRoute) {
        return r.routes.map((route) => (route as GoRoute).path);
      }
      return [(r as GoRoute).path];
    }).toList();

    expect(paths, containsAll([
      Paths.login,
      Paths.register,
      Paths.settings,
      Paths.home,
      Paths.search,
      Paths.create,
      Paths.notifications,
      Paths.profile,
    ]));
  });
  
  testWidgets('Cover all GoRouter builders', (WidgetTester tester) async {
    final router = GoRouter(
      routes: appRoutes,
      initialLocation: Paths.home,
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
      ),
    );
    final paths = [
      Paths.search,
      Paths.notifications,
    ];

    for (final path in paths) {
      router.go(path);
      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsNWidgets(2));
    }
  });
}
