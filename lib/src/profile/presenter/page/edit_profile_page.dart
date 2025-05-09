import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/src/profile/domain/models/user.dart';
import 'package:mobile/src/profile/presenter/bloc/profile_bloc.dart';
import 'package:mobile/src/profile/presenter/widgets/edit_profile_fields.dart';

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
  final ImagePicker _picker = ImagePicker();

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
        _checkFormDirty();
      });
    }
  }

  void _checkFormDirty() {
    final isDirty =
        _firstNameController.text != widget.user.firstName ||
        _lastNameController.text != widget.user.lastName ||
        _usernameController.text != widget.user.username ||
        _emailController.text != widget.user.email ||
        _selectedImage != null;

    if (isDirty != _isFormDirty) {
      setState(() {
        _isFormDirty = isDirty;
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _isFormDirty = true;
      });
    }
  }

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (photo != null) {
      setState(() {
        _selectedImage = File(photo.path);
        _isFormDirty = true;
      });
    }
  }

  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Select Image Source',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Gallery'),
                    onTap: () {
                      Navigator.of(context).pop();
                      _pickImageFromGallery();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.camera_alt),
                    title: const Text('Camera'),
                    onTap: () {
                      Navigator.of(context).pop();
                      _takePhoto();
                    },
                  ),
                  if (_selectedImage != null || widget.user.image.isNotEmpty)
                    ListTile(
                      leading: const Icon(Icons.delete, color: Colors.red),
                      title: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.red),
                      ),
                      onTap: () {
                        context.pop();
                        setState(() {
                          _selectedImage = null;
                          _isFormDirty = true;
                        });
                      },
                    ),
                ],
              ),
            ),
          ),
    );
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

      if (_selectedImage != null) {
        print('Image Changed: ${_selectedImage!.path}');
        // todo: Implement image upload logic
        // updates['image'] = _selectedImage;
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
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [
          // Save button in app bar
          BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              final isLoading = state is ProfileUpdating;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: TextButton.icon(
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
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: Colors.white),
                    SizedBox(width: 8),
                    Expanded(child: Text('Profile updated successfully')),
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
            context.pop();
          } else if (state is ProfileUpdateFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.white),
                    SizedBox(width: 8),
                    Expanded(child: Text('Update failed: ${state.error}')),
                  ],
                ),
                backgroundColor: Theme.of(context).colorScheme.error,
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.all(16),
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
                    // Profile Image Section with edit functionality
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        // Imagen de perfil
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.2),
                          backgroundImage:
                              _selectedImage != null
                                  ? FileImage(_selectedImage!) as ImageProvider
                                  : widget.user.image.isNotEmpty
                                  ? NetworkImage(widget.user.image)
                                  : null,
                          child:
                              widget.user.image.isEmpty &&
                                      _selectedImage == null
                                  ? Icon(
                                    Icons.person,
                                    size: 50,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  )
                                  : null,
                        ),
                        // Botón para editar la imagen
                        GestureDetector(
                          onTap: _showImageSourceOptions,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
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
