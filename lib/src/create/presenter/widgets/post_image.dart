import 'dart:async';
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
  double? _aspectRatio;

  @override
  void initState() {
    super.initState();
    _calculateAspectRatio();
  }

  @override
  void didUpdateWidget(PostImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.image != oldWidget.image && widget.image != null) {
      _calculateAspectRatio();
    }
  }

  Future<void> _calculateAspectRatio() async {
    if (widget.image != null) {
      final imageFile = FileImage(widget.image!);
      final completer = Completer<ImageInfo>();
      imageFile.resolve(const ImageConfiguration()).addListener(
        ImageStreamListener((ImageInfo info, bool _) {
          completer.complete(info);
        }),
      );

      final imageInfo = await completer.future;
      final width = imageInfo.image.width.toDouble();
      final height = imageInfo.image.height.toDouble();

      setState(() {
        _aspectRatio = width / height;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.image == null || _aspectRatio == null) {
      return const SizedBox();
    }

    return Stack(
      alignment: Alignment.topRight,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: AspectRatio(
              aspectRatio: _aspectRatio!,
              child: Image.file(
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