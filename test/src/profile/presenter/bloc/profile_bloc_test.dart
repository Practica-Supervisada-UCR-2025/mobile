import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mobile/core/core.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:mobile/src/profile/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

@GenerateMocks([ProfileRepository, LocalStorage, ProfileRepositoryAPI])
import 'profile_bloc_test.mocks.dart';

void main() {
  late MockProfileRepository mockProfileRepository;
  late ProfileBloc profileBloc;
  late MockLocalStorage mockLocalStorage;

  final testUser = User(
    firstName: "user",
    lastName: "name",
    username: "user1",
    email: "user@ucr.ac.cr",
    image: "https://dummyjson.com/icon/emilys/128",
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});

    mockProfileRepository = MockProfileRepository();

    profileBloc = ProfileBloc(profileRepository: mockProfileRepository);

    mockLocalStorage = MockLocalStorage();
    LocalStorage.init();
    when(mockLocalStorage.accessToken).thenReturn('1');
    when(mockLocalStorage.userId).thenReturn('1');
  });

  // after each test, reset the mock
  tearDown(() {
    profileBloc.close();
  });

  group('ProfileBloc', () {
    test('initial state of profile bloc should be ProfileInitial', () {
      expect(profileBloc.state, isA<ProfileInitial>());
    });

    blocTest<ProfileBloc, ProfileState>(
      'should emit [ProfileLoading, ProfileSuccess] when a fetch is successful',
      build: () {
        when(
          mockProfileRepository.getCurrentUser(any),
        ).thenAnswer((_) async => testUser);

        return profileBloc;
      },
      act: (bloc) => bloc.add(const ProfileLoad()),
      expect:
          () => [
            isA<ProfileLoading>(),
            isA<ProfileSuccess>().having(
              (state) => state.user,
              'user',
              testUser,
            ),
          ],
      verify: (_) {
        verify(mockProfileRepository.getCurrentUser(any)).called(1);
      },
    );

    blocTest<ProfileBloc, ProfileState>(
      'should emit [ProfileLoading, ProfileError] when a fetch fails',
      build: () {
        when(
          mockProfileRepository.getCurrentUser(any),
        ).thenThrow(Exception('Failed to load user'));

        return profileBloc;
      },
      act: (bloc) => bloc.add(const ProfileLoad()),
      expect: () => [isA<ProfileLoading>(), isA<ProfileFailure>()],
      verify: (_) {
        verify(mockProfileRepository.getCurrentUser(any)).called(1);
      },
    );

    blocTest<ProfileBloc, ProfileState>(
      'should emit [ProfileSuccess] when ProfileRefreshed event is added',
      build: () {
        return profileBloc;
      },
      act: (bloc) => bloc.add(ProfileRefreshed(testUser)),
      expect:
          () => [
            isA<ProfileSuccess>().having(
              (state) => state.user,
              'user',
              testUser,
            ),
          ],
    );
  });

  group('ProfileEvent Props', () {
    test('ProfileLoad props should be empty', () {
      const event = ProfileLoad();
      expect(event.props, []);
    });

    test('ProfileRefreshed props should contain user', () {
      final user = User(
        firstName: "user",
        lastName: "name",
        username: "user1",
        email: "user@ucr.ac.cr",
        image: "https://dummyjson.com/icon/emilys/128",
      );
      final event = ProfileRefreshed(user);
      expect(event.props, [user]);
    });
  });
}
