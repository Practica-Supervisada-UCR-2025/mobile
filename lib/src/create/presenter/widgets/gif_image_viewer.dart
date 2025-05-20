import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class GifImageViewer extends StatefulWidget {
  final File imageFile;
  final BoxFit fit;
  
  const GifImageViewer({
    super.key,
    required this.imageFile,
    this.fit = BoxFit.cover,
  });

  @override
  State<GifImageViewer> createState() => _GifImageViewerState();
}

class _GifImageViewerState extends State<GifImageViewer> {
  late Future<Uint8List> _imageBytesFuture;
  Uint8List? _cachedImageBytes;
  
  @override
  void initState() {
    super.initState();
    _loadGifBytes();
  }
  
  @override
  void didUpdateWidget(GifImageViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imageFile.path != oldWidget.imageFile.path) {
      _loadGifBytes();
      _cachedImageBytes = null;
    }
  }
  
  void _loadGifBytes() {
    _imageBytesFuture = widget.imageFile.readAsBytes();
  }
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      key: ValueKey<String>(widget.imageFile.path),
      future: _imageBytesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Could not load image'));
        } else if (snapshot.hasData) {
          _cachedImageBytes ??= snapshot.data!;
          
          return Image.memory(
            _cachedImageBytes!,
            fit: widget.fit,
            gaplessPlayback: true,
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
