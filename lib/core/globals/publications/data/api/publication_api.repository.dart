import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/core/constants/constants.dart';
import 'package:mobile/core/storage/storage.dart';
import 'package:mobile/core/globals/publications/publications.dart';

class PublicationRepositoryAPI implements PublicationRepository {
  final http.Client client;
  static const _baseUrl = API_POST_BASE_URL;
  final String endpoint;

  PublicationRepositoryAPI({http.Client? client, required this.endpoint})
    : client = client ?? http.Client();

  Future<String> _getJwtToken() async {
    return LocalStorage().accessToken;
  }

  @override
  Future<PublicationResponse> fetchPublications({
    required int page,
    required int limit,
    String? time,
  }) async {
    final token = await _getJwtToken();
    if (token.isEmpty) {
      throw Exception('No JWT token found');
    }

    late final Uri uri;
    if (time != null && time.isNotEmpty) {
      uri = Uri.parse('$_baseUrl$endpoint?limit=$limit&date=$time');
    }
    else {
      uri = Uri.parse('$_baseUrl$endpoint?page=$page&limit=$limit');
    }
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
    if (time != null && time.isNotEmpty) {
      if (body.containsKey('posts') && body['posts']['data'] is List) {
        postsJson.addAll(body['posts']['data'] as List<dynamic>);
      }
    } else {
      if (body.containsKey('data') && body['data'] is List) {
        postsJson.addAll(body['data'] as List<dynamic>);
      }
    }

    final List<Publication> publications = [];

    for (final raw in postsJson) {
      if (raw is Map<String, dynamic>) {
        final String id = raw['id'] is String ? raw['id'] as String : '';
        final String content =
            raw['content'] is String ? raw['content'] as String : '';
        final String? fileUrl =
            raw['file_url'] is String ? raw['file_url'] as String : null;
        final String createdAtStr =
            raw['created_at'] is String ? raw['created_at'] as String : '';
        final String username =
            raw['username'] is String ? raw['username'] 
            : LocalStorage().username.isNotEmpty
                ? LocalStorage().username
                : 'User';
        final imageUrl =
            raw['profile_picture'] is String ? raw['profile_picture'] 
            : LocalStorage().userProfilePicture.isNotEmpty
                ? LocalStorage().userProfilePicture
                : DEFAULT_PROFILE_PIC;

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
            username: username,
            profileImageUrl: imageUrl,
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
