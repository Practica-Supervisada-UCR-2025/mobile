part of 'register_bloc.dart';

sealed class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object> get props => [];
}

final class RegisterSubmitted extends RegisterEvent {

  final String username;
  final String password;

  const RegisterSubmitted({required this.username, required this.password});

  @override
  List<Object> get props => [username, password];

}
