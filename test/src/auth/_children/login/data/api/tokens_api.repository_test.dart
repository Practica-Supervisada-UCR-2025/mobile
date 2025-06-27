import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mobile/core/core.dart';
import 'package:mobile/src/auth/auth.dart';

import 'tokens_api.repository_test.mocks.dart';

@GenerateMocks([ApiService])
void main() {
  late MockApiService mockApiService;
  late TokensRepositoryAPI repository;

  setUp(() {
    mockApiService = MockApiService();
    repository = TokensRepositoryAPI(apiService: mockApiService);
  });

  group('TokensRepositoryAPI', () {
    final authProviderToken = 'test-auth-provider-token';
    final endpoint = '/user/auth/login';
    final requestBody = {'auth_token': authProviderToken};

    test('should return AuthTokens when API call is successful', () async {
      final responseData = {
        'access_token': 'test-access-token',
        'refreshToken': 'test-refresh-token',
      };

      when(
        mockApiService.post(endpoint, body: requestBody, authenticated: false),
      ).thenAnswer((_) async => http.Response(jsonEncode(responseData), 200));

      final result = await repository.getTokens(authProviderToken);

      expect(result.accessToken, equals('test-access-token'));
      expect(result.refreshToken, equals('test-refresh-token'));

      verify(
        mockApiService.post(endpoint, body: requestBody, authenticated: false),
      ).called(1);
    });

    test('should handle null refreshToken in successful response', () async {
      final responseData = {'access_token': 'test-access-token'};

      when(
        mockApiService.post(endpoint, body: requestBody, authenticated: false),
      ).thenAnswer((_) async => http.Response(jsonEncode(responseData), 200));

      final result = await repository.getTokens(authProviderToken);

      expect(result.accessToken, equals('test-access-token'));
      expect(result.refreshToken, equals(''));
    });

    test(
      'should throw AuthException when API returns error with message',
      () async {
        final errorResponse = {'message': 'Invalid credentials'};

        when(
          mockApiService.post(
            endpoint,
            body: requestBody,
            authenticated: false,
          ),
        ).thenAnswer(
          (_) async => http.Response(jsonEncode(errorResponse), 401),
        );

        expect(
          () => repository.getTokens(authProviderToken),
          throwsA(
            isA<AuthException>().having(
              (e) => e.message,
              'message',
              'Invalid credentials',
            ),
          ),
        );
      },
    );

    test(
      'should use default error message when API error has no message',
      () async {
        when(
          mockApiService.post(
            endpoint,
            body: requestBody,
            authenticated: false,
          ),
        ).thenAnswer((_) async => http.Response(jsonEncode({}), 500));

        expect(
          () => repository.getTokens(authProviderToken),
          throwsA(
            isA<AuthException>().having(
              (e) => e.message,
              'message',
              'Authentication failed',
            ),
          ),
        );
      },
    );

    test('should handle "Unauthorized" exception', () async {
      when(
        mockApiService.post(endpoint, body: requestBody, authenticated: false),
      ).thenThrow('Unauthorized');

      expect(
        () => repository.getTokens(authProviderToken),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            'Unauthorized access',
          ),
        ),
      );
    });

    test('should handle unexpected exceptions', () async {
      when(
        mockApiService.post(endpoint, body: requestBody, authenticated: false),
      ).thenThrow(Exception('Network error'));

      expect(
        () => repository.getTokens(authProviderToken),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            contains('Unexpected error'),
          ),
        ),
      );
    });
  });
}
