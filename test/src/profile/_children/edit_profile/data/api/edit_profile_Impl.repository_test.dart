import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/core/core.dart';
import 'package:mobile/src/profile/profile.dart';

import 'edit_profile_Impl.repository_test.mocks.dart';

@GenerateMocks([http.Client, http.StreamedResponse])
void main() {
  late MockClient mockClient;
  late EditProfileRepositoryImpl repository;
  late String token;
  late Map<String, dynamic> mockUser;

  setUp(() {
    mockClient = MockClient();
    repository = EditProfileRepositoryImpl(client: mockClient);
    token = 'test_token';

    mockUser = {
      "data": {
        "full_name": "Test User",
        "username": "testuser",
        "email": "test@example.com",
        "profile_picture": "https://example.com/profile.jpg",
      },
    };
  });

  group('EditProfileRepositoryImpl', () {
    test('updateUserProfile - without profile picture - success', () async {
      // Arrange
      final updates = {'name': 'Updated Name', 'bio': 'Updated Bio'};

      final expectedUser = {
        ...mockUser,
        "data": {
          ...mockUser['data'],
          "full_name": "Updated Name",
          "bio": "Updated Bio",
        },
      };

      when(
        mockClient.patch(
          Uri.parse('$API_BASE_URL/user/auth/profile'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode(updates),
        ),
      ).thenAnswer((_) async => http.Response(json.encode(expectedUser), 200));

      // Act
      final result = await repository.updateUserProfile(token, updates);

      // Assert
      expect(result, isA<User>());
      expect(result.firstName, 'Updated');
      expect(result.lastName, 'Name');
      expect(result.email, 'test@example.com');

      verify(
        mockClient.patch(
          Uri.parse('$API_BASE_URL/user/auth/profile'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode(updates),
        ),
      ).called(1);
    });

    test('updateUserProfile - without profile picture - failure', () async {
      // Arrange
      final updates = {'name': 'Updated Name', 'bio': 'Updated Bio'};

      when(
        mockClient.patch(
          Uri.parse('$API_BASE_URL/user/auth/profile'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode(updates),
        ),
      ).thenAnswer((_) async => http.Response('Invalid request', 400));

      // Act & Assert
      expect(
        () => repository.updateUserProfile(token, updates),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Failed to update user profile'),
          ),
        ),
      );
    });
  });
}
