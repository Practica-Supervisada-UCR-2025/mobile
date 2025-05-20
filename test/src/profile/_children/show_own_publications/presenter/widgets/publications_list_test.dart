// test/publications_list_test.dart

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mobile/src/profile/profile.dart'
    show
        PublicationBloc,
        PublicationEvent,
        PublicationState,
        LoadPublications,
        LoadMorePublications,
        PublicationInitial,
        PublicationLoading,
        PublicationFailure,
        PublicationSuccess,
        Publication,
        PublicationsList,
        PublicationCard;

class MockPublicationBloc extends Mock implements PublicationBloc {}

class FakePublicationEvent extends Fake implements PublicationEvent {}

class FakePublicationState extends Fake implements PublicationState {}

void main() {
  late MockPublicationBloc mockBloc;

  setUpAll(() {
    registerFallbackValue(FakePublicationEvent());
    registerFallbackValue(FakePublicationState());
  });

  setUp(() {
    mockBloc = MockPublicationBloc();
  });

  Widget buildTestableWidget(PublicationState state) {
    // Stub the bloc's state and stream
    when(() => mockBloc.state).thenReturn(state);
    whenListen(
      mockBloc,
      Stream<PublicationState>.fromIterable([state]),
      initialState: state,
    );

    return MaterialApp(
      home: BlocProvider<PublicationBloc>.value(
        value: mockBloc,
        child: const PublicationsList(),
      ),
    );
  }

  testWidgets('muestra spinner de carga cuando el estado es PublicationLoading',
      (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      final state = PublicationLoading();
      await tester.pumpWidget(buildTestableWidget(state));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  testWidgets(
      'muestra mensaje de error y botón Retry cuando el estado es PublicationFailure',
      (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      final state = PublicationFailure();
      await tester.pumpWidget(buildTestableWidget(state));
      await tester.pump();

      expect(find.text('Failed to load posts'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Retry'), findsOneWidget);

      // Al pulsar Retry debe dispararse LoadPublications
      await tester.tap(find.widgetWithText(ElevatedButton, 'Retry'));
      await tester.pump();
      verify(() => mockBloc.add(LoadPublications())).called(1);
    });
  });

  testWidgets(
      'muestra mensaje vacío cuando PublicationSuccess contiene lista vacía',
      (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      final state = PublicationSuccess(
        publications: const [],
        totalPosts: 0,
        totalPages: 1,
        currentPage: 1,
      );
      await tester.pumpWidget(buildTestableWidget(state));
      await tester.pump();

      expect(find.text("You haven’t posted anything yet."), findsOneWidget);
    });
  });

  testWidgets(
      'renderiza items y spinner de carga al final cuando hasReachedMax es false',
      (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      // Un solo post de ejemplo
      final pub = Publication(
        id: 1,
        username: 'user1',
        profileImageUrl: 'https://example.com/avatar.png',
        content: 'Hello World',
        createdAt: DateTime.now(),
        attachment: null,
        likes: 0,
        comments: 0,
      );
      final state = PublicationSuccess(
        publications: [pub],
        totalPosts: 2,
        totalPages: 2,
        currentPage: 1,
      );
      await tester.pumpWidget(buildTestableWidget(state));
      await tester.pump();

      // Debe encontrar la tarjeta
      expect(find.byType(PublicationCard), findsOneWidget);

      // Debe encontrar el spinner al final de la lista
      expect(
        find.byWidgetPredicate((w) =>
            w is Padding &&
            w.child is Center &&
            (w.child as Center).child is CircularProgressIndicator),
        findsOneWidget,
      );

      // Forzamos el scroll al final para disparar LoadMorePublications
      final listView = tester.widget<ListView>(find.byType(ListView));
      final controller = listView.controller!;
      // Esperamos un frame para que esté todo montado
      await tester.pump();
      controller.jumpTo(controller.position.maxScrollExtent + 300);
      await tester.pump(const Duration(milliseconds: 200));

      verify(() => mockBloc.add(LoadMorePublications())).called(1);
    });
  });

  testWidgets(
      'muestra "No more posts to show." cuando hasReachedMax es true',
      (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      final pub = Publication(
        id: 2,
        username: 'user2',
        profileImageUrl: 'https://example.com/avatar2.png',
        content: 'Second post',
        createdAt: DateTime.now(),
        attachment: null,
        likes: 0,
        comments: 0,
      );
      final state = PublicationSuccess(
        publications: [pub],
        totalPosts: 1,
        totalPages: 1,
        currentPage: 1,
      );
      await tester.pumpWidget(buildTestableWidget(state));
      await tester.pump();

      expect(find.text('No more posts to show.'), findsOneWidget);
    });
  });

  testWidgets('renderiza SizedBox.shrink() para estados no manejados',
      (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      final state = PublicationInitial();
      await tester.pumpWidget(buildTestableWidget(state));
      await tester.pump();
      expect(find.byType(SizedBox), findsOneWidget);
    });
  });
}
