import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mobile/src/auth/auth.dart';

class MockRegisterBloc extends MockBloc<RegisterEvent, RegisterState>
    implements RegisterBloc {}

class MockLoginBloc extends MockBloc<LoginEvent, LoginState>
    implements LoginBloc {}

class MockLogoutBloc extends MockBloc<LogoutEvent, LogoutState>
    implements LogoutBloc {}

void main() {
  late MockRegisterBloc mockRegisterBloc;
  late MockLoginBloc mockLoginBloc;
  late MockLogoutBloc mockLogoutBloc;

  final testUser = AuthUserInfo(
    name: 'Test User',
    id: 'test-user-id',
    email: 'test@email.com',
    authProviderToken: 'token123',
  );

  setUp(() {
    mockRegisterBloc = MockRegisterBloc();
    mockLoginBloc = MockLoginBloc();
    mockLogoutBloc = MockLogoutBloc();
  });

  // after each test, reset the mock
  tearDown(() {
    mockRegisterBloc.close();
    mockLoginBloc.close();
    mockLogoutBloc.close();
  });

  group('RegisterPage', () {
    testWidgets('renders RegisterForm when RegisterBloc is in initial state', (
      WidgetTester tester,
    ) async {
      whenListen(
        mockRegisterBloc,
        Stream.fromIterable([RegisterInitial()]),
        initialState: RegisterInitial(),
      );

      whenListen(
        mockLoginBloc,
        Stream<LoginState>.empty(),
        initialState: LoginInitial(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<RegisterBloc>.value(value: mockRegisterBloc),
              BlocProvider<LoginBloc>.value(value: mockLoginBloc),
            ],
            child: const RegisterPage(),
          ),
        ),
      );

      expect(find.byType(RegisterForm), findsOneWidget);
    });

    testWidgets(
      'shows loading indicator when RegisterBloc is in loading state',
      (WidgetTester tester) async {
        whenListen(
          mockRegisterBloc,
          Stream.fromIterable([RegisterLoading()]),
          initialState: RegisterLoading(),
        );

        whenListen(
          mockLoginBloc,
          Stream<LoginState>.empty(),
          initialState: LoginInitial(),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: MultiBlocProvider(
              providers: [
                BlocProvider<RegisterBloc>.value(value: mockRegisterBloc),
                BlocProvider<LoginBloc>.value(value: mockLoginBloc),
              ],
              child: const RegisterPage(),
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets('shows error message on RegisterFailure', (
      WidgetTester tester,
    ) async {
      const errorMessage =
          'This email is already registered. Please log in or reset your password.';

      whenListen(
        mockRegisterBloc,
        Stream.fromIterable([RegisterFailure(error: errorMessage)]),
        initialState: RegisterFailure(error: errorMessage),
      );

      whenListen(
        mockLoginBloc,
        Stream<LoginState>.empty(),
        initialState: LoginInitial(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<RegisterBloc>.value(value: mockRegisterBloc),
              BlocProvider<LoginBloc>.value(value: mockLoginBloc),
            ],
            child: const RegisterPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text(errorMessage), findsOneWidget);
    });
  });

  testWidgets('shows error SnackBar on LoginFailure from RegisterPage', (
    tester,
  ) async {
    const loginError = 'Invalid credentials from backend';

    whenListen(
      mockRegisterBloc,
      Stream.fromIterable([RegisterSuccess(user: testUser, password: 'pass')]),
      initialState: RegisterInitial(),
    );

    whenListen(
      mockLoginBloc,
      Stream.fromIterable([LoginFailure(error: loginError)]),
      initialState: LoginLoading(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<RegisterBloc>.value(value: mockRegisterBloc),
            BlocProvider<LoginBloc>.value(value: mockLoginBloc),
          ],
          child: const RegisterPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text(loginError), findsOneWidget);
  });
}
