class MediaPickerConfig {
  final List<String> allowedExtensions;
  final int maxSizeInBytes;
  final int imageQuality;
  final void Function(String message)? onInvalidFile;

  const MediaPickerConfig({
    required this.allowedExtensions,
    required this.maxSizeInBytes,
    this.imageQuality = 80,
    this.onInvalidFile,
  });

  MediaPickerConfig copyWith({
    List<String>? allowedExtensions,
    int? maxSizeInBytes,
    int? imageQuality,
    void Function(String message)? onInvalidFile,
  }) {
    return MediaPickerConfig(
      allowedExtensions: allowedExtensions ?? this.allowedExtensions,
      maxSizeInBytes: maxSizeInBytes ?? this.maxSizeInBytes,
      imageQuality: imageQuality ?? this.imageQuality,
      onInvalidFile: onInvalidFile ?? this.onInvalidFile,
    );
  }
}
