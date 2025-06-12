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
  final _focusNode = FocusNode();
  File? _selectedImage;
  GifModel? _selectedGif;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {});
  }

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
        CommentTextField(
          textController: _textController,
          focusNode: _focusNode,
          selectedImage: _selectedImage,
          selectedGif: _selectedGif,
          onRemove: () {
            _onRemoveImage();
            _onRemoveGif();
          },
        ),
        if (_focusNode.hasFocus)
          CommentBottomBar(
            onImageSelected: _onImageSelected,
          ),
      ],
    );
  }
}
