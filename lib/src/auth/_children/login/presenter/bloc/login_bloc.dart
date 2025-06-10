import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/storage/user_session.storage.dart';
import 'package:mobile/src/auth/auth.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginRepository loginRepository;
  final LocalStorage localStorage;
  final TokensRepository tokensRepository;

  // Constructor
  // The LoginBloc takes a LoginRepository as a dependency
  // and initializes the state to LoginInitial.
  LoginBloc({
    required this.loginRepository,
    required this.localStorage,
    required this.tokensRepository,
  }) : super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LoginReset>(_onLoginReset);
  }

  void _onLoginReset(LoginReset event, Emitter<LoginState> emit) {
    emit(LoginInitial());
  }

  // Event handler for LoginSubmitted event
  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading()); // Always emit loading state first

    try {
      final user = await loginRepository.login(event.username, event.password);

      final tokens = await tokensRepository.getTokens(user.authProviderToken);

      localStorage.userId = user.id;
      localStorage.userEmail = user.email;
      localStorage.accessToken = tokens.accessToken;

      emit(LoginSuccess(user: user));
    } on AuthException catch (e) {
      emit(LoginFailure(error: e.message));
    } catch (e) {
      emit(LoginFailure(error: 'Unexpected error'));
    }
  }
}
