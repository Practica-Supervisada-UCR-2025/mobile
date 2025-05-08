import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mobile/core/storage/user_session.storage.dart';
import 'package:mobile/src/auth/auth.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/login_bloc_test.mocks.dart';

class MockLoginBloc extends MockBloc<LoginEvent, LoginState>
    implements LoginBloc {
  @override
  void add(LoginEvent event) {
    super.noSuchMethod(Invocation.method(#add, [event]));
  }
}

class MockLogoutBloc extends MockBloc<LogoutEvent, LogoutState>
    implements LogoutBloc {
  @override
  void add(LogoutEvent event) {
    super.noSuchMethod(Invocation.method(#add, [event]));
  }
}

void main() {
  SharedPreferences.setMockInitialValues({});
  late MockLoginBloc mockLoginBloc;
  late MockLogoutBloc mockLogoutBloc;
  late MockLocalStorage mockLocalStorage;
  final testUser = AuthUserInfo(
    id: 'test-user-id',
    email: 'user@test.com',
    authProviderToken: 'token123',
  );

  setUp(() async {
    mockLocalStorage = MockLocalStorage();
    mockLoginBloc = MockLoginBloc();
    mockLogoutBloc = MockLogoutBloc();
  });

  // after each test, reset the mock
  tearDown(() {
    mockLoginBloc.close();
    mockLogoutBloc.close();
  });

  group('LoginPage', () {
    testWidgets('renders LoginForm when LoginBloc is in initial state', (
      WidgetTester tester,
    ) async {
      whenListen(
        mockLoginBloc,
        Stream.fromIterable([LoginInitial()]),
        initialState: LoginInitial(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<LoginBloc>.value(
            value: mockLoginBloc,
            child: const LoginPage(),
          ),
        ),
      );

      expect(find.byType(LoginForm), findsOneWidget);
    });

    testWidgets('shows loading indicator when LoginBloc is in loading state',
        (WidgetTester tester) async {
      whenListen(
        mockLoginBloc,
        Stream.fromIterable([LoginLoading()]),
        initialState: LoginLoading(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<LoginBloc>.value(
            value: mockLoginBloc,
            child: const LoginPage(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
    
    testWidgets('doesnt show login Form when LoginBloc is success',
    (WidgetTester tester) async {
      whenListen(
        mockLoginBloc,
        Stream.fromIterable([LoginSuccess(user: testUser)]),
        initialState: LoginSuccess(user: testUser),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<LoginBloc>.value(
            value: mockLoginBloc,
            child: const LoginPage(),
          ),
        ),
      );

      expect(find.byType(LoginForm), findsNothing);
    }
    );

    testWidgets('navigates to HomePage on LoginSuccess', (
      WidgetTester tester,
    ) async {
      whenListen(
        mockLoginBloc,
        Stream.fromIterable([LoginSuccess(user: testUser)]),
        initialState: LoginSuccess(user: testUser),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<LoginBloc>.value(
            value: mockLoginBloc,
            child: const LoginPage(),
          ),
        ),
      );

      // TODO: Implement a proper HomePage widget and check for its presence
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows error message on LoginFailure', (
      WidgetTester tester,
    ) async {
      whenListen(
        mockLoginBloc,
        Stream.fromIterable([LoginFailure(error: 'Invalid credentials')]),
        initialState: LoginFailure(error: 'Invalid credentials'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<LoginBloc>.value(
            value: mockLoginBloc,
            child: const LoginPage(),
          ),
        ),
      );

      expect(find.byType(ScaffoldMessenger), findsOneWidget);
    });


    testWidgets('shows error on LogoutFailure', (WidgetTester tester) async {
      LocalStorage.init();
      when(mockLocalStorage.userId).thenReturn(testUser.id);
      when(mockLocalStorage.userEmail).thenReturn(testUser.email);

      whenListen(
        mockLogoutBloc,
        Stream.fromIterable([LogoutFailure('Logout failed')]),
        initialState: LogoutFailure('Logout failed'),
      );
      whenListen(
        mockLoginBloc,
        Stream.fromIterable([LoginInitial()]),
        initialState: LoginInitial(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<LoginBloc>.value(value: mockLoginBloc),
              BlocProvider<LogoutBloc>.value(value: mockLogoutBloc),
            ],
            child: const LoginPage(),
          ),
        ),
      );

      expect(find.byType(ScaffoldMessenger), findsOneWidget);
    });
  });
}
