import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/core/core.dart';
import 'package:mobile/src/create/create.dart';

class BottomBar extends StatelessWidget {
  final Function(File?) onImageSelected;

  const BottomBar({super.key, required this.onImageSelected});

  Future<bool> _validateFile(XFile file, ScaffoldMessengerState scaffoldMessenger) async {
    final String extension = file.path.split('.').last.toLowerCase();
    final List<String> allowedExtensions = ['png', 'jpeg', 'jpg', 'webp', 'gif'];
    
    if (!allowedExtensions.contains(extension)) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('File type not allowed. Use .png, .jpeg, .jpg, .webp or .gif.'),
        ),
      );
      return false;
    }
    
    final File fileObj = File(file.path);
    final int fileSize = await fileObj.length();
    const int maxSize = 5 * 1024 * 1024;
    
    if (fileSize > maxSize) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('File exceeds the 5MB limit.'),
        ),
      );
      return false;
    }
    
    return true;
  }

  Future<void> _pickImageFromGallery(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    final permissionsRepo = context.read<PermissionsRepository>();
    bool hasPermission = await permissionsRepo.checkGalleryPermission(
      context: context,
    );

    if (hasPermission) {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        if (await _validateFile(image, scaffoldMessenger)) {
          onImageSelected(File(image.path));
        }
      }
    }
  }

  Future<void> _takePhoto(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    final permissionsRepo = context.read<PermissionsRepository>();
    bool hasPermission = await permissionsRepo.checkCameraPermission(
      context: context,
    );

    if (hasPermission) {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (photo != null) {
        if (await _validateFile(photo, scaffoldMessenger)) {
          onImageSelected(File(photo.path));
        }
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).dividerColor,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white10
                  : Colors.black12,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.image_outlined),
              onPressed: () => _pickImageFromGallery(context),
            ),
            IconButton(
              icon: const Icon(Icons.camera_alt_outlined),
              onPressed: () => _takePhoto(context),
            ),
            const Spacer(),
            BlocBuilder<CreatePostBloc, CreatePostState>(
              builder: (context, state) {
                final textLength = state.text.length;
                final isOverLimit = textLength > 300;

                return Text(
                  '$textLength/300',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isOverLimit
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}