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

  Future<void> _submitAndHandleDialog(WidgetTester tester) async {
  await tester.tap(find.byType(PrimaryButton));
  await tester.pump();
}

  group('ForgotPasswordForm UI Tests', () {
    testWidgets('Validation: empty field shows error', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await submitAndHandleDialog(tester);

      expect(find.text('This field is required'), findsOneWidget);
    });

    testWidgets('Validation: incorrect domain shows error', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.enterText(find.byType(TextFormField), 'test@gmail.com');
      await submitAndHandleDialog(tester);

      expect(find.text('Invalid email. Must be @ucr.ac.cr domain.'), findsOneWidget);
    });

    testWidgets('DO NOT send event if email is from wrong domain', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.enterText(find.byType(TextFormField), 'test@gmail.com');
      await submitAndHandleDialog(tester);

      verifyNever(() => bloc.add(any()));
    });

    testWidgets('Sends ForgotPasswordSubmitted event if email is valid', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.enterText(find.byType(TextFormField), 'test@ucr.ac.cr');
      await tester.tap(find.byType(PrimaryButton));
      await tester.pump();

      verify(() => bloc.add(any(that: isA<ForgotPasswordSubmitted>()))).called(1);
    });
  });

  group('ForgotPasswordForm BlocListener Tests', () {
    testWidgets('Clear the email field if validation fails', (tester) async {
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

    testWidgets('Displays success dialog if ForgotPasswordSuccess', (tester) async {
      whenListen(
        bloc,
        Stream.fromIterable([
          ForgotPasswordLoading(),
          ForgotPasswordSuccess('Mail sent successfully'),
        ]),
        initialState: ForgotPasswordInitial(),
    );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text('Mail sent'), findsOneWidget);
      expect(find.text('Mail sent successfully'), findsOneWidget);
    });

    testWidgets('Displays error dialog if ForgotPasswordFailure', (tester) async {
      whenListen(
        bloc,
        Stream.fromIterable([
          ForgotPasswordLoading(),
          ForgotPasswordFailure('There was an error'),
        ]),
        initialState: ForgotPasswordInitial(),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text('Error'), findsOneWidget);
      expect(find.text('There was an error'), findsOneWidget);
    });
  });

      testWidgets('Dialog closes correctly on success = false', (tester) async {
      whenListen(
        bloc,
        Stream.fromIterable([
          ForgotPasswordLoading(),
          ForgotPasswordFailure('An error occurred'),
        ]),
        initialState: ForgotPasswordInitial(),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(); // Rebuild after state change

      // Find and tap the Accept button on the dialog
      final acceptButton = find.widgetWithText(TextButton, 'Accept');
      expect(acceptButton, findsOneWidget);
      await tester.tap(acceptButton);
      await tester.pump();

      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('Dialog closes correctly on success = true', (tester) async {
      whenListen(
        bloc,
        Stream.fromIterable([
          ForgotPasswordLoading(),
          ForgotPasswordSuccess('Email sent successfully'),
        ]),
        initialState: ForgotPasswordInitial(),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(); // Rebuild after state change

      // Find and tap the Accept button on the dialog
      final acceptButton = find.widgetWithText(TextButton, 'Accept');
      expect(acceptButton, findsOneWidget);
      await tester.tap(acceptButton);
      await tester.pumpAndSettle(); // Ensure both Navigator.pop() complete

      expect(find.byType(AlertDialog), findsNothing);
    });

}
