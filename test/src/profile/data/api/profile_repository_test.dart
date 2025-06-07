import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/core/constants/constants.dart';
import 'package:mobile/core/storage/user_session.storage.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mobile/src/profile/profile.dart';

@GenerateMocks([http.Client, LocalStorage])
import 'profile_dummy_repository_test.mocks.dart';

class MockFile extends Mock implements File {}

void main() {
  late MockClient mockClient;
  late ProfileRepositoryAPI repository;
  late MockLocalStorage mockLocalStorage;

  setUp(() {
    mockClient = MockClient();
    mockLocalStorage = MockLocalStorage();
    when(mockLocalStorage.userId).thenReturn('1');
    when(mockLocalStorage.accessToken).thenReturn('token');
    when(mockLocalStorage.refreshToken).thenReturn('refreshToken');
    when(mockLocalStorage.username).thenReturn('test');
    repository = ProfileRepositoryAPI(client: mockClient);
  });

  group('ProfileRepositoryAPI', () {
    const token = '1';
    final url = Uri.parse('$API_BASE_URL/user/auth/profile');

    test('should return User when getCurrentUser API call is successful', () async {
      final mockUserData = {
        'message': 'User profile retrieved successfully',
        'data': {
          'email': 'test@ucr.ac.cr',
          'username': 'test',
          'full_name': 'test',
          'profile_picture': 'https://dummyjson.com/icon/emilys/128',
        },
      };

      when(
        mockClient.get(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      ).thenAnswer((_) async => http.Response(jsonEncode(mockUserData), 201));

      final result = await repository.getCurrentUser(token);

      expect(result.email, equals('test@ucr.ac.cr'));
      expect(result.username, equals('test'));
      expect(result.firstName, equals('test'));
      expect(result.image, equals('https://dummyjson.com/icon/emilys/128'));
    });

    test('should throw Exception when getCurrentUser API call fails', () async {
      when(mockClient.get(url)).thenAnswer((_) async => http.Response('Not found', 404));

      expect(() => repository.getCurrentUser(token), throwsException);
    });

    group('getUserProfile', () {
      const userId = '123';
      final userProfileUrl = Uri.parse('$API_BASE_URL/user/$userId');

      test('should return User when getUserProfile API call is successful', () async {
         final mockUserData = {
        'message': 'User profile retrieved successfully',
        'data': {
          'email': 'test@ucr.ac.cr',
          'username': 'test',
          'full_name': 'Test User',
          'profile_picture': 'https://dummyjson.com/icon/emilys/128',
        },
      };

        when(
          mockClient.get(
            userProfileUrl,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          ),
        ).thenAnswer((_) async => http.Response(jsonEncode(mockUserData), 201));

        final result = await repository.getUserProfile(userId, token);

        expect(result.email, equals('test@ucr.ac.cr'));
        expect(result.username, equals('test'));
        expect(result.firstName, equals('Test'));
        expect(result.image, equals('https://dummyjson.com/icon/emilys/128'));
      });

      test('should throw Exception when getUserProfile API call fails with 404', () async {
        final errorResponse = {
          'message': 'User not found',
        };

        when(
          mockClient.get(
            userProfileUrl,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          ),
        ).thenAnswer((_) async => http.Response(jsonEncode(errorResponse), 404));

        expect(
          () => repository.getUserProfile(userId, token),
          throwsA(predicate((e) =>
              e is Exception &&
              e.toString().contains('User not found'))),
        );
      });

      test('should throw Exception when getUserProfile API call throws network error', () async {
        when(
          mockClient.get(
            userProfileUrl,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          ),
        ).thenThrow(SocketException('No Internet connection'));

        expect(
          () => repository.getUserProfile(userId, token),
          throwsA(predicate((e) =>
              e is Exception &&
              e.toString().contains('Error getting user profile'))),
        );
      });
    });
  });
}
