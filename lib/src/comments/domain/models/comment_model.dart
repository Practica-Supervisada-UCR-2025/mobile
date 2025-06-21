import 'package:equatable/equatable.dart';

class CommentModel extends Equatable {
  final String id;
  final String content;
  final String username;
  final DateTime createdAt;
  final String? profileImageUrl;
  final String? attachmentUrl;

  const CommentModel({
    required this.id,
    required this.content,
    required this.username,
    required this.createdAt,
    this.profileImageUrl,
    this.attachmentUrl,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'],
      content: json['content'],
      username: json['username'],
      createdAt: DateTime.parse(json['created_at']),
      profileImageUrl: json['profile_picture'],
      attachmentUrl: json['file_url'],
    );
  }

  CommentModel copyWith({
    String? id,
    String? content,
    String? username,
    DateTime? createdAt,
    String? profileImageUrl,
    String? attachmentUrl,
  }) {
    return CommentModel(
      id: id ?? this.id,
      content: content ?? this.content,
      username: username ?? this.username,
      createdAt: createdAt ?? this.createdAt,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
    );
  }

  @override
  List<Object?> get props => [
        id,
        content,
        username,
        createdAt,
        profileImageUrl,
        attachmentUrl,
      ];
}
