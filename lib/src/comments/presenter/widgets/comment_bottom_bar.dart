import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/core.dart';
import 'package:mobile/src/comments/comments.dart';
import 'package:mobile/src/shared/models/gif_model.dart';

class CommentBottomBar extends StatefulWidget {
  final String postId;
  final Function(File?) onImageSelected;
  final Function(GifModel?)? onGifSelected;
  final VoidCallback? onGifPickerOpened;

  const CommentBottomBar({
    super.key,
    required this.postId,
    required this.onImageSelected,
    this.onGifSelected,
    this.onGifPickerOpened,
  });

  @override
  State<CommentBottomBar> createState() => _CommentBottomBarState();
}

class _CommentBottomBarState extends State<CommentBottomBar> {
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
      context.read<CommentsCreateBloc>().add(const CommentGifChanged(null));
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
      context.read<CommentsCreateBloc>().add(const CommentGifChanged(null));
      widget.onImageSelected(photo);
    }
  }

  Future<void> _pickGifFromMediaPicker() async {
    widget.onGifPickerOpened?.call();

    final GifModel? gif = await context
        .read<MediaPickerRepository>()
        .pickGifFromTenor(context: context);

    if (!mounted) return;

    if (gif != null) {
      widget.onImageSelected(null);

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
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 0, top: 0),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
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
                final textLength = state.text.runes.length;
                final isOverLimit = state.isOverLimit;

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
            const SizedBox(width: 16),
            BlocConsumer<CommentsCreateBloc, CommentsCreateState>(
              listener: (context, state) {
                if (state is CommentFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Something went wrong. Please try again.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else if (state is CommentSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Your comment was posted!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              builder: (context, state) {
                final isEnabled = state.isValid;

                final replyButton = TextButton(
                  onPressed: null,
                  style: TextButton.styleFrom(
                    backgroundColor:
                        isEnabled
                            ? AppColors.primary
                            : AppColors.getDisabledPostButtonColor(
                              Theme.of(context).brightness,
                            ),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Reply',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                );

                return LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        Opacity(opacity: 0, child: replyButton),
                        Positioned.fill(
                          child:
                              state is CommentSubmitting
                                  ? const Center(
                                    child: SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.0,
                                      ),
                                    ),
                                  )
                                  : TextButton(
                                    onPressed:
                                        isEnabled
                                            ? () {
                                              final bloc =
                                                  context
                                                      .read<
                                                        CommentsCreateBloc
                                                      >();
                                              bloc.add(
                                                CommentSubmitted(
                                                  postId: widget.postId,
                                                  text: state.text,
                                                  image: state.image,
                                                  selectedGif:
                                                      state.selectedGif,
                                                ),
                                              );
                                            }
                                            : null,
                                    style: TextButton.styleFrom(
                                      backgroundColor:
                                          isEnabled
                                              ? AppColors.primary
                                              : AppColors.getDisabledPostButtonColor(
                                                Theme.of(context).brightness,
                                              ),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      minimumSize: const Size(0, 0),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: const Text(
                                      'Reply',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
