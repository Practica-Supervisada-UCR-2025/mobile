part of 'edit_profile_bloc.dart';

abstract class EditProfileState extends Equatable {
  const EditProfileState();

  @override
  List<Object?> get props => [];
}

class EditProfileInitial extends EditProfileState {}

class EditProfileUpdating extends EditProfileState {}

class EditProfileSuccess extends EditProfileState {
  final User user;

  const EditProfileSuccess({required this.user});

  @override
  List<Object?> get props => [user];
}

class EditProfileFailure extends EditProfileState {
  final String error;

  const EditProfileFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
