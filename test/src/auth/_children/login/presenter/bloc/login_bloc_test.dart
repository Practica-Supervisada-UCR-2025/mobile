import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mobile/core/core.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:mobile/src/auth/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

@GenerateMocks([
  LoginRepository,
  LocalStorage,
  TokensRepository,
  NotificationsService,
])
import 'login_bloc_test.mocks.dart';

void main() {
  late MockLoginRepository mockLoginRepository;
  late MockLocalStorage mockLocalStorage;
  late MockTokensRepository mockTokensRepository;
  late LoginBloc loginBloc;
  late NotificationsService mockNotificationsService;

  final testUser = AuthUserInfo(
    id: 'test-user-id',
    email: 'user@test.com',
    authProviderToken: 'token123',
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});

    mockLoginRepository = MockLoginRepository();
    mockLocalStorage = MockLocalStorage();
    mockTokensRepository = MockTokensRepository();
    mockNotificationsService = MockNotificationsService();

    loginBloc = LoginBloc(
      loginRepository: mockLoginRepository,
      localStorage: mockLocalStorage,
      tokensRepository: mockTokensRepository,
      notificationsService: mockNotificationsService,
    );
  });

  // after each test, reset the mock
  tearDown(() {
    loginBloc.close();
  });

  group('LoginBloc', () {
    test('initial state of login bloc should be LoginInitial', () {
      expect(loginBloc.state, isA<LoginInitial>());
    });

    test('loginSubmitted event should be equatable', () {
      const eventA = LoginSubmitted(username: 'user', password: 'pass');
      const eventB = LoginSubmitted(username: 'user', password: 'pass');
      const eventC = LoginSubmitted(username: 'other', password: 'pass');

      expect(eventA, equals(eventB));
      expect(eventA == eventB, isTrue);
      expect(eventA == eventC, isFalse);
    });

    blocTest<LoginBloc, LoginState>(
      'should emit [LoginLoading, LoginSuccess] when a login is successful',
      build: () {
        // Mock the login repository response as successful
        when(
          mockLoginRepository.login('user@test.com', 'password'),
        ).thenAnswer((_) async => testUser);

        // Mock tokens repository response
        when(
          mockTokensRepository.getTokens(testUser.authProviderToken),
        ).thenAnswer(
          (_) async => AuthTokens(
            accessToken: 'accessToken',
            refreshToken: 'refreshToken',
          ),
        );

        // Mock localStorage setters (they return void, so we use '')
        when(mockLocalStorage.userId = testUser.id).thenReturn('');
        when(mockLocalStorage.userEmail = testUser.email).thenReturn('');
        when(mockLocalStorage.accessToken = 'accessToken').thenReturn('');

        when(mockNotificationsService.setupNotificationsSilently()).thenAnswer(
          (_) async => const NotificationSetupResult(
            hasPermission: true,
            hasFCMToken: true,
            success: true,
          ),
        );

        return loginBloc;
      },
      act:
          (bloc) => bloc.add(
            const LoginSubmitted(
              username: 'user@test.com',
              password: 'password',
            ),
          ),
      expect:
          () => [
            isA<LoginLoading>(),
            isA<LoginSuccess>().having((state) => state.user, 'user', testUser),
          ],
      verify: (_) {
        verify(
          mockLoginRepository.login('user@test.com', 'password'),
        ).called(1);

        verify(
          mockTokensRepository.getTokens(testUser.authProviderToken),
        ).called(1);

        verify(mockLocalStorage.userId = testUser.id).called(1);
        verify(mockLocalStorage.userEmail = testUser.email).called(1);
        verify(mockLocalStorage.accessToken = 'accessToken').called(1);
        verify(mockNotificationsService.setupNotificationsSilently()).called(1);
      },
    );

    blocTest<LoginBloc, LoginState>(
      'should emit [LoginLoading, LoginFailure] when a login throws AuthException',

      build: () {
        when(
          mockLoginRepository.login('testuser', 'wrong_password'),
        ).thenThrow(AuthException('Invalid credentials'));
        return loginBloc;
      },

      act:
          (bloc) => bloc.add(
            const LoginSubmitted(
              username: 'testuser',
              password: 'wrong_password',
            ),
          ),

      expect: () => [isA<LoginLoading>(), isA<LoginFailure>()],

      verify: (bloc) {
        verify(
          mockLoginRepository.login('testuser', 'wrong_password'),
        ).called(1);

        expect(
          bloc.state,
          isA<LoginFailure>().having(
            (state) => state.error,
            'error',
            'Invalid credentials',
          ),
        );
      },
    );

    blocTest<LoginBloc, LoginState>(
      'should emit [LoginLoading, LoginFailure] when a login throws an unexpected error',

      build: () {
        when(
          mockLoginRepository.login('testuser', 'wrong_password'),
        ).thenThrow(Exception('Unexpected error'));
        return loginBloc;
      },

      act:
          (bloc) => bloc.add(
            const LoginSubmitted(
              username: 'testuser',
              password: 'wrong_password',
            ),
          ),

      expect: () => [isA<LoginLoading>(), isA<LoginFailure>()],

      verify: (bloc) {
        verify(
          mockLoginRepository.login('testuser', 'wrong_password'),
        ).called(1);

        expect(
          bloc.state,
          isA<LoginFailure>().having(
            (state) => state.error,
            'error',
            'Unexpected error',
          ),
        );
      },
    );

    blocTest<LoginBloc, LoginState>(
      'should emit [LoginInitial] when LoginReset is added',
      build: () => loginBloc,

      act: (bloc) => bloc.add(LoginReset()),

      expect: () => [isA<LoginInitial>()],
    );
  });
}
