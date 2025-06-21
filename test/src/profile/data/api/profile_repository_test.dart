import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/src/profile/data/api/api.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:mobile/core/services/api_service/domain/repository/api_service.dart';
import 'package:mobile/src/profile/domain/models/user.dart';

import 'profile_repository_test.mocks.dart';

@GenerateMocks([ApiService])
void main() {
  late MockApiService mockApiService;
  late ProfileRepositoryAPI repository;

  setUp(() {
    mockApiService = MockApiService();
    repository = ProfileRepositoryAPI(apiService: mockApiService);
  });

  group('getCurrentUser', () {
    const token = 'token';
    const endpoint = '/user/auth/profile';

    test('should return User when API call is successful with status 201', () async {
      final mockResponseData = {
        'message': 'User profile retrieved successfully',
        'data': {
          'email': 'test@ucr.ac.cr',
          'username': 'test',
          'full_name': 'Test User',
          'profile_picture': 'https://dummyjson.com/icon/emilys/128',
        },
      };


      final response = http.Response(jsonEncode(mockResponseData), 201);

      when(mockApiService.get(endpoint, authenticated: true))
          .thenAnswer((_) async => response);

      final result = await repository.getCurrentUser(token);

      expect(result.email, equals('test@ucr.ac.cr'));
      expect(result.username, equals('test'));
      expect(result.firstName, equals('Test'));
      expect(result.image, equals('https://dummyjson.com/icon/emilys/128'));
    });

    test('should throw Exception when API call fails with status != 201', () async {
      final response = http.Response(jsonEncode({'message': 'Unauthorized'}), 401);

      when(mockApiService.get(endpoint, authenticated: true))
          .thenAnswer((_) async => response);

      expect(() => repository.getCurrentUser(token), throwsException);
    });

    test('should throw Exception on network error', () async {
      when(mockApiService.get(endpoint, authenticated: true))
          .thenThrow(const SocketException('No Internet'));

      expect(
        () => repository.getCurrentUser(token),
        throwsA(predicate((e) =>
            e is Exception && e.toString().contains('Error getting user profile'))),
      );
    });
  });

  group('getUserProfile', () {
    const userId = '123';
    const token = 'token';
    final endpoint = 'user/profile/$userId';

    test('should return User when API call is successful with status 200', () async {
      final mockResponseData = {
        'message': 'User profile retrieved successfully',
        'data': {
          'email': 'jane@ucr.ac.cr',
          'username': 'jane',
          'full_name': 'Jane Doe',
          'profile_picture': 'https://dummyjson.com/icon/jane/128',
        },
      };
      
      final response = http.Response(jsonEncode(mockResponseData), 200);

      when(mockApiService.get(endpoint, authenticated: true))
          .thenAnswer((_) async => response);

      final result = await repository.getUserProfile(userId, token);

      expect(result.email, equals('jane@ucr.ac.cr'));
      expect(result.username, equals('jane'));
      expect(result.firstName, equals('Jane'));
      expect(result.image, equals('https://dummyjson.com/icon/jane/128'));
    });

    test('should throw Exception when API call fails with status != 200', () async {
      final response = http.Response(jsonEncode({'message': 'User not found'}), 404);

      when(mockApiService.get(endpoint, authenticated: true))
          .thenAnswer((_) async => response);

      expect(() => repository.getUserProfile(userId, token), throwsException);
    });

    test('should throw Exception on network error', () async {
      when(mockApiService.get(endpoint, authenticated: true))
          .thenThrow(const SocketException('No Internet'));

      expect(
        () => repository.getUserProfile(userId, token),
        throwsA(predicate((e) =>
            e is Exception && e.toString().contains('Error getting user profile'))),
      );
    });
  });
}
