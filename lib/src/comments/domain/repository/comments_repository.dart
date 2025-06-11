import '../models/comments_response.dart';

abstract class CommentsRepository {
  Future<CommentsResponse> fetchComments({
    required String postId,
    required DateTime startTime,
  });
}
