import 'dart:convert';

import 'package:mobile/core/core.dart';
import 'package:mobile/src/search/search.dart';

class SearchUsersRepositoryImpl implements SearchUsersRepository {
  final ApiService apiService;

  SearchUsersRepositoryImpl({required this.apiService});

  @override
  Future<List<UserModel>> searchUsers(String name) async {
    try {
      if (name.trim().isEmpty) {
        return [];
      }

      final response = await apiService.get(
        '/user/search/?name=${Uri.encodeComponent(name)}',
        authenticated: true,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> usersData = jsonResponse['data'] ?? [];

        return usersData
            .map((userData) => UserModel.fromJson(userData))
            .toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Error searching users: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching users: $e');
    }
  }
}
