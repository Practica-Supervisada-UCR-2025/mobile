import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';

typedef DownloadFunction = void Function({
  required String url,
  Function(String)? onDownloadCompleted,
  Function(String)? onDownloadError,
});

class ImagePreviewScreen extends StatefulWidget {
  final String imageUrl;

  final DownloadFunction? downloadFn;

  const ImagePreviewScreen({
    super.key,
    required this.imageUrl,
    this.downloadFn,
  });

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  bool _isDownloading = false;

  void downloadImage(BuildContext context, String url) {
    setState(() => _isDownloading = true);

    final downloadFunction = widget.downloadFn ?? FileDownloader.downloadFile;

    downloadFunction(
      url: url,
      onDownloadCompleted: (String path) {
        setState(() => _isDownloading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image downloaded')),
        );
      },
      onDownloadError: (String errorMessage) {
        setState(() => _isDownloading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: $errorMessage')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Hero(
              tag: widget.imageUrl,
              child: InteractiveViewer(
                child: Image.network(
                  widget.imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          if (_isDownloading)
            const Positioned.fill(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          Positioned(
            top: 40,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 16,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: const Icon(Icons.download, color: Colors.white),
                onPressed: _isDownloading
                    ? null
                    : () => downloadImage(context, widget.imageUrl),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
