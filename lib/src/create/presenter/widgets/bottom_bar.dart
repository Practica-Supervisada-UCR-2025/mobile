import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/core.dart'; 
import 'package:mobile/src/create/create.dart';
import 'package:mobile/src/shared/models/gif_model.dart';

class BottomBar extends StatelessWidget {
  final Function(File?) onImageSelected;

  const BottomBar({super.key, required this.onImageSelected});

  Future<void> _pickImageFromGallery(BuildContext context) async {
    final image = await MediaPickerService.pickImageFromGallery(
      context: context,
      onInvalidFile: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      },
      allowedExtensions: [...IMAGES_ALLOWED, 'gif'], 
      maxSizeInBytes: MAX_IMAGE_SIZE,
    );

    if (image != null) {
      onImageSelected(image);
    }
  }

  Future<void> _takePhoto(BuildContext context) async {
    final photo = await MediaPickerService.takePhoto(
      context: context,
      onInvalidFile: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      },
      allowedExtensions: [...IMAGES_ALLOWED, 'gif'], 
      maxSizeInBytes: MAX_IMAGE_SIZE,
    );

    if (photo != null) {
      onImageSelected(photo);
    }
  }

  Future<void> _pickGifFromMediaPicker(BuildContext context) async {
    final GifModel? gif = await MediaPickerService.pickGifFromTenor(context: context);

    if (gif != null) {
      context.read<CreatePostBloc>().add(PostGifChanged(gif));
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
            IconButton(
              icon: const Icon(Icons.gif_box_outlined),
              onPressed: () => _pickGifFromMediaPicker(context),
            ),
            const Spacer(),
            BlocBuilder<CreatePostBloc, CreatePostState>(
              builder: (context, state) {
                final textLength = state.text.runes.length;
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