import 'dart:convert';
import 'package:mobile/src/comments/comments.dart';
import 'package:mobile/core/services/api_service/domain/repository/api_service.dart';

class CommentsRepositoryImpl implements CommentsRepository {
  final ApiService apiService;

  CommentsRepositoryImpl({required this.apiService});

  @override
  Future<CommentsResponse> fetchComments({
    required String postId,
    required DateTime startTime,
  }) async {
    final endpoint = '/api/posts/$postId/comments?startTime=${startTime.toUtc().toIso8601String()}';

    final response = await apiService.get(endpoint);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return CommentsResponse.fromJson(data);
    } else {
      throw Exception("Error loading comments");
    }
  }
}
