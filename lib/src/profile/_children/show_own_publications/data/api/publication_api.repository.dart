import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/src/profile/profile.dart';

class PublicationRepositoryAPI implements PublicationRepository {
  final http.Client client;
  //final _baseUrl = 'http://localhost:3000/api/posts/mine';

  PublicationRepositoryAPI({http.Client? client}) : client = client ?? http.Client();

  @override
  Future<List<Publication>> fetchPublications({int limit = 14}) async {
    final response = await client.get(Uri.parse('https://dummyjson.com/posts?limit=$limit'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final posts = data['posts'] as List;

      return posts.map((json) => Publication.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }

  // @override
  // Future<List<Publication>> fetchPublications(int page, int limit) async {
  //   final token = LocalStorage().accessToken;
  //   final response = await http.get(
  //     Uri.parse('$_baseUrl?page=$page&limit=$limit'),
  //     headers: {
  //       'Authorization': 'Bearer $token',
  //       'Content-Type': 'application/json',
  //     },
  //   );

  //   if (response.statusCode == 200) {
  //     final data = json.decode(response.body);
  //     final posts = data['posts'] as List;

  //     return posts.map((json) => Publication.fromJson(json)).toList();
  //   } else {
  //     throw Exception('Failed to load publications');
  //   }
  // }
}