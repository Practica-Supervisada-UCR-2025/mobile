import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/core.dart';

class ProfileImagePicker extends StatelessWidget {
  final String currentImage;
  final File? selectedImage;
  final Function(File?) onImageSelected;

  const ProfileImagePicker({
    super.key,
    required this.currentImage,
    this.selectedImage,
    required this.onImageSelected,
  });

  void _showImageSourceOptions(BuildContext context) {
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
                    onTap: () async {
                      final navigatorContext = Navigator.of(context).context;
                      context.pop();

                      String? errorMessage;
                      final image = await context
                          .read<MediaPickerRepository>()
                          .pickImageFromGallery(
                            context: context,
                            config: MediaPickerConfig(
                              allowedExtensions: IMAGES_ALLOWED,
                              maxSizeInBytes: MAX_IMAGE_SIZE,
                              onInvalidFile: (error) {
                                errorMessage = error;
                              },
                            ),
                          );

                      if (image != null) {
                        onImageSelected(image);
                      } else if (errorMessage != null &&
                          navigatorContext.mounted) {
                        ScaffoldMessenger.of(
                          navigatorContext,
                        ).showSnackBar(SnackBar(content: Text(errorMessage!)));
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.camera_alt),
                    title: const Text('Camera'),
                    onTap: () async {
                      final navigatorContext = Navigator.of(context).context;
                      context.pop();
                      String? errorMessage;
                      final photo = await context
                          .read<MediaPickerRepository>()
                          .takePhoto(
                            context: context,
                            config: MediaPickerConfig(
                              allowedExtensions: IMAGES_ALLOWED,
                              maxSizeInBytes: MAX_IMAGE_SIZE,
                              onInvalidFile: (error) {
                                errorMessage = error;
                              },
                            ),
                          );

                      if (photo != null) {
                        onImageSelected(photo);
                      } else if (errorMessage != null &&
                          navigatorContext.mounted) {
                        ScaffoldMessenger.of(
                          navigatorContext,
                        ).showSnackBar(SnackBar(content: Text(errorMessage!)));
                      }
                    },
                  ),
                  if (selectedImage != null || currentImage.isNotEmpty)
                    ListTile(
                      leading: const Icon(Icons.delete, color: Colors.red),
                      title: const Text(
                        'Delete Image',
                        style: TextStyle(color: Colors.red),
                      ),
                      onTap: () {
                        context.pop();
                        onImageSelected(null);
                      },
                    ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showImageSourceOptions(context),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          // Profile image
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withAlpha(50),
            backgroundImage:
                selectedImage != null
                    ? FileImage(selectedImage!) as ImageProvider
                    : currentImage.isNotEmpty
                    ? NetworkImage(currentImage)
                    : const NetworkImage(DEFAULT_PROFILE_PIC_2),
            child: null,
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: const Icon(
              Icons.add_a_photo_rounded,
              size: 18,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
