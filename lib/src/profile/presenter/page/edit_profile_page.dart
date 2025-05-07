import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/globals/widgets/secondary_button.dart';
import 'package:mobile/src/profile/domain/models/user.dart';
import 'package:mobile/src/profile/presenter/bloc/profile_bloc.dart';

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
      controller.addListener(() {
        final isDirty =
            _firstNameController.text != widget.user.firstName ||
            _lastNameController.text != widget.user.lastName ||
            _usernameController.text != widget.user.username ||
            _emailController.text != widget.user.email;

        if (isDirty != _isFormDirty) {
          setState(() {
            _isFormDirty = isDirty;
          });
        }
      });
    }
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

      if (_firstNameController.text != widget.user.firstName) {
        updates['firstName'] = _firstNameController.text;
      }

      if (_lastNameController.text != widget.user.lastName) {
        updates['lastName'] = _lastNameController.text;
      }

      if (_usernameController.text != widget.user.username) {
        updates['username'] = _usernameController.text;
      }

      if (_emailController.text != widget.user.email) {
        updates['email'] = _emailController.text;
      }

      if (updates.isNotEmpty) {
        context.read<ProfileBloc>().add(ProfileUpdate(updates: updates));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          BlocConsumer<ProfileBloc, ProfileState>(
            listener: (context, state) {
              if (state is ProfileUpdateSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated successfully')),
                );
                Navigator.of(context).pop();
              } else if (state is ProfileUpdateFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Update failed: ${state.error}')),
                );
              }
            },
            builder: (context, state) {
              final isLoading = state is ProfileUpdating;
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: TextButton(
                  onPressed: _isFormDirty && !isLoading ? _saveChanges : null,
                  child:
                      isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text('Save'),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Image Section
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                          backgroundImage:
                              widget.user.image != null
                                  ? NetworkImage(widget.user.image!)
                                  : null,
                          child:
                              widget.user.image == null
                                  ? Text(
                                    widget.user.firstName[0] +
                                        widget.user.lastName[0],
                                    style: TextStyle(
                                      fontSize: 30,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  )
                                  : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt, size: 18),
                              color: Theme.of(context).colorScheme.onPrimary,
                              onPressed: () {
                                // TODO: Implement image upload
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Image upload not implemented yet',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Form Fields
                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your last name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a username';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // TODO: Save Button
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
