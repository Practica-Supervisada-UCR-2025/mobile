import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/core/core.dart';
import 'package:mobile/src/create/create.dart';

class BottomBar extends StatelessWidget {
  final Function(File?) onImageSelected;

  const BottomBar({super.key, required this.onImageSelected});

  Future<void> _pickImageFromGallery(BuildContext context) async {
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
        onImageSelected(File(image.path));
      }
    }
  }

  Future<void> _takePhoto(BuildContext context) async {
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
        onImageSelected(File(photo.path));
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
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
    );
  }
}