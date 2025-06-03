// test/src/home/presenter/page/page_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:mobile/src/home/_children/news/news.dart';
import 'package:mobile/src/home/_children/posts/posts.dart';
import 'package:mobile/src/home/presenter/page/page.dart';
import 'package:mobile/core/core.dart'; // para PublicationRepositoryAPI y ENDPOINT_OWN_PUBLICATIONS

void main() {
  testWidgets('HomeScreen shows tabs "Posts" and "News" and switches between them',
      (WidgetTester tester) async {
    // Montamos HomeScreen directamente (no se necesita router aquí)
    await tester.pumpWidget(
      MaterialApp(
        home: const HomeScreen(),
      ),
    );

    // Debería arrancar en el tab de Posts:
    // 1) Encontrar el PublicationsList dentro de PostsPage
    expect(find.byType(PostsPage), findsOneWidget);
    expect(find.byType(PublicationsList), findsOneWidget);

    // 2) Al inicio no debe mostrarse nada de NewsPage
    expect(find.byType(NewsPage), findsNothing);
    expect(find.text('No news available'), findsNothing);

    // Ahora cambia al tab de News:
    await tester.tap(find.text('News'));
    await tester.pumpAndSettle();

    // 3) Debería aparecer NewsPage con su texto
    expect(find.byType(NewsPage), findsOneWidget);
    expect(find.text('No news available'), findsOneWidget);

    // 4) Volvemos a Posts
    await tester.tap(find.text('Posts'));
    await tester.pumpAndSettle();

    // Y el PublicationsList debe estar de nuevo visible
    expect(find.byType(PostsPage), findsOneWidget);
    expect(find.byType(PublicationsList), findsOneWidget);
  });
}
