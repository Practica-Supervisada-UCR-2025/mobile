import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/core/core.dart';

class MockReportPublicationBloc extends Mock implements ReportPublicationBloc {}

class FakeReportPublicationEvent extends Fake
    implements ReportPublicationEvent {}

class FakeReportPublicationState extends Fake
    implements ReportPublicationState {}

class MockPublicationBloc extends Mock implements PublicationBloc {}

class FakePublicationEvent extends Fake implements PublicationEvent {}

class FakePublicationState extends Fake implements PublicationState {}

void main() {
  late MockReportPublicationBloc reportBloc;
  late MockPublicationBloc publicationBloc;

  setUpAll(() {
    registerFallbackValue(FakeReportPublicationEvent());
    registerFallbackValue(FakeReportPublicationState());
    registerFallbackValue(FakePublicationEvent());
    registerFallbackValue(FakePublicationState());
  });

  setUp(() {
    reportBloc = MockReportPublicationBloc();
    publicationBloc = MockPublicationBloc();
  });

  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<ReportPublicationBloc>.value(value: reportBloc),
          BlocProvider<PublicationBloc>.value(value: publicationBloc),
        ],
        child: Scaffold(body: child),
      ),
    );
  }

  testWidgets('renderiza opciones y selección por defecto', (tester) async {
    when(() => reportBloc.state).thenReturn(ReportPublicationInitial());
    when(() => reportBloc.stream).thenAnswer((_) => const Stream.empty());

    when(() => publicationBloc.state).thenReturn(PublicationInitial());
    when(() => publicationBloc.stream).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(
      buildTestableWidget(ReportBottomSheet(publicationId: '123')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Report content'), findsOneWidget);
    expect(find.text('Why are you reporting this post?'), findsOneWidget);
    expect(find.text('Inappropriate content'), findsOneWidget);
    expect(find.text('Other reason'), findsOneWidget);
  });

  testWidgets('muestra campo de texto si se selecciona "Other reason"', (
    tester,
  ) async {
    when(() => reportBloc.state).thenReturn(ReportPublicationInitial());
    when(() => reportBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => publicationBloc.state).thenReturn(PublicationInitial());
    when(() => publicationBloc.stream).thenAnswer((_) => const Stream.empty());
    await tester.pumpWidget(
      buildTestableWidget(ReportBottomSheet(publicationId: '123')),
    );
    await tester.tap(find.text('Other reason'));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('botón habilitado cuando el formulario es válido', (
    tester,
  ) async {
    when(() => reportBloc.state).thenReturn(ReportPublicationInitial());
    when(() => reportBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => publicationBloc.state).thenReturn(PublicationInitial());
    when(() => publicationBloc.stream).thenAnswer((_) => const Stream.empty());
    await tester.pumpWidget(
      buildTestableWidget(ReportBottomSheet(publicationId: '123')),
    );
    final sendButton = find.widgetWithText(PrimaryButton, 'Send report');
    final PrimaryButton buttonWidget = tester.widget(sendButton);
    expect(buttonWidget.isEnabled, isTrue);
  });

  testWidgets('envía ReportPublicationRequest al presionar botón', (
    tester,
  ) async {
    when(() => reportBloc.state).thenReturn(ReportPublicationInitial());
    when(() => reportBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => publicationBloc.state).thenReturn(PublicationInitial());
    when(() => publicationBloc.stream).thenAnswer((_) => const Stream.empty());
    await tester.pumpWidget(
      buildTestableWidget(ReportBottomSheet(publicationId: '123')),
    );
    await tester.tap(find.widgetWithText(PrimaryButton, 'Send report'));
    await tester.pump();

    verify(
      () => reportBloc.add(any(that: isA<ReportPublicationRequest>())),
    ).called(1);
  });
  testWidgets(
    'muestra FeedbackContent verde si el reporte fue exitoso y oculta publicación',
    (tester) async {
      when(() => reportBloc.state).thenReturn(ReportPublicationInitial());
      when(
        () => reportBloc.stream,
      ).thenAnswer((_) => Stream.value(ReportPublicationSuccess()));
      when(() => publicationBloc.state).thenReturn(PublicationInitial());
      when(
        () => publicationBloc.stream,
      ).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(
        buildTestableWidget(ReportBottomSheet(publicationId: '123')),
      );

      await tester.pump();

      expect(find.text('Report sent'), findsOneWidget);
      verify(() => publicationBloc.add(HidePublication('123'))).called(1);
    },
  );

  testWidgets('muestra FeedbackContent rojo si ocurre un error', (
    tester,
  ) async {
    when(
      () => reportBloc.state,
    ).thenReturn(ReportPublicationFailure(error: 'Error inesperado'));
    when(() => reportBloc.stream).thenAnswer(
      (_) => Stream.value(ReportPublicationFailure(error: 'Error inesperado')),
    );
    when(() => publicationBloc.state).thenReturn(PublicationInitial());
    when(() => publicationBloc.stream).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(
      buildTestableWidget(ReportBottomSheet(publicationId: '123')),
    );

    await tester.pump();

    expect(find.text('An error occurred.'), findsOneWidget);
    expect(find.text('Error inesperado'), findsOneWidget);
  });
  testWidgets('botón deshabilitado si "Other reason" está vacío', (
    tester,
  ) async {
    when(() => reportBloc.state).thenReturn(ReportPublicationInitial());
    when(() => reportBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => publicationBloc.state).thenReturn(PublicationInitial());
    when(() => publicationBloc.stream).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(
      buildTestableWidget(ReportBottomSheet(publicationId: '123')),
    );

    await tester.tap(find.text('Other reason'));
    await tester.pumpAndSettle();

    final sendButton = find.widgetWithText(PrimaryButton, 'Send report');
    final PrimaryButton buttonWidget = tester.widget(sendButton);

    expect(buttonWidget.isEnabled, isFalse);
  });
}
