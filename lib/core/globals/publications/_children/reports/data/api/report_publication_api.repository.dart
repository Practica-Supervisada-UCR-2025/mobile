import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/core/constants/constants.dart';
import 'package:mobile/core/storage/storage.dart';
import 'package:mobile/core/globals/publications/publications.dart';

class ReportPublicationRepositoryAPI implements ReportPublicationRepository {
  final http.Client client;
  static const _baseUrl = API_POST_BASE_URL;

  ReportPublicationRepositoryAPI({http.Client? client})
    : client = client ?? http.Client();

  Future<String> _getJwtToken() async {
    return LocalStorage().accessToken;
  }

  @override
  Future<void> reportPublication({
    required String publicationId,
    required String reason,
  }) async {
    final token = await _getJwtToken();
    if (token.isEmpty) {
      throw Exception('No JWT token found');
    }

    final uri = Uri.parse('${_baseUrl}posts/report');
    final body = json.encode({'postID': publicationId, 'reason': reason});

    final response = await client.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    final Map<String, dynamic> responseBody =
        json.decode(response.body) as Map<String, dynamic>;

    switch (response.statusCode) {
      case 201:
        return;

      case 400:
        final message = responseBody['message'] ?? 'Bad request';
        final details = responseBody['details'];
        if (details is List && details.isNotEmpty) {
          throw Exception(details.join(', '));
        } else {
          throw Exception(message);
        }

      case 409:
        throw Exception(responseBody['message'] ?? 'Post already reported');

      case 500:
        throw Exception(responseBody['message'] ?? 'Server error');

      default:
        throw Exception(
          'Unexpected error: ${response.statusCode} ${response.body}',
        );
    }
  }
}
