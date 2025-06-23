import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/core.dart';
import 'package:mobile/src/auth/auth.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late AnimationController _animationController;
  Animation<double>? _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: MultiBlocListener(
            listeners: [
              BlocListener<RegisterBloc, RegisterState>(
                listener: (context, state) {
                  if (state is RegisterSuccess) {
                    context.read<LoginBloc>().add(
                      LoginSubmitted(
                        username: state.user.email,
                        password: state.password,
                      ),
                    );
                  } else if (state is RegisterFailure) {
                    FeedbackSnackBar.showError(context, state.error);
                  }
                },
              ),
              BlocListener<LoginBloc, LoginState>(
                listener: (context, state) {
                  if (state is LoginFailure) {
                    FeedbackSnackBar.showError(context, state.error);
                  }
                },
              ),
            ],
            child: BlocBuilder<RegisterBloc, RegisterState>(
              builder: (context, state) {
                if (_fadeAnimation == null) return const SizedBox();

                return FadeTransition(
                  opacity: _fadeAnimation!,
                  child: Stack(
                    children: [
                      if (state is! RegisterLoading &&
                          state is! RegisterSuccess)
                        RegisterForm(
                          nameController: _nameController,
                          emailController: _emailController,
                          passwordController: _passwordController,
                          confirmPasswordController: _confirmPasswordController,
                          onRegister: (name, email, password) {
                            context.read<RegisterBloc>().add(
                              RegisterSubmitted(
                                name: name,
                                email: email,
                                password: password,
                              ),
                            );
                          },
                        ),
                      if (state is RegisterLoading)
                        Container(
                          color: Theme.of(context).colorScheme.surface,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
