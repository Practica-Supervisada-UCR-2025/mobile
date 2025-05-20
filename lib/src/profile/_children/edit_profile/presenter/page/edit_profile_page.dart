import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/src/profile/_children/edit_profile/presenter/bloc/edit_profile_bloc.dart';
import 'package:mobile/src/profile/profile.dart';

class ProfileEditPage extends StatefulWidget {
  final User user;

  const ProfileEditPage({super.key, required this.user});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  final _formKey = GlobalKey<FormState>();
  bool _isFormDirty = false;

  File? _selectedImage;
  bool _isRemovingImage = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.user.firstName);
    _lastNameController = TextEditingController(text: widget.user.lastName);
    _usernameController = TextEditingController(text: widget.user.username);
    _emailController = TextEditingController(text: widget.user.email);
    _setupTextControllerListeners();
  }

  void _setupTextControllerListeners() {
    final controllers = [
      _firstNameController,
      _lastNameController,
      _usernameController,
      _emailController,
    ];

    for (final controller in controllers) {
      controller.addListener(_checkFormDirty);
    }
  }

  void _checkFormDirty() {
    final isDirty =
        _firstNameController.text != widget.user.firstName ||
        _lastNameController.text != widget.user.lastName ||
        _usernameController.text != widget.user.username ||
        _emailController.text != widget.user.email ||
        _selectedImage != null ||
        _isRemovingImage;

    if (isDirty != _isFormDirty) {
      setState(() {
        _isFormDirty = isDirty;
      });
    }
  }

  void _handleImageChanged(File? image) {
    setState(() {
      _selectedImage = image;
      _isRemovingImage = image == null && widget.user.image.isNotEmpty;
      _isFormDirty = true;
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_formKey.currentState?.validate() ?? false) {
      final updates = <String, dynamic>{};

      if (_lastNameController.text != widget.user.lastName ||
          _firstNameController.text != widget.user.firstName) {
        updates['full_name'] =
            '${_firstNameController.text} ${_lastNameController.text}';
      }

      if (_usernameController.text != widget.user.username) {
        updates['username'] = _usernameController.text;
      }

      if (_isRemovingImage) {
        updates['profile_picture'] = null;
      }

      context.read<EditProfileBloc>().add(
        EditProfileSubmitted(updates: updates, profilePicture: _selectedImage),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [
          BlocBuilder<EditProfileBloc, EditProfileState>(
            builder: (context, state) {
              final isLoading = state is EditProfileUpdating;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: TextButton.icon(
                  key: const Key('save_button'),
                  onPressed: _isFormDirty && !isLoading ? _saveChanges : null,
                  icon:
                      isLoading
                          ? SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color:
                                  _isFormDirty
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).disabledColor,
                            ),
                          )
                          : Icon(
                            Icons.check,
                            size: 20,
                            color:
                                _isFormDirty
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).disabledColor,
                          ),
                  label: Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color:
                          _isFormDirty
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).disabledColor,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: BlocConsumer<EditProfileBloc, EditProfileState>(
        listener: (context, state) {
          if (state is EditProfileSuccess) {
            // Update the profile in the ProfileBloc
            context.read<ProfileBloc>().add(ProfileRefreshed(state.user));

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: Colors.white),
                    const SizedBox(width: 8),
                    const Expanded(child: Text('Profile updated successfully')),
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
            context.pop();
          } else if (state is EditProfileFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Update failed: ${state.error}')),
                  ],
                ),
                backgroundColor: Theme.of(context).colorScheme.error,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ProfileImagePicker(
                      currentImage: widget.user.image,
                      selectedImage: _selectedImage,
                      onImageSelected: _handleImageChanged,
                    ),
                    const SizedBox(height: 32),
                    EditProfileFields(
                      firstNameController: _firstNameController,
                      lastNameController: _lastNameController,
                      usernameController: _usernameController,
                      emailController: _emailController,
                      formKey: _formKey,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
