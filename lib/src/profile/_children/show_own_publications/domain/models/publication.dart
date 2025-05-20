class Publication {
  final int id;
  final String username;
  final String profileImageUrl;
  final String content;
  final DateTime createdAt;
  final String? attachment; // Solo un adjunto máximo
  final int likes;
  final int comments;

  Publication({
    required this.id,
    required this.username,
    required this.profileImageUrl,
    required this.content,
    required this.createdAt,
    this.attachment,
    required this.likes,
    required this.comments,
  });
}