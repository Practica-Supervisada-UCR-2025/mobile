import 'dart:convert';
import 'package:mobile/core/core.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/src/profile/profile.dart';

class ProfileRepositoryAPI implements ProfileRepository {
  final http.Client client;

  ProfileRepositoryAPI({http.Client? client})
    : client = client ?? http.Client();

  @override
  Future<User> getCurrentUser(String token) async {
    try {
      final response = await client.get(
        Uri.parse('$API_BASE_URL/user/auth/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return User.fromJson(data);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to load user');
      }
    } catch (e) {
      throw Exception('Error getting user profile: $e');
    }
  }

  @override
  Future<User> getUserProfile(String userId, String? token) async {
    final uri = Uri.parse('$API_BASE_URL' 'user/profile/$userId');
    try {
        final headers = <String, String>{
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
      final response = await client.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return User.fromJson(data);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to load user');
      }
    } catch (e) {
      throw Exception('Error getting user profile: $e');
    }
  }
}
