import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/globals/globals.dart';
import '../../forgot_password.dart';

class ForgotPasswordForm extends StatefulWidget {
  const ForgotPasswordForm({super.key});

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    final regex = RegExp(r'^[\w-\.]+@ucr\.ac\.cr$');

    if (email.isEmpty) {
      return 'This field is required';
    }

    if (!regex.hasMatch(email)) {
      return 'Invalid email. Must be @ucr.ac.cr domain.';
    }

    return null;
  }

  void _showDialog(String title, String message, {bool success = false}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('Accept'),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              if (success) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      );
    },
  );
}


  void _onSubmit() {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      final email = _emailController.text.trim();
      context.read<ForgotPasswordBloc>().add(ForgotPasswordSubmitted(email));
    } else {
      _emailController.clear();
      _showDialog(
        'Invalid Email',
        'Please enter a valid email address from the @ucr.ac.cr domain.',
      );
    }
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      cursorColor: Theme.of(context).colorScheme.primary,
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'email@ucr.ac.cr',
        hintStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withAlpha((0.3 * 255).round()),
        ),
        prefixIcon: Icon(
          Icons.email_outlined,
          color: Theme.of(context).colorScheme.outline,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.onSurface.withAlpha((0.3 * 255).round()),
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 1.0,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 2.0,
          ),
        ),
        fillColor: Theme.of(context).colorScheme.surface,
        filled: true,
        labelStyle: TextStyle(color: Theme.of(context).colorScheme.outline),
        floatingLabelStyle: TextStyle(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      validator: _validateEmail,
    );
  }

  Widget _buildSubmitButton() {
  return PrimaryButton(
    onPressed: _isLoading ? () {} : _onSubmit,
    text: 'Send',
    isLoading: _isLoading,
    isEnabled: !_isLoading,
  );
}

  @override
  Widget build(BuildContext context) {
    return BlocListener<ForgotPasswordBloc, ForgotPasswordState>(
      listener: (context, state) {
        if (state is ForgotPasswordLoading) {
          setState(() {
            _isLoading = true;
          });
        } else {
          setState(() {
            _isLoading = false;
          });

          if (state is ForgotPasswordSuccess) {
            _showDialog('Mail sent', state.message, success: true);
          } else if (state is ForgotPasswordFailure) {
            _showDialog('Error', state.message);
          }
        }
      },
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildEmailField(),
              const SizedBox(height: 16),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }
}
