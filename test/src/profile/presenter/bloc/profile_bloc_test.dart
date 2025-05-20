import 'dart:io';

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
  const testToken = 'mocked_token';

  final testUser = User(
    firstName: "user",
    lastName: "name",
    username: "user1",
    email: "user@ucr.ac.cr",
    image: "https://dummyjson.com/icon/emilys/128",
  );

  
  final updatedUser = User(
    firstName: "updated",
    lastName: "user",
    username: "updated_user1",
    email: "updated_user@ucr.ac.cr",
    image: "https://dummyjson.com/icon/emilys/256",
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
        when(mockProfileRepository.getCurrentUser(any))
            .thenAnswer((_) async => testUser);

        return profileBloc;
      },
      act: (bloc) => bloc.add(const ProfileLoad()),
      expect: () => [
        isA<ProfileLoading>(),
        isA<ProfileSuccess>().having((state) => state.user, 'user', testUser),
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
  });

  group('ProfileBloc - Update Profile Tests', () {
    // Helper function to prepare the bloc with a successful state
    ProfileBloc prepareSuccessState() {
      final bloc = ProfileBloc(profileRepository: mockProfileRepository);
      bloc.emit(ProfileSuccess(user: testUser));
      return bloc;
    }

    blocTest<ProfileBloc, ProfileState>(
      'should emit [ProfileUpdating, ProfileUpdateSuccess, ProfileSuccess] when update is successful',
      build: () {
        profileBloc = prepareSuccessState();

        final userUpdates = {'firstName': 'updated', 'lastName': 'user'};

        when(
          mockProfileRepository.updateUserProfile(
            "1",
            userUpdates,
            profilePicture: null,
          ),
        ).thenAnswer((_) async => updatedUser);

        return profileBloc;
      },
      act:
          (bloc) => bloc.add(
            ProfileUpdate(
              updates: {'firstName': 'updated', 'lastName': 'user'},
            ),
          ),
      expect:
          () => [
            isA<ProfileUpdating>().having(
              (state) => state.user,
              'original user',
              testUser,
            ),
            isA<ProfileUpdateSuccess>().having(
              (state) => state.user,
              'updated user',
              updatedUser,
            ),
            isA<ProfileSuccess>().having(
              (state) => state.user,
              'final state user',
              updatedUser,
            ),
          ],
      verify: (_) {
        verify(
          mockProfileRepository.updateUserProfile("1", {
            'firstName': 'updated',
            'lastName': 'user',
          }, profilePicture: null),
        ).called(1);
      },
    );

    blocTest<ProfileBloc, ProfileState>(
      'should emit [ProfileUpdating, ProfileUpdateFailure] when update fails',
      build: () {
        profileBloc = prepareSuccessState();

        final userUpdates = {'firstName': 'updated', 'lastName': 'user'};

        when(
          mockProfileRepository.updateUserProfile(
            "1",
            userUpdates,
            profilePicture: null,
          ),
        ).thenThrow(Exception('Failed to update profile'));

        return profileBloc;
      },
      act:
          (bloc) => bloc.add(
            ProfileUpdate(
              updates: {'firstName': 'updated', 'lastName': 'user'},
            ),
          ),
      expect:
          () => [
            isA<ProfileUpdating>().having(
              (state) => state.user,
              'original user',
              testUser,
            ),
            isA<ProfileUpdateFailure>()
                .having(
                  (state) => state.user,
                  'original user restored',
                  testUser,
                )
                .having(
                  (state) => state.error,
                  'error message',
                  'Exception: Failed to update profile',
                ),
          ],
      verify: (_) {
        verify(
          mockProfileRepository.updateUserProfile("1", {
            'firstName': 'updated',
            'lastName': 'user',
          }, profilePicture: null),
        ).called(1);
      },
    );

    test(
      'should not emit any states when current state is not ProfileSuccess',
      () {
        // Set the state to something other than ProfileSuccess
        profileBloc.emit(ProfileInitial());

        // Add the update event
        profileBloc.add(ProfileUpdate(updates: {'firstName': 'updated'}));

        // Use expectLater to verify no state changes occur
        expectLater(profileBloc.stream, emitsInOrder([]));

        // Verify no repository calls were made
        verifyNever(mockProfileRepository.updateUserProfile(any, any));
      },
    );

    test('props should contain updates and profilePicture', () {
      final testFile = File('test_image.jpg');

      final event1 = ProfileUpdate(
        updates: {'name': 'test'},
        profilePicture: testFile,
      );

      final event2 = ProfileUpdate(
        updates: {'name': 'test'},
        profilePicture: testFile,
      );

      final event3 = ProfileUpdate(
        updates: {'name': 'different'},
        profilePicture: testFile,
      );

      expect(event1, equals(event2));
      expect(event1, isNot(equals(event3)));

      expect(
        event1.props,
        containsAll([
          {'name': 'test'},
          testFile,
        ]),
      );

      expect(event1.hashCode, equals(event2.hashCode));
      expect(event1.hashCode, isNot(equals(event3.hashCode)));
    });
  });
}
