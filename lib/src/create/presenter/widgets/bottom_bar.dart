import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/core.dart';
import 'package:mobile/src/create/create.dart';
import 'package:mobile/src/shared/models/gif_model.dart';

class BottomBar extends StatefulWidget {
  final Function(File?) onImageSelected;

  const BottomBar({super.key, required this.onImageSelected});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  Future<void> _pickImageFromGallery() async {
    final image = await context
        .read<MediaPickerRepository>()
        .pickImageFromGallery(
          context: context,
          config: MediaPickerConfig(
            allowedExtensions: [...IMAGES_ALLOWED, 'gif'],
            maxSizeInBytes: MAX_IMAGE_SIZE,
            onInvalidFile: (error) {
              if (!mounted) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(error)));
            },
          ),
        );

    if (!mounted) return;
    if (image != null) {
      widget.onImageSelected(image);
    }
  }

  Future<void> _takePhoto() async {
    final photo = await context.read<MediaPickerRepository>().takePhoto(
      context: context,
      config: MediaPickerConfig(
        allowedExtensions: [...IMAGES_ALLOWED, 'gif'],
        maxSizeInBytes: MAX_IMAGE_SIZE,
        onInvalidFile: (error) {
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error)));
        },
      ),
    );

    if (!mounted) return;
    if (photo != null) {
      widget.onImageSelected(photo);
    }
  }

  Future<void> _pickGifFromMediaPicker() async {
    final GifModel? gif = await context
        .read<MediaPickerRepository>()
        .pickGifFromTenor(context: context);

    if (!mounted) return;
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
            top: BorderSide(color: Theme.of(context).dividerColor),
          ),
          boxShadow: [
            BoxShadow(
              color:
                  Theme.of(context).brightness == Brightness.dark
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
              onPressed: _pickImageFromGallery,
            ),
            IconButton(
              icon: const Icon(Icons.camera_alt_outlined),
              onPressed: _takePhoto,
            ),
            IconButton(
              icon: const Icon(Icons.gif_box_outlined),
              onPressed: _pickGifFromMediaPicker,
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
                    color:
                        isOverLimit
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
