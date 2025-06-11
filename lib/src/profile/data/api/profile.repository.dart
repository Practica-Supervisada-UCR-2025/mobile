import 'dart:convert';
import 'package:mobile/core/core.dart';
import 'package:mobile/src/profile/profile.dart';

class ProfileRepositoryAPI implements ProfileRepository {
  final ApiService apiService;

  ProfileRepositoryAPI({required this.apiService});

  @override
  Future<User> getCurrentUser(String token) async {
    try {
      final response = await apiService.get(
        '/user/auth/profile',
        authenticated: true,
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
    try {
        final response = await apiService.get(
          'user/profile/${Uri.encodeComponent(userId)}',
          authenticated: true,
        );

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
