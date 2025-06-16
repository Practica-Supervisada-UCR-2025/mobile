import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mobile/core/globals/publications/publications.dart';
import 'package:mobile/src/home/presenter/page/page.dart';
import 'package:mobile/src/home/_children/posts/posts.dart';
import 'package:mobile/src/home/_children/news/news.dart';

class MockPublicationBloc extends Mock implements PublicationBloc {}
class FakePublicationEvent extends Fake implements PublicationEvent {}
class FakePublicationState extends Fake implements PublicationState {}

void main() {
  late PublicationBloc mockBloc;

  setUpAll(() {
    registerFallbackValue(FakePublicationEvent());
    registerFallbackValue(FakePublicationState());
  });

  setUp(() {
    mockBloc = MockPublicationBloc();
    // Estado inicial
    when(() => mockBloc.state).thenReturn(PublicationInitial());
    whenListen<PublicationState>(
      mockBloc,
      Stream.value(PublicationInitial()),
      initialState: PublicationInitial(),
    );
  });

  testWidgets(
    'HomeScreen shows tabs "Posts" and "News" and switches between them',
    (WidgetTester tester) async {
      // Arranque de la pantalla con el BlocProvider
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<PublicationBloc>.value(
            value: mockBloc,
            child: const HomeScreen(isFeed: true),
          ),
        ),
      );
      await tester.pump(); // Build inicial

      // Comprueba que las dos pestañas están
      expect(find.text('Posts'), findsOneWidget);
      expect(find.text('News'), findsOneWidget);

      // Por defecto debe verse PostsPage (y dentro de ella PublicationsList)
      expect(find.byType(PostsPage), findsOneWidget);
      expect(find.byType(PublicationsList), findsOneWidget);
      expect(find.byType(NewsPage), findsNothing);

      // Cambia a la pestaña "News"
      await tester.tap(find.text('News'));
      await tester.pump(); // inicia la animación
      await tester.pump(const Duration(milliseconds: 300)); // la completa

      // Ahora debe verse NewsPage
      expect(find.byType(NewsPage), findsOneWidget);
      // Asumiendo que NewsPage muestra algo como "No news available" en vacío
      expect(find.text('No news available'), findsOneWidget);
      expect(find.byType(PostsPage), findsNothing);

      // Vuelve a "Posts"
      await tester.tap(find.text('Posts'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(PostsPage), findsOneWidget);
      expect(find.byType(PublicationsList), findsOneWidget);
    },
  );
}
