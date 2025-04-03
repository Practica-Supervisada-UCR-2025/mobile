import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/src/auth/auth.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginRepository loginRepository;

  // Constructor
  // The LoginBloc takes a LoginRepository as a dependency
  // and initializes the state to LoginInitial.
  LoginBloc({required this.loginRepository}) : super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  // Event handler for LoginSubmitted event
  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading()); // Always emit loading state first

    try {
      final user = await loginRepository.login(event.username, event.password);
      emit(LoginSuccess(user: user));
    } catch (e) {
      emit(LoginFailure(error: e.toString()));
    }
  }
}
