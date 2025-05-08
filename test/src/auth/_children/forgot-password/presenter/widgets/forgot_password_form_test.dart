import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/globals/widgets/primary_button.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/src/auth/auth.dart';

class MockForgotPasswordBloc extends Mock implements ForgotPasswordBloc {}

class FakeForgotPasswordEvent extends Fake implements ForgotPasswordEvent {}
class FakeForgotPasswordState extends Fake implements ForgotPasswordState {}

void main() {
  late ForgotPasswordBloc bloc;

  setUpAll(() {
    registerFallbackValue(FakeForgotPasswordEvent());
    registerFallbackValue(FakeForgotPasswordState());
  });

  setUp(() {
    bloc = MockForgotPasswordBloc();
    when(() => bloc.state).thenReturn(ForgotPasswordInitial());
    when(() => bloc.stream).thenAnswer((_) => const Stream<ForgotPasswordState>.empty());
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<ForgotPasswordBloc>.value(
        value: bloc,
        child: const Scaffold(
          body: ForgotPasswordForm(),
        ),
      ),
    );
  }

  Future<void> submitAndHandleDialog(WidgetTester tester) async {
    await tester.tap(find.byType(PrimaryButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  }

  group('ForgotPasswordForm UI Tests', () {
    testWidgets('Validación: campo vacío muestra error', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await submitAndHandleDialog(tester);

      expect(find.text('This field is required'), findsOneWidget);
    });

    testWidgets('Validación: dominio incorrecto muestra error', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.enterText(find.byType(TextFormField), 'test@gmail.com');
      await submitAndHandleDialog(tester);

      expect(find.text('Invalid email. Must be @ucr.ac.cr domain.'), findsOneWidget);
    });

    testWidgets('NO envía evento si email es de dominio incorrecto', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.enterText(find.byType(TextFormField), 'test@gmail.com');
      await submitAndHandleDialog(tester);

      verifyNever(() => bloc.add(any()));
    });

    testWidgets('Envía evento ForgotPasswordSubmitted si email es válido', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.enterText(find.byType(TextFormField), 'test@ucr.ac.cr');
      await tester.tap(find.byType(PrimaryButton));
      await tester.pump();

      verify(() => bloc.add(any(that: isA<ForgotPasswordSubmitted>()))).called(1);
    });
  });

  group('ForgotPasswordForm BlocListener Tests', () {
    testWidgets('Limpia el campo email si validación falla', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final emailField = find.byType(TextFormField);
      await tester.enterText(emailField, 'test@gmail.com');

      expect(
        (tester.widget(emailField) as TextFormField).controller!.text,
        'test@gmail.com',
      );

      await submitAndHandleDialog(tester);

      expect(
        (tester.widget(emailField) as TextFormField).controller!.text,
        '',
      );
    });

    testWidgets('Muestra dialog de éxito si ForgotPasswordSuccess', (tester) async {
      whenListen(
        bloc,
        Stream.fromIterable([
          ForgotPasswordLoading(),
          ForgotPasswordSuccess('Correo enviado exitosamente'),
        ]),
        initialState: ForgotPasswordInitial(),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Mail sent'), findsOneWidget);
      expect(find.text('Correo enviado exitosamente'), findsOneWidget);

      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });

    testWidgets('Muestra dialog de error si ForgotPasswordFailure', (tester) async {
      whenListen(
        bloc,
        Stream.fromIterable([
          ForgotPasswordLoading(),
          ForgotPasswordFailure('Hubo un error'),
        ]),
        initialState: ForgotPasswordInitial(),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Hubo un error'), findsOneWidget);

      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });
  });
}
