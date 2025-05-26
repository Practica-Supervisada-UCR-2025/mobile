class CreatePostException implements Exception {
  final String message;
  CreatePostException(this.message);

  @override
  String toString() => message;
}
