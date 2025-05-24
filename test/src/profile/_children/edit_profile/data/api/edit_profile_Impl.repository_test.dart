import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mobile/core/core.dart';
import 'package:mobile/src/profile/profile.dart';

@GenerateMocks([ApiService, File])
import 'edit_profile_Impl.repository_test.mocks.dart';

void main() {
  group('EditProfileRepositoryImpl', () {
    late EditProfileRepositoryImpl repository;
    late MockApiService mockApiService;

    setUp(() {
      mockApiService = MockApiService();
      repository = EditProfileRepositoryImpl(apiService: mockApiService);
    });

    group('updateUserProfile without profile picture', () {
      test('should return User when update is successful', () async {
        // Arrange
        final updates = {'full_name': 'John Doe', 'email': 'john@example.com'};
        final userJson = {
          'data': {
            'full_name': 'John Doe',
            'username': 'johndoe',
            'email': 'john@example.com',
            'profile_picture': 'https://example.com/image.jpg',
          },
        };
        final response = http.Response(json.encode(userJson), 200);

        when(
          mockApiService.patch('/user/auth/profile', body: updates),
        ).thenAnswer((_) async => response);

        // Act
        final result = await repository.updateUserProfile(updates);

        // Assert
        expect(result, isA<User>());
        expect(result.firstName, 'John');
        expect(result.lastName, 'Doe');
        expect(result.username, 'johndoe');
        expect(result.email, 'john@example.com');
        expect(result.image, 'https://example.com/image.jpg');
        verify(
          mockApiService.patch('/user/auth/profile', body: updates),
        ).called(1);
      });

      test('should throw exception when update fails', () async {
        // Arrange
        final updates = {'full_name': 'John Doe'};
        final response = http.Response('Error', 400);

        when(
          mockApiService.patch('/user/auth/profile', body: updates),
        ).thenAnswer((_) async => response);

        // Act & Assert
        expect(
          () => repository.updateUserProfile(updates),
          throwsA(isA<Exception>()),
        );
        verify(
          mockApiService.patch('/user/auth/profile', body: updates),
        ).called(1);
      });

      test('should throw exception on network error', () async {
        // Arrange
        final updates = {'full_name': 'John Doe'};

        when(
          mockApiService.patch('/user/auth/profile', body: updates),
        ).thenThrow(Exception('Network error'));

        // Act & Assert
        expect(
          () => repository.updateUserProfile(updates),
          throwsA(isA<Exception>()),
        );
        verify(
          mockApiService.patch('/user/auth/profile', body: updates),
        ).called(1);
      });
    });

    group('edge cases', () {
      test('should handle empty updates map', () async {
        // Arrange
        final updates = <String, dynamic>{};
        final userJson = {
          'data': {
            'full_name': 'John Doe',
            'username': 'johndoe',
            'email': 'john@example.com',
            'profile_picture': 'https://example.com/image.jpg',
          },
        };
        final response = http.Response(json.encode(userJson), 200);

        when(
          mockApiService.patch('/user/auth/profile', body: updates),
        ).thenAnswer((_) async => response);

        // Act
        final result = await repository.updateUserProfile(updates);

        // Assert
        expect(result, isA<User>());
        verify(
          mockApiService.patch('/user/auth/profile', body: updates),
        ).called(1);
      });
    });
  });
}
