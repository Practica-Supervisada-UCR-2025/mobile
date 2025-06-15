import 'comment_model.dart';

class CommentsResponse {
  final List<CommentModel> comments;
  final int totalItems;
  final int currentIndex;

  CommentsResponse({
    required this.comments,
    required this.totalItems,
    required this.currentIndex,
  });

  factory CommentsResponse.fromJson(Map<String, dynamic> json) {
    return CommentsResponse(
      comments: (json['comments'] as List)
          .map((c) => CommentModel.fromJson(c))
          .toList(),
      totalItems: json['metadata']['totalItems'],
      currentIndex: json['metadata']['currentIndex'],
    );
  }
}