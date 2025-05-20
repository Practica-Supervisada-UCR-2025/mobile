part of 'profile_bloc.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

final class ProfileInitial extends ProfileState {}

final class ProfileLoading extends ProfileState {}

final class ProfileSuccess extends ProfileState {
  final User user;

  const ProfileSuccess({required this.user});
}

final class ProfileFailure extends ProfileState {
  final String error;

  const ProfileFailure({required this.error});

  @override
  List<Object> get props => [error];
}

final class ProfileUpdating extends ProfileState {
  final User user;

  const ProfileUpdating({required this.user});

  @override
  List<Object> get props => [user];
}

final class ProfileUpdateSuccess extends ProfileState {
  final User user;

  const ProfileUpdateSuccess({required this.user});

  @override
  List<Object> get props => [user];
}

final class ProfileUpdateFailure extends ProfileState {
  final String error;
  final User user;

  const ProfileUpdateFailure({required this.error, required this.user});

  @override
  List<Object> get props => [error, user];
}
