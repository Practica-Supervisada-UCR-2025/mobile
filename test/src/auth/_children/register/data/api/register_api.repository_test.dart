import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/core/core.dart';
import 'package:mobile/src/auth/auth.dart';

import 'register_api.repository_test.mocks.dart';

@GenerateMocks([ApiService])
void main() {
  late MockApiService mockApiService;
  late RegisterAPIRepository repository;

  setUp(() {
    mockApiService = MockApiService();
    repository = RegisterAPIRepository(apiService: mockApiService);
  });

  group('RegisterAPIRepository Tests', () {
    const endpoint = '/user/auth/register';

    final user = AuthUserInfo(
      name: 'Test User',
      id: 'abc123',
      email: 'test@example.com',
      authProviderToken: 'token123',
    );

    final requestBody = {
      'email': user.email,
      'full_name': user.name,
      'auth_id': user.id,
      'auth_token': user.authProviderToken,
    };

    test('should send user data to backend successfully', () async {
      when(
        mockApiService.post(endpoint, body: requestBody, authenticated: false),
      ).thenAnswer((_) async => http.Response('', 201));

      await repository.sendUserToBackend(user);

      verify(
        mockApiService.post(endpoint, body: requestBody, authenticated: false),
      ).called(1);
    });

    test(
      'should throw AuthException when backend returns non-201 status',
      () async {
        when(
          mockApiService.post(
            endpoint,
            body: requestBody,
            authenticated: false,
          ),
        ).thenAnswer(
          (_) async => http.Response(
            '{"message": "Registration failed", "details": ["Invalid data"]}',
            400,
          ),
        );

        expect(
          () => repository.sendUserToBackend(user),
          throwsA(
            isA<AuthException>().having(
              (e) => e.message,
              'message',
              'Unexpected error: Registration failed: Invalid data',
            ),
          ),
        );
      },
    );

    test(
      'should throw AuthException when backend response is unauthorized',
      () async {
        when(
          mockApiService.post(
            endpoint,
            body: requestBody,
            authenticated: false,
          ),
        ).thenAnswer((_) async => http.Response('Unauthorized', 401));

        expect(
          () => repository.sendUserToBackend(user),
          throwsA(
            isA<AuthException>().having(
              (e) => e.message,
              'message',
              'Unauthorized: Invalid or missing auth token',
            ),
          ),
        );
      },
    );

    test('should throw AuthException for unexpected errors', () async {
      when(
        mockApiService.post(endpoint, body: requestBody, authenticated: false),
      ).thenThrow(Exception('Unexpected error'));

      expect(
        () => repository.sendUserToBackend(user),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            'Unexpected error: Exception: Unexpected error',
          ),
        ),
      );
    });
  });
}
