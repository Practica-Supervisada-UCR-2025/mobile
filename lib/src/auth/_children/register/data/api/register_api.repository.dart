import 'dart:convert';
import 'package:mobile/core/core.dart';
import 'package:mobile/src/auth/auth.dart';

class RegisterAPIRepository {
  final ApiService apiService;

  RegisterAPIRepository({required this.apiService});

  Future<void> sendUserToBackend(AuthUserInfo user) async {
    try {
      final response = await apiService.post(
        '/user/auth/register',
        body: {
          'email': user.email,
          'full_name': user.name,
          'auth_id': user.id,
          'auth_token': user.authProviderToken,
        },
        authenticated: false,
      );

      if (response.statusCode == 201) return;

      final data = jsonDecode(response.body);
      final message = data['message'] ?? 'Registration failed';
      final details = (data['details'] as List?)?.join(', ');

      throw AuthException('$message${details != null ? ': $details' : ''}');
    } catch (e) {
      if (e.toString().contains('Unauthorized')) {
        throw AuthException('Unauthorized: Invalid or missing auth token');
      }
      throw AuthException('Unexpected error: $e');
    }
  }
}
