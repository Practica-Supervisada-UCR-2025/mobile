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

  factory Publication.fromJson(Map<String, dynamic> json) {
    return Publication(
      id: json['id'],
      username: 'User #${json['userId']}', // Simulación, ya que DummyJSON no devuelve username
      profileImageUrl: 'https://i.pravatar.cc/150?u=${json['userId']}', // Avatar aleatorio
      content: json['body'],
      createdAt: DateTime.now().subtract(Duration(days: json['id'])), // Fecha simulada
      attachment: json['id'] % 2 == 0 // Adjuntos simulados
          ? 'https://picsum.photos/400/300'
          : null,
      likes: 0,
      comments: 0,
    );
  }
}
