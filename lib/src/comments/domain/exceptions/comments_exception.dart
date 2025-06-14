class CommentsException implements Exception {
  final String message;
  CommentsException(this.message);

  @override
  String toString() => message;
}
