import 'package:flutter/material.dart';
import 'package:mobile/core/core.dart';

class EditProfileFields extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final GlobalKey<FormState> formKey;

  const EditProfileFields({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
    required this.usernameController,
    required this.emailController,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildFirstNameField(context),
          const SizedBox(height: 16),
          _buildLastNameField(context),
          const SizedBox(height: 16),
          _buildUsernameField(context),
          const SizedBox(height: 16),
          _buildEmailField(context),
        ],
      ),
    );
  }

  Widget _buildFirstNameField(BuildContext context) {
    return TextFormField(
      controller: firstNameController,
      cursorColor: Theme.of(context).colorScheme.primary,
      decoration: _getInputDecoration(
        context: context,
        labelText: 'First Name',
        hintText: 'Enter your first name',
        prefixIcon: Icons.person_outline,
      ),
      validator: UserValidator.validateName,
    );
  }

  Widget _buildLastNameField(BuildContext context) {
    return TextFormField(
      controller: lastNameController,
      cursorColor: Theme.of(context).colorScheme.primary,
      decoration: _getInputDecoration(
        context: context,
        labelText: 'Last Name',
        hintText: 'Enter your last name',
        prefixIcon: Icons.person_outline,
      ),
      validator: UserValidator.validateName,
    );
  }

  Widget _buildUsernameField(BuildContext context) {
    return TextFormField(
      controller: usernameController,
      cursorColor: Theme.of(context).colorScheme.primary,
      decoration: _getInputDecoration(
        context: context,
        labelText: 'Username',
        hintText: 'Enter your username',
        prefixIcon: Icons.alternate_email,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a username';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField(BuildContext context) {
    return TextFormField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      cursorColor: Theme.of(context).colorScheme.primary,
      decoration: _getInputDecoration(
        context: context,
        labelText: 'Email',
        hintText: 'email@example.com',
        prefixIcon: Icons.email_outlined,
      ),
      validator: UserValidator.validateEmail,
    );
  }

  InputDecoration _getInputDecoration({
    required BuildContext context,
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      hintStyle: TextStyle(
        color: Theme.of(
          context,
        ).colorScheme.onSurface.withAlpha((0.3 * 255).round()),
      ),
      prefixIcon: Icon(
        prefixIcon,
        color: Theme.of(context).colorScheme.outline,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withAlpha((0.3 * 255).round()),
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
    );
  }
}
