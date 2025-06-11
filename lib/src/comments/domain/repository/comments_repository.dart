import 'package:http/http.dart' as http;
import 'package:mobile/src/comments/domain/models/comments_response.dart';
import 'dart:convert';

class CommentsRepository {
  final http.Client client;

  CommentsRepository({http.Client? client}) : client = client ?? http.Client();

  Future<CommentsResponse> fetchComments({
    required String postId,
    required DateTime startTime,
  }) async {
    final uri = Uri.parse(
      'http://192.168.100.17:3000/api/posts/$postId/comments?startTime=${startTime.toUtc().toIso8601String()}',
    );

    final response = await client.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return CommentsResponse.fromJson(data);
    } else {
      throw Exception("Error loading comments");
    }
  }
}
