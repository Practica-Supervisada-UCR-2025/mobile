import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/core.dart';

class MockDeletePublicationBloc extends Mock implements DeletePublicationBloc {}

class FakeDeletePublicationEvent extends Fake
    implements DeletePublicationEvent {}

class FakeDeletePublicationState extends Fake
    implements DeletePublicationState {}

class MockPublicationBloc extends Mock implements PublicationBloc {}

class FakeRoute extends Fake implements Route<dynamic> {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late MockDeletePublicationBloc deleteBloc;
  late MockPublicationBloc publicationBloc;

  setUpAll(() {
    registerFallbackValue(FakeDeletePublicationEvent());
    registerFallbackValue(FakeDeletePublicationState());
    registerFallbackValue(FakeRoute());
  });

  setUp(() {
    deleteBloc = MockDeletePublicationBloc();
    publicationBloc = MockPublicationBloc();

    when(() => publicationBloc.state).thenReturn(PublicationInitial());
    when(
      () => publicationBloc.stream,
    ).thenAnswer((_) => const Stream<PublicationState>.empty());
  });

  Widget buildTestableWidget(DeletePublicationState deleteState) {
    when(() => deleteBloc.state).thenReturn(deleteState);
    whenListen(
      deleteBloc,
      Stream<DeletePublicationState>.empty(),
      initialState: deleteState,
    );
    when(() => publicationBloc.state).thenReturn(PublicationInitial());

    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<DeletePublicationBloc>.value(value: deleteBloc),
          BlocProvider<PublicationBloc>.value(value: publicationBloc),
        ],
        child: DeleteBottomSheet(publicationId: 'test123'),
      ),
    );
  }

  testWidgets(
    'muestra botón y texto de confirmación cuando DeletePublicationInitial',
    (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(DeletePublicationInitial()));
      expect(find.text('Delete this post?'), findsOneWidget);
      expect(find.textContaining('This action is permanent'), findsOneWidget);
      expect(find.text('Delete Post'), findsOneWidget);
    },
  );

  testWidgets('muestra spinner cuando DeletePublicationLoading está activo', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestableWidget(DeletePublicationLoading()));
    expect(find.byType(PrimaryButton), findsOneWidget);
    expect(
      tester.widget<PrimaryButton>(find.byType(PrimaryButton)).isLoading,
      true,
    );
  });

  testWidgets('muestra mensaje de éxito y dispara HidePublication', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestableWidget(DeletePublicationSuccess()));
    await tester.pump();
    await tester.pump();

    verify(() => publicationBloc.add(HidePublication('test123'))).called(1);

    expect(find.text('Post deleted'), findsOneWidget);
    expect(find.text('The post was deleted successfully.'), findsOneWidget);
  });

  testWidgets('muestra mensaje de error en DeletePublicationFailure', (
    WidgetTester tester,
  ) async {
    const errorMessage = 'Could not delete';
    await tester.pumpWidget(
      buildTestableWidget(DeletePublicationFailure(error: errorMessage)),
    );

    expect(find.text('Failed to delete'), findsOneWidget);
    expect(find.text(errorMessage), findsOneWidget);
  });

  testWidgets('presionar "Delete Post" emite DeletePublicationRequest', (
    WidgetTester tester,
  ) async {
    when(() => deleteBloc.state).thenReturn(DeletePublicationInitial());
    whenListen(
      deleteBloc,
      Stream<DeletePublicationState>.empty(),
      initialState: DeletePublicationInitial(),
    );

    await tester.pumpWidget(buildTestableWidget(DeletePublicationInitial()));

    await tester.tap(find.text('Delete Post'));
    await tester.pump();

    verify(
      () => deleteBloc.add(DeletePublicationRequest(publicationId: 'test123')),
    ).called(1);
  });
  testWidgets('didChangeDependencies obtiene correctamente PublicationBloc', (
    tester,
  ) async {
    when(
      () => deleteBloc.stream,
    ).thenAnswer((_) => const Stream<DeletePublicationState>.empty());
    when(() => deleteBloc.state).thenReturn(DeletePublicationInitial());

    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<DeletePublicationBloc>.value(value: deleteBloc),
            BlocProvider<PublicationBloc>.value(value: publicationBloc),
          ],
          child: DeleteBottomSheet(publicationId: 'test123'),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'DeletePublicationSuccess dispara HidePublication y muestra mensaje',
    (tester) async {
      await tester.pumpWidget(buildTestableWidget(DeletePublicationSuccess()));
      await tester.pump();
      await tester.pump();

      verify(() => publicationBloc.add(HidePublication('test123'))).called(1);

      expect(find.text('Post deleted'), findsOneWidget);
      expect(find.text('The post was deleted successfully.'), findsOneWidget);
    },
  );
  testWidgets('mensaje éxito cierra dialogo al pulsar onClose', (tester) async {
    final mockObserver = MockNavigatorObserver();

    when(() => deleteBloc.state).thenReturn(DeletePublicationSuccess());
    whenListen(
      deleteBloc,
      Stream.value(DeletePublicationSuccess()),
      initialState: DeletePublicationSuccess(),
    );

    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [mockObserver],
        home: MultiBlocProvider(
          providers: [
            BlocProvider<DeletePublicationBloc>.value(value: deleteBloc),
            BlocProvider<PublicationBloc>.value(value: publicationBloc),
          ],
          child: DeleteBottomSheet(publicationId: 'test123'),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(FeedbackContent), findsOneWidget);
    final closeButton = find.text('Close');
    expect(closeButton, findsOneWidget);
    await tester.tap(closeButton);
    await tester.pumpAndSettle();
    verify(() => mockObserver.didPop(any(), any())).called(1);
  });
}
