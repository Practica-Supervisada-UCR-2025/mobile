part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class ProfileLoad extends ProfileEvent {
  const ProfileLoad();
}

class ProfileUpdate extends ProfileEvent {
  final Map<String, dynamic> updates;

  const ProfileUpdate({required this.updates});

  @override
  List<Object> get props => [updates];
}
