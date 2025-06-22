import 'dart:convert';

import 'package:mobile/core/core.dart';
import 'package:mobile/src/auth/auth.dart';

class TokensRepositoryAPI implements TokensRepository {
  final ApiService apiService;

  TokensRepositoryAPI({required this.apiService});

  @override
  Future<AuthTokens> getTokens(String authProviderToken) async {
    try {
      final response = await apiService.post(
        '/user/auth/login',
        body: {'auth_token': authProviderToken},
        authenticated: false,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return AuthTokens(
          accessToken: data['access_token'],
          refreshToken: data['refreshToken'] ?? '',
        );
      } else {
        throw AuthException(data['message'] ?? 'Authentication failed');
      }
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }

      if (e.toString().contains('Unauthorized')) {
        throw AuthException('Unauthorized access');
      }

      throw AuthException('Unexpected error');
    }
  }
}
