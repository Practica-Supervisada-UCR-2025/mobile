class CommentModel {
  final String id;
  final String content;
  final String username;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.content,
    required this.username,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'],
      content: json['content'],
      username: json['username'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
