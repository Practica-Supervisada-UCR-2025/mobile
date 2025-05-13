import 'dart:math';

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
      username: 'User #${json['userId']}', 
      profileImageUrl: 'https://i.pravatar.cc/150?u=${json['userId']}', 
      content: json['body'],
      createdAt: DateTime.now().subtract(Duration(days: json['id'])), 
      attachment: json['id'] % 2 == 0 
          ? 'https://picsum.photos/400/300'
          : null,
      likes: Random().nextInt(251),
      comments: Random().nextInt(51),
    );
  }

  // factory Publication.fromJson(Map<String, dynamic> json) {
  //   return Publication(
  //     id: json['id'],
  //     username: json['username'] ?? 'Unknown',
  //     profileImageUrl: json['userProfileImage'] ?? 'https://placekitten.com/200/200',
  //     content: json['content'] ?? '',
  //     attachment: json['file_url'],
  //     createdAt: DateTime.parse(json['created_at']),
  //   );
  // }
}
