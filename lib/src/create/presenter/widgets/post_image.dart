import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/globals/widgets/gif_viewer.dart';
import 'package:mobile/src/create/create.dart';

class PostImage extends StatefulWidget {
  final File? image;
  final dynamic gifData;
  final VoidCallback onRemove;

  const PostImage({
    super.key,
    this.image,
    this.gifData,
    required this.onRemove,
  }) : assert(image != null || gifData != null);

  @override
  State<PostImage> createState() => _PostImageState();
}

class _PostImageState extends State<PostImage> {
  bool _isLocalGif = false;

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
        _isLocalGif = file.path.toLowerCase().endsWith('.gif');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.gifData != null) {
      return _buildTenorGif(context);
    }

    if (widget.image != null) {
      return _buildLocalImage(context);
    }

    return const SizedBox();
  }

  Widget _buildLocalImage(BuildContext context) {
    return Stack(
      key: ValueKey<String>(widget.image!.path),
      alignment: Alignment.topRight,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: SizedBox(
              height: 300,
              width: double.infinity,
              child: _isLocalGif
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
        _buildCloseButton(() {
          widget.onRemove();
          context.read<CreatePostBloc>().add(const PostImageChanged(null));
        }),
      ],
    );
  }

  Widget _buildTenorGif(BuildContext context) {
    return Stack(
      key: ValueKey<String>(widget.gifData!.tinyGifUrl),
      alignment: Alignment.topRight,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: SizedBox(
              height: 300,
              width: double.infinity,
              child: _isLocalGif
                  ? GifImageViewer(
                      key: ValueKey<String>(widget.gifData!.tinyGifUrl),
                      imageFile: widget.image!,
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      widget.gifData!.tinyGifUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          alignment: Alignment.center,
                          child: const Icon(Icons.broken_image, color: Colors.grey, size: 50),
                        );
                      },
                    ),
            ),
          ),
        ),
        _buildCloseButton(() {
          widget.onRemove();
          context.read<CreatePostBloc>().add(const PostGifChanged(null));
        }),
      ],
    );
  }

  Widget _buildCloseButton(VoidCallback onTapCallbackFromParent) {
    return Positioned(
      top: 20,
      right: 24,
      child: GestureDetector(
        onTap: onTapCallbackFromParent, 
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(6.0),
          child: const Icon(
            Icons.close,
            color: Colors.white,
            size: 15,
          ),
        ),
      ),
    );
  }
  
}
