import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/core.dart';
import 'package:mobile/src/profile/profile.dart';

part 'edit_profile_event.dart';
part 'edit_profile_state.dart';

class EditProfileBloc extends Bloc<EditProfileEvent, EditProfileState> {
  final EditProfileRepository editProfileRepository;

  EditProfileBloc({required this.editProfileRepository})
    : super(EditProfileInitial()) {
    on<EditProfileSubmitted>(_onEditProfileSubmitted);
  }

  Future<void> _onEditProfileSubmitted(
    EditProfileSubmitted event,
    Emitter<EditProfileState> emit,
  ) async {
    emit(EditProfileUpdating());
    try {
      final updatedUser = await editProfileRepository.updateUserProfile(
        LocalStorage().accessToken,
        event.updates,
        profilePicture: event.profilePicture,
      );
      emit(EditProfileSuccess(user: updatedUser));
    } catch (e) {
      emit(EditProfileFailure(error: e.toString()));
    }
  }
}
