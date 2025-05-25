part of 'edit_profile_bloc.dart';

abstract class EditProfileEvent extends Equatable {
  const EditProfileEvent();

  @override
  List<Object?> get props => [];
}

class EditProfileSubmitted extends EditProfileEvent {
  final Map<String, dynamic> updates;
  final File? profilePicture;

  const EditProfileSubmitted({required this.updates, this.profilePicture});

  @override
  List<Object?> get props => [updates, profilePicture];
}
