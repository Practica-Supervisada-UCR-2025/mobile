import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/src/create/create.dart';

class PostImage extends StatefulWidget {
  final File? image;
  final VoidCallback onRemove;

  const PostImage({super.key, required this.image, required this.onRemove});

  @override
  State<PostImage> createState() => _PostImageState();
}

class _PostImageState extends State<PostImage> {
  bool _isGif = false;

  @override
  void initState() {
    super.initState();
    _checkIfGif();
  }

  @override
  void didUpdateWidget(PostImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.image != oldWidget.image && widget.image != null) {
      _checkIfGif();
    }
  }

  void _checkIfGif() {
    final file = widget.image;
    if (file != null) {
      setState(() {
        _isGif = file.path.toLowerCase().endsWith('.gif');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.image == null) return const SizedBox();
    return Stack(
      key: widget.image != null ? ValueKey<String>(widget.image!.path) : null,
      alignment: Alignment.topRight,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: SizedBox(
              height: 300,
              width: double.infinity,
              child: _isGif
                  ? GifImageViewer(
                      key: ValueKey<String>(widget.image!.path),
                      imageFile: widget.image!,
                      fit: BoxFit.cover,
                    )
                  : Image.file(
                      widget.image!,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
        ),
        Positioned(
          top: 12,
          right: 28,
          child: GestureDetector(
            onTap: () {
              widget.onRemove();
              context.read<CreatePostBloc>().add(PostImageChanged(null));
            },
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 12.0),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
