import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/core.dart';
import 'package:mobile/src/auth/auth.dart';

// LoginPage is a StatefulWidget that represents the login screen of the app.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

// State class for LoginPage
class _LoginPageState extends State<LoginPage> {
  // Controllers for email and password input fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Boolean to track whether the login process is loading
  bool _isLoading = false;

  @override
void initState() {
  super.initState();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    final initialState = context.read<LoginBloc>().state;
    if (initialState is LoginLoading) {
      setState(() {
        _isLoading = true;
      });
    }
  });
}


  // Dispose controllers when the widget is removed from the widget tree
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar with the title "Login"
      appBar: AppBar(title: const Text('Login')),

      // Set the background color using the app's theme
      backgroundColor: Theme.of(context).colorScheme.surface,

      // Padding around the body content
      body: Padding(
        padding: const EdgeInsets.all(16.0),

        // BlocConsumer listens to LoginBloc and reacts to state changes
        child: BlocConsumer<LoginBloc, LoginState>(
          listener: (context, state) {
            // Handle state changes
            if (state is LoginLoading) {
              setState(() {
                _isLoading = true;
              });
            } else {
              setState(() {
                _isLoading = false;
              });
            }

            if (state is LoginSuccess) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            } else if (state is LoginFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            }
          },
          builder: (context, state) {
            // Build the UI based on the current state
            if (state is LoginLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is LoginSuccess) {
              return const Center(child: Text('Login Successful'));
            }
            return Stack(
              children: [
                if (!_isLoading)
                  LoginForm(
                    emailController: _emailController,
                    passwordController: _passwordController,
                    onLogin: (email, password) {
                      context.read<LoginBloc>().add(
                        LoginSubmitted(username: email, password: password),
                      );
                    },
                  ),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator()),
              ],
            );
          },
        ),
      ),
    );
  }
}

// TODO: Redirect to the actual home screen of the app
// HomePage is a placeholder for the app's home screen after login
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar with the title "Home"
      appBar: AppBar(title: const Text('Home')),

      // Display a welcome message with the user's email
      body: Center(child: Text('Welcome ${LocalStorage().userEmail}')),
    );
  }
}
