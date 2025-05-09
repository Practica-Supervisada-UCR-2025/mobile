import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/src/profile/domain/models/models.dart';
import 'package:mobile/src/profile/domain/repository/repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository profileRepository;

  ProfileBloc({
    required this.profileRepository,
  }) : super(ProfileInitial()) {
    on<ProfileLoad>(_onProfileLoad);
  }

  Future<void> _onProfileLoad(
    ProfileLoad event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      // TODO: Remove hardcoded user ID and use the one from LocalStorage
      // final user = await profileRepository.getCurrentUser(LocalStorage().accessToken);
      final user = await profileRepository.getCurrentUser("1");
      emit(ProfileSuccess(user: user));
    } catch (e) {
      emit(ProfileFailure(error: e.toString()));
    }
  }
}