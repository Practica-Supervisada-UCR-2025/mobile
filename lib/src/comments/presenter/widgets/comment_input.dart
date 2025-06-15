import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/src/comments/comments.dart';
import 'package:mobile/src/shared/models/gif_model.dart';

class CommentInput extends StatefulWidget {
  final String postId;
  
  const CommentInput({super.key, required this.postId});

  @override
  State<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  File? _selectedImage;
  GifModel? _selectedGif;
  bool _isSelectingGif = false;

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

  void _onGifSelected(GifModel? gif) {
    setState(() {
      _selectedGif = gif;
      _isSelectingGif = false;
    });
    if (gif != null) {
      context.read<CommentsCreateBloc>().add(CommentGifChanged(gif));
    }
  }

  void _onGifPickerOpened() {
    setState(() {
      _isSelectingGif = true;
    });
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
      _isSelectingGif = false;
    });
    context.read<CommentsCreateBloc>().add(const CommentGifChanged(null));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CommentsCreateBloc, CommentsCreateState>(
      listener: (context, state) {
        if (state.selectedGif != _selectedGif) {
          setState(() {
            _selectedGif = state.selectedGif;
            if (state.selectedGif != null) {
              _isSelectingGif = false;
            }
          });
        }
        
        if (state is CommentSuccess) {
          _textController.clear();
          setState(() {
            _selectedImage = null;
            _selectedGif = null;
            _isSelectingGif = false;
          });
          _focusNode.unfocus();
          
          context.read<CommentsCreateBloc>().add(const CommentReset());
          context.read<CommentsLoadBloc>().add(FetchInitialComments());
        }
      },
      child: Column(
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
          if (_focusNode.hasFocus || _isSelectingGif)
            CommentBottomBar(
              postId: widget.postId,
              onImageSelected: _onImageSelected,
              onGifSelected: _onGifSelected,
              onGifPickerOpened: _onGifPickerOpened,
            ),
        ],
      ),
    );
  }
}
