part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileLoad extends ProfileEvent {
  const ProfileLoad();
}

class ProfileUpdate extends ProfileEvent {
  final Map<String, dynamic> updates;
  final File? profilePicture;

  const ProfileUpdate({required this.updates, this.profilePicture});

  @override
  List<Object?> get props => [updates, profilePicture];
}
