import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/core/constants/constants.dart';
import 'package:mobile/core/storage/storage.dart';
import 'package:mobile/src/profile/_children/show_own_publications/show_own_publications.dart';

class PublicationRepositoryAPI implements PublicationRepository {
  final http.Client client;
  static const _baseUrl = API_POST_BASE_URL;

  PublicationRepositoryAPI({http.Client? client})
      : client = client ?? http.Client();

 
  Future<String> _getJwtToken() async {
    return LocalStorage().accessToken;
  }

  @override
  Future<PublicationResponse> fetchPublications({
    required int page,
    required int limit,
  }) async {
    
    final token = await _getJwtToken();
    if (token.isEmpty) {
      throw Exception('No JWT token found');
    }

    
    final uri = Uri.parse(
      '${_baseUrl}user/posts/mine?page=$page&limit=$limit',
    );
    final resp = await client.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (resp.statusCode != 200) {
      throw Exception('Failed to load posts: ${resp.statusCode}');
    }

    
    final body = json.decode(resp.body) as Map<String, dynamic>;

    
    final postsJson = <dynamic>[];
    if (body.containsKey('data') && body['data'] is List) {
      postsJson.addAll(body['data'] as List<dynamic>);
    }

    
    final List<Publication> publications = [];

    for (final raw in postsJson) {
      if (raw is Map<String, dynamic>) {
        final String id = raw['id'] is String ? raw['id'] as String : '';
        final String content = raw['content'] is String ? raw['content'] as String : '';
        final String? fileUrl = raw['file_url'] is String ? raw['file_url'] as String : null;
        final String createdAtStr = raw['created_at'] is String ? raw['created_at'] as String : '';
    
        DateTime createdAt;
        try {
          createdAt = DateTime.parse(createdAtStr);
        } catch (_) {
          createdAt = DateTime.now();
        }

        final String? attachment =
            fileUrl != null && fileUrl.isNotEmpty ? fileUrl : null;

        publications.add(
          Publication(
            id: id,
            username: LocalStorage().username.isNotEmpty ? LocalStorage().username : 'User',
            profileImageUrl: LocalStorage().userProfilePicture.isNotEmpty ? LocalStorage().userProfilePicture : DEFAULT_PROFILE_PIC,
            content: content,
            createdAt: createdAt,
            attachment: attachment,
            likes: raw['likes'] is int ? raw['likes'] as int : 0,
            comments: raw['comments'] is int ? raw['comments'] as int : 0,
          ),
        );
      }
    }

    
    final meta = body['metadata'] as Map<String, dynamic>? ?? {};
    final totalPosts = meta['totalPosts'] as int? ?? 0;
    final totalPages = meta['totalPages'] as int? ?? 0;
    final currentPage = meta['currentPage'] as int? ?? page;

    
    return PublicationResponse(
      publications: publications,
      totalPosts: totalPosts,
      totalPages: totalPages,
      currentPage: currentPage,
    );
  }

  @override
  Future<void> deletePublication({
    required String postId,
  }) async {
    final token = await _getJwtToken();
    if (token.isEmpty) {
      throw Exception('No JWT token found');
    }

    final postIdStr = postId.toString();
    final uri = Uri.parse('$_baseUrl/api/user/posts/delete/$postIdStr');
    final request = http.Request('DELETE', uri);
    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });
    final streamedResponse = await client.send(request);
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode != 200) {
      try {
        final body = jsonDecode(response.body);
        final message = body['message'] ?? 'Unknown error.';
        throw Exception('Error ${response.statusCode}: $message');
      } catch (_) {
        throw Exception('Error ${response.statusCode}: Invalid response from the server.');
      }
    }

    final Map<String, dynamic> data = jsonDecode(response.body);

    if (data['status'] != 'success') {
      throw Exception(data['message'] ?? 'The post could not be deleted.');
    }

    if (data['data']?['deleted'] != true) {
      throw Exception('The post was not deleted properly.');
    }
  }

}
