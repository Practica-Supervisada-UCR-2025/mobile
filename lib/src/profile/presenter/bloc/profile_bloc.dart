import 'dart:io';

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
    on<ProfileUpdate>(_onProfileUpdate);
  }

  Future<void> _onProfileLoad(
    ProfileLoad event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final user = await profileRepository.getCurrentUser(LocalStorage().accessToken);
      emit(ProfileSuccess(user: user));
    } catch (e) {
      emit(ProfileFailure(error: e.toString()));
    }
  }

  Future<void> _onProfileUpdate(
    ProfileUpdate event,
    Emitter<ProfileState> emit,
  ) async {
    // Store current state to restore it if update fails
    final currentState = state;

    if (currentState is ProfileSuccess) {
      emit(ProfileUpdating(user: currentState.user));
      try {
        final updatedUser = await profileRepository.updateUserProfile(
          "1",
          event.updates,
          profilePicture: event.profilePicture,
        );
        emit(ProfileUpdateSuccess(user: updatedUser));

        // Emit a new ProfileSuccess state with the updated user
        // to ensure that the UI reflects the changes
        // made to the user profile
        emit(ProfileSuccess(user: updatedUser));
      } catch (e) {
        emit(
          ProfileUpdateFailure(error: e.toString(), user: currentState.user),
        );
      }
    }
  }
}
