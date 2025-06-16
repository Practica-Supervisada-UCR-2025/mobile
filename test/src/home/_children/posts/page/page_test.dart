import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mobile/core/globals/publications/publications.dart';
import 'package:mobile/src/home/home.dart';

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
  });

  testWidgets(
    'HomeScreen builds the BlocProvider and displays PublicationsList',
    (WidgetTester tester) async {
      // Simulamos estado de carga inicial
      when(() => mockBloc.state).thenReturn(PublicationLoading());
      whenListen<PublicationState>(
        mockBloc,
        Stream.value(PublicationLoading()),
        initialState: PublicationLoading(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<PublicationBloc>.value(
            value: mockBloc,
            child: const HomeScreen(isFeed: true),
          ),
        ),
      );
      await tester.pump(); // <-- reemplazamos pumpAndSettle()

      // Verificamos que exista el provider y la lista
      expect(find.byType(BlocProvider<PublicationBloc>), findsOneWidget);
      expect(find.byType(PublicationsList), findsOneWidget);
    },
  );

  testWidgets(
    'When PublicationsList fails and Retry is pressed, the error message reappears',
    (WidgetTester tester) async {
      // Simulamos estado de error
      when(() => mockBloc.state).thenReturn(PublicationFailure());
      whenListen<PublicationState>(
        mockBloc,
        Stream.value(PublicationFailure()),
        initialState: PublicationFailure(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<PublicationBloc>.value(
            value: mockBloc,
            child: const PublicationsList(
              scrollKey: 'homePage',
              isFeed: true,
            ),
          ),
        ),
      );
      await tester.pump(); // <-- reemplazamos pumpAndSettle()

      // Debe verse el mensaje de fallo y el botón Retry
      expect(find.text('Failed to load posts'), findsOneWidget);
      final retryBtn = find.widgetWithText(ElevatedButton, 'Retry');
      expect(retryBtn, findsOneWidget);

      // Al pulsarlo, se dispara LoadPublications y el mensaje sigue ahí
      await tester.tap(retryBtn);
      await tester.pump();

      verify(() => mockBloc.add(LoadPublications())).called(1);
      expect(find.text('Failed to load posts'), findsOneWidget);
      expect(retryBtn, findsOneWidget);
    },
  );
}
