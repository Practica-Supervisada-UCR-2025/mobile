import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mobile/core/core.dart';
import 'package:mobile/src/profile/presenter/bloc/profile_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:mobile/src/profile/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

@GenerateMocks([
  ProfileRepository,
  LocalStorage,
  ProfileRepositoryAPI,
])
import 'profile_bloc_test.mocks.dart';

void main() {
  late MockProfileRepository mockProfileRepository;
  late MockLocalStorage mockLocalStorage;
  late MockProfileRepositoryAPI mockProfileRepositoryAPI;
  late ProfileBloc profileBloc;

  final testUser = 
  User(
    firstName: "user", 
    lastName: "name", 
    username: "user1", 
    email: "user@ucr.ac.cr", 
    image: "https://dummyjson.com/icon/emilys/128"
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});

    mockProfileRepository = MockProfileRepository();
    mockLocalStorage = MockLocalStorage();
    mockProfileRepositoryAPI = MockProfileRepositoryAPI();

    profileBloc = ProfileBloc(
      profileRepository: mockProfileRepository,
    );
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
      build: (){
        when(mockProfileRepository.getCurrentUser('1')).thenAnswer((_) async => testUser);
        
        return profileBloc;
      },
      act: (bloc) => bloc.add(const ProfileLoad()),
      expect: () => [
        isA<ProfileLoading>(),
        isA<ProfileSuccess>().having((state) => state.user, 'user', testUser),
      ],
      verify: (_) {
        verify(mockProfileRepository.getCurrentUser('1')).called(1);
      },
    );

    blocTest<ProfileBloc, ProfileState>(
      'should emit [ProfileLoading, ProfileError] when a fetch fails', 
      build: (){
        when(mockProfileRepository.getCurrentUser('1')).thenThrow(Exception('Failed to load user'));
        
        return profileBloc;
      },
      act: (bloc) => bloc.add(const ProfileLoad()),
      expect: () => [
        isA<ProfileLoading>(),
        isA<ProfileFailure>(),
      ],
      verify: (_) {
        verify(mockProfileRepository.getCurrentUser('1')).called(1);
      },
    );
  }); 
}
