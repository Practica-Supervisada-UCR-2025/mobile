part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileLoad extends ProfileEvent {
  final String? userId;
  const ProfileLoad({this.userId});
}

class ProfileRefreshed extends ProfileEvent {
  final User user;

  const ProfileRefreshed(this.user);

  @override
  List<Object?> get props => [user];
}
