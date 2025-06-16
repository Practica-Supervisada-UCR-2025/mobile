import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/core/constants/constants.dart';
import 'package:mobile/core/storage/storage.dart';
import 'package:mobile/core/globals/publications/publications.dart';

class DeletePublicationRepositoryAPI implements DeletePublicationRepository {
  final http.Client client;
  static const _baseUrl = API_POST_BASE_URL;

  DeletePublicationRepositoryAPI({http.Client? client})
    : client = client ?? http.Client();

  Future<String> _getJwtToken() async {
    return LocalStorage().accessToken;
  }

  @override
  Future<void> deletePublication({required String publicationId}) async {
    final token = await _getJwtToken();
    if (token.isEmpty) {
      throw Exception('No JWT token found');
    }

    final uri = Uri.parse('${_baseUrl}user/posts/delete/$publicationId');
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
        throw Exception(
          'Error ${response.statusCode}: Invalid response from the server.',
        );
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
