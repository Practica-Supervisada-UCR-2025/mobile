import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:mobile/src/auth/auth.dart';

import 'logout_bloc_test.mocks.dart';

@GenerateMocks([LogoutRepository])
void main() {
  late MockLogoutRepository mockLogoutRepository;
  late LogoutBloc logoutBloc;

  setUp(() {
    mockLogoutRepository = MockLogoutRepository();
    logoutBloc = LogoutBloc(logoutRepository: mockLogoutRepository);
  });

  tearDown(() {
    logoutBloc.close();
  });

  group('LogoutBloc', () {
    test('initial state is LogoutInitial', () {
      expect(logoutBloc.state, LogoutInitial());
    });

    test('LogoutRequested should be equatable', () {
      final eventA = LogoutRequested();
      final eventB = LogoutRequested();

      expect(eventA, equals(eventB));
      expect(eventA.props, isEmpty);
    });

    blocTest<LogoutBloc, LogoutState>(
      'emits [LogoutLoading, LogoutSuccess] when logout succeeds',
      build: () {
        when(mockLogoutRepository.logout()).thenAnswer((_) async {});
        return logoutBloc;
      },
      act: (bloc) => bloc.add(LogoutRequested()),
      expect: () => [LogoutLoading(), LogoutSuccess()],
      verify: (_) {
        verify(mockLogoutRepository.logout()).called(1);
      },
    );

    blocTest<LogoutBloc, LogoutState>(
      'emits [LogoutLoading, LogoutFailure] when logout throws',
      build: () {
        when(mockLogoutRepository.logout()).thenThrow(Exception('error'));
        return logoutBloc;
      },
      act: (bloc) => bloc.add(LogoutRequested()),
      expect:
          () => [
            LogoutLoading(),
            isA<LogoutFailure>().having(
              (e) => e.message,
              'message',
              'Logout failed',
            ),
          ],
      verify: (_) {
        verify(mockLogoutRepository.logout()).called(1);
      },
    );
  });
}
