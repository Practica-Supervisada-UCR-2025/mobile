import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/core/storage/storage.dart';
import 'package:mobile/src/profile/_children/show_own_publications/show_own_publications.dart';

class PublicationRepositoryAPI implements PublicationRepository {
  final http.Client client;
  static const _baseUrl = 'http://157.230.224.13:3003';

  PublicationRepositoryAPI({http.Client? client})
      : client = client ?? http.Client();

 
  Future<String> _getJwtToken() async {
    return LocalStorage().accessToken ?? '';
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
      '$_baseUrl/api/user/posts/mine?page=$page&limit=$limit',
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
        // Safely extract each field, providing defaults if faltan
        final int id = raw['id'] is int ? raw['id'] as int : 0;
        final String content = raw['content'] is String ? raw['content'] as String : '';
        final String? fileUrl = raw['file_url'] is String ? raw['file_url'] as String : null;
        final String createdAtStr = raw['created_at'] is String ? raw['created_at'] as String : '';
    
        // Parse DateTime with fallback
        DateTime createdAt;
        try {
          createdAt = DateTime.parse(createdAtStr);
        } catch (_) {
          createdAt = DateTime.now();
        }

        // Decide whether to include an attachment
        final String? attachment =
            fileUrl != null && fileUrl.isNotEmpty ? fileUrl : null;

        publications.add(
          Publication(
            id: id,
            username: LocalStorage().username.isNotEmpty ? LocalStorage().username : 'User',
            profileImageUrl: LocalStorage().userProfilePicture.isNotEmpty ? LocalStorage().userProfilePicture : 'https://i.pinimg.com/736x/7b/8c/d8/7b8cd8b068e4b9f80b4bcf0928d7d499.jpg',
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
}
