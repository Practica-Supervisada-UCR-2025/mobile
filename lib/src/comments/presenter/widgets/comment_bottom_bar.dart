import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/core.dart';
import 'package:mobile/src/comments/comments.dart';
import 'package:mobile/src/shared/models/gif_model.dart';

class CommentBottomBar extends StatefulWidget {
  final Function(File?) onImageSelected;
  final Function(GifModel?)? onGifSelected;
  final VoidCallback? onGifPickerOpened;

  const CommentBottomBar({
    super.key, 
    required this.onImageSelected,
    this.onGifSelected,
    this.onGifPickerOpened,
  });

  @override
  State<CommentBottomBar> createState() => _CommentBottomBarState();
}

class _CommentBottomBarState extends State<CommentBottomBar> {
  Future<void> _pickImageFromGallery() async {
    final image = await MediaPickerService.pickImageFromGallery(
      context: context,
      onInvalidFile: (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      },
      allowedExtensions: [...IMAGES_ALLOWED, 'gif'],
      maxSizeInBytes: MAX_IMAGE_SIZE,
    );

    if (!mounted) return;
    if (image != null) {
      widget.onImageSelected(image);
    }
  }

  Future<void> _takePhoto() async {
    final photo = await MediaPickerService.takePhoto(
      context: context,
      onInvalidFile: (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      },
      allowedExtensions: [...IMAGES_ALLOWED, 'gif'],
      maxSizeInBytes: MAX_IMAGE_SIZE,
    );

    if (!mounted) return;
    if (photo != null) {
      widget.onImageSelected(photo);
    }
  }

  Future<void> _pickGifFromMediaPicker() async {
    widget.onGifPickerOpened?.call();
    
    final GifModel? gif = await MediaPickerService.pickGifFromTenor(context: context);

    if (!mounted) return;
    
    if (gif != null) {
      if (widget.onGifSelected != null) {
        widget.onGifSelected!(gif);
      } else {
        context.read<CommentsCreateBloc>().add(CommentGifChanged(gif));
      }
    } else {
      if (widget.onGifSelected != null) {
        widget.onGifSelected!(null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
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
            BlocBuilder<CommentsCreateBloc, CommentsCreateState>(
              builder: (context, state) {
                final textLength = state is CommentTextChanged ? state.text.runes.length : 0;
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
