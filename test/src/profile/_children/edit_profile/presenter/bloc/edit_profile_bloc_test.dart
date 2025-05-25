import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mobile/src/profile/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

@GenerateMocks([EditProfileRepository])
import 'edit_profile_bloc_test.mocks.dart';

class DummyEvent extends EditProfileEvent {
  const DummyEvent();
}

void main() {
  late MockEditProfileRepository mockEditProfileRepository;
  late EditProfileBloc editProfileBloc;

  final testUser = User(
    firstName: "user",
    lastName: "name",
    username: "user1",
    email: "user@ucr.ac.cr",
    image: "https://dummyjson.com/icon/emilys/128",
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    mockEditProfileRepository = MockEditProfileRepository();
    editProfileBloc = EditProfileBloc(
      editProfileRepository: mockEditProfileRepository,
    );
  });

  tearDown(() {
    editProfileBloc.close();
  });

  group('EditProfileBloc', () {
    test('initial state should be EditProfileInitial', () {
      expect(editProfileBloc.state, isA<EditProfileInitial>());
    });

    blocTest<EditProfileBloc, EditProfileState>(
      'emits [EditProfileUpdating, EditProfileSuccess] on successful update',
      build: () {
        when(
          mockEditProfileRepository.updateUserProfile(
            any,
            profilePicture: anyNamed('profilePicture'),
          ),
        ).thenAnswer((_) async => testUser);

        return editProfileBloc;
      },
      act:
          (bloc) => bloc.add(
            const EditProfileSubmitted(updates: {'firstName': 'new name'}),
          ),
      expect:
          () => [
            EditProfileUpdating(),
            isA<EditProfileSuccess>().having(
              (state) => state.user,
              'user',
              testUser,
            ),
          ],
      verify: (_) {
        verify(
          mockEditProfileRepository.updateUserProfile({
            'firstName': 'new name',
          }, profilePicture: null),
        ).called(1);
      },
    );

    blocTest<EditProfileBloc, EditProfileState>(
      'emits [EditProfileUpdating, EditProfileFailure] on update failure',
      build: () {
        when(
          mockEditProfileRepository.updateUserProfile(
            any,
            profilePicture: anyNamed('profilePicture'),
          ),
        ).thenThrow(Exception('Update failed'));

        return editProfileBloc;
      },
      act:
          (bloc) => bloc.add(
            const EditProfileSubmitted(updates: {'firstName': 'new name'}),
          ),
      expect:
          () => [
            EditProfileUpdating(),
            isA<EditProfileFailure>().having(
              (state) => state.error,
              'error',
              'Exception: Update failed',
            ),
          ],
      verify: (_) {
        verify(
          mockEditProfileRepository.updateUserProfile({
            'firstName': 'new name',
          }, profilePicture: null),
        ).called(1);
      },
    );
  });

  group('EditProfileEvent props', () {
    test(
      'EditProfileSubmitted props should include updates and profilePicture',
      () {
        const event = EditProfileSubmitted(
          updates: {'key': 'value'},
          profilePicture: null,
        );
        expect(event.props, [
          {'key': 'value'},
          null,
        ]);
      },
    );

    test('EditProfileEvent props should be empty by default', () {
      const event = DummyEvent();
      expect(event.props, []);
    });
  });
}
