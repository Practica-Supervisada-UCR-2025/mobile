import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/storage/user_session.storage.dart';
import 'package:mobile/src/profile/domain/models/models.dart';
import 'package:mobile/src/profile/domain/repository/repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository profileRepository;

  ProfileBloc({required this.profileRepository}) : super(ProfileInitial()) {
    on<ProfileLoad>(_onProfileLoad);
    on<ProfileRefreshed>((event, emit) {
      emit(ProfileSuccess(user: event.user));
    });
  }

  Future<void> _onProfileLoad(
    ProfileLoad event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final user = event.userId == null
        ? await profileRepository.getCurrentUser(
          LocalStorage().accessToken
        )
        : await profileRepository.getUserProfile(
          event.userId!,
          LocalStorage().accessToken
        );
      if(event.userId == null) {
        LocalStorage localStorage = LocalStorage();
        localStorage.userProfilePicture = user.image;
        localStorage.username = user.username;
      }
      emit(ProfileSuccess(user: user));
    } catch (e) {
      emit(ProfileFailure(error: e.toString()));
    }
  }
}
