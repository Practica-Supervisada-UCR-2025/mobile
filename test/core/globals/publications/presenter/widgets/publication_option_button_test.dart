import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/core/core.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockPublicationBloc extends Mock implements PublicationBloc {}

class MockDeletePublicationBloc extends Mock implements DeletePublicationBloc {}

class MockReportPublicationBloc extends Mock implements ReportPublicationBloc {}

class FakePublicationState extends Fake implements PublicationState {}

class FakeDeletePublicationState extends Fake
    implements DeletePublicationState {}

class FakeReportPublicationState extends Fake
    implements ReportPublicationState {}

void main() {
  late MockPublicationBloc publicationBloc;
  late MockDeletePublicationBloc deleteBloc;
  late MockReportPublicationBloc reportBloc;

  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
    registerFallbackValue(FakePublicationState());
    registerFallbackValue(FakeDeletePublicationState());
    registerFallbackValue(FakeReportPublicationState());
  });

  setUp(() async {
    await LocalStorage.init();
    LocalStorage().username = 'ownerUser';
    publicationBloc = MockPublicationBloc();
    deleteBloc = MockDeletePublicationBloc();
    reportBloc = MockReportPublicationBloc();

    when(() => publicationBloc.state).thenReturn(PublicationInitial());
    when(() => deleteBloc.state).thenReturn(DeletePublicationInitial());
    when(() => reportBloc.state).thenReturn(ReportPublicationInitial());
  });

  testWidgets('muestra ícono de opciones', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<PublicationBloc>.value(value: publicationBloc),
            BlocProvider<DeletePublicationBloc>.value(value: deleteBloc),
            BlocProvider<ReportPublicationBloc>.value(value: reportBloc),
          ],
          child: const Scaffold(
            body: PublicationOptionsButton(
              publicationId: 'test123',
              publicationUsername: 'ownerUser',
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.more_vert), findsOneWidget);
  });

  testWidgets('muestra opción Delete si es el dueño', (tester) async {
    LocalStorage().username = 'ownerUser';

    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<PublicationBloc>.value(value: publicationBloc),
            BlocProvider<DeletePublicationBloc>.value(value: deleteBloc),
            BlocProvider<ReportPublicationBloc>.value(value: reportBloc),
          ],
          child: const Scaffold(
            body: PublicationOptionsButton(
              publicationId: 'test123',
              publicationUsername: 'ownerUser',
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    expect(find.text('Delete'), findsOneWidget);
    expect(find.text('Report'), findsNothing);
  });

  testWidgets('muestra opción Report si NO es el dueño', (tester) async {
    LocalStorage().username = 'anotherUser';

    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<PublicationBloc>.value(value: publicationBloc),
            BlocProvider<DeletePublicationBloc>.value(value: deleteBloc),
            BlocProvider<ReportPublicationBloc>.value(value: reportBloc),
          ],
          child: const Scaffold(
            body: PublicationOptionsButton(
              publicationId: 'test123',
              publicationUsername: 'ownerUser',
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    expect(find.text('Report'), findsOneWidget);
    expect(find.text('Delete'), findsNothing);
  });

  testWidgets('al pulsar "Report" muestra ReportBottomSheet', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorage.init();
    LocalStorage().username = 'anotherUser';
    when(() => publicationBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => publicationBloc.state).thenReturn(PublicationInitial());

    when(() => deleteBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => deleteBloc.state).thenReturn(DeletePublicationInitial());

    when(() => reportBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => reportBloc.state).thenReturn(ReportPublicationInitial());

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<PublicationBloc>.value(value: publicationBloc),
          BlocProvider<DeletePublicationBloc>.value(value: deleteBloc),
          BlocProvider<ReportPublicationBloc>.value(value: reportBloc),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: PublicationOptionsButton(
              publicationId: 'test123',
              publicationUsername: 'ownerUser',
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Report'));
    await tester.pumpAndSettle();

    expect(find.byType(ReportBottomSheet), findsOneWidget);
  });

  testWidgets('al pulsar "Delete" muestra DeleteBottomSheet', (tester) async {
    LocalStorage().username = 'ownerUser';

    when(() => publicationBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => publicationBloc.state).thenReturn(PublicationInitial());

    when(() => deleteBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => deleteBloc.state).thenReturn(DeletePublicationInitial());

    when(() => reportBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => reportBloc.state).thenReturn(ReportPublicationInitial());

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<PublicationBloc>.value(value: publicationBloc),
          BlocProvider<DeletePublicationBloc>.value(value: deleteBloc),
          BlocProvider<ReportPublicationBloc>.value(value: reportBloc),
        ],
        child: MaterialApp(
          home: const Scaffold(
            body: PublicationOptionsButton(
              publicationId: 'test123',
              publicationUsername: 'ownerUser',
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.byType(DeleteBottomSheet), findsOneWidget);
  });
  testWidgets('dispara ReportPublicationReset al pulsar "Report"', (
    tester,
  ) async {
    LocalStorage().username = 'anotherUser';

    when(() => publicationBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => publicationBloc.state).thenReturn(PublicationInitial());

    when(() => deleteBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => deleteBloc.state).thenReturn(DeletePublicationInitial());

    when(() => reportBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => reportBloc.state).thenReturn(ReportPublicationInitial());

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<PublicationBloc>.value(value: publicationBloc),
          BlocProvider<DeletePublicationBloc>.value(value: deleteBloc),
          BlocProvider<ReportPublicationBloc>.value(value: reportBloc),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: PublicationOptionsButton(
              publicationId: 'test123',
              publicationUsername: 'ownerUser',
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Report'));
    await tester.pumpAndSettle();

    verify(() => reportBloc.add(ReportPublicationReset())).called(1);
  });
  testWidgets('dispara DeletePublicationReset al pulsar "Delete"', (
    tester,
  ) async {
    LocalStorage().username = 'ownerUser';

    when(() => publicationBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => publicationBloc.state).thenReturn(PublicationInitial());

    when(() => deleteBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => deleteBloc.state).thenReturn(DeletePublicationInitial());

    when(() => reportBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => reportBloc.state).thenReturn(ReportPublicationInitial());

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<PublicationBloc>.value(value: publicationBloc),
          BlocProvider<DeletePublicationBloc>.value(value: deleteBloc),
          BlocProvider<ReportPublicationBloc>.value(value: reportBloc),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: PublicationOptionsButton(
              publicationId: 'test123',
              publicationUsername: 'ownerUser',
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    verify(() => deleteBloc.add(DeletePublicationReset())).called(1);
  });
}
