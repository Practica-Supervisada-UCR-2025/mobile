import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/src/comments/comments.dart';
import 'package:mobile/src/shared/models/gif_model.dart';

class CommentInput extends StatefulWidget {
  const CommentInput({super.key});

  @override
  State<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  final _textController = TextEditingController();
  File? _selectedImage;
  GifModel? _selectedGif;

  void _onImageSelected(File? image) {
    setState(() {
      _selectedImage = image;
    });
    context.read<CommentsCreateBloc>().add(CommentImageChanged(image));
  }

  void _onRemoveImage() {
    setState(() {
      _selectedImage = null;
    });
    context.read<CommentsCreateBloc>().add(const CommentImageChanged(null));
  }

  void _onRemoveGif() {
    setState(() {
      _selectedGif = null;
    });
    context.read<CommentsCreateBloc>().add(const CommentGifChanged(null));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_selectedImage != null || _selectedGif != null)
          CommentImage(
            image: _selectedImage,
            gifData: _selectedGif,
            onRemove: () {
              if (_selectedImage != null) {
                _onRemoveImage();
              } else if (_selectedGif != null) {
                _onRemoveGif();
              }
            },
          ),
        CommentTextField(textController: _textController),
        CommentBottomBar(onImageSelected: _onImageSelected),
      ],
    );
  }
}
