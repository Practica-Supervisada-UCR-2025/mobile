import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mobile/src/profile/profile.dart';

class ProfileRepositoryAPI implements ProfileRepository {
  final http.Client client;

  ProfileRepositoryAPI({http.Client? client})
    : client = client ?? http.Client();

  @override
  Future<User> getCurrentUser(String token) async {
    final response = await client.get(
      Uri.parse('https://dummyjson.com/users/$token'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return User.fromJson(data);
    } else {
      throw Exception('Failed to load user');
    }
  }

  @override
  Future<User> updateUserProfile(
    String token,
    Map<String, dynamic> updates,
  ) async {
    final response = await client.put(
      Uri.parse('https://dummyjson.com/users/$token'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Optional for dummy API
      },
      body: json.encode(updates),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return User.fromJson(data);
    } else {
      throw Exception('Failed to update user profile');
    }
  }
}
