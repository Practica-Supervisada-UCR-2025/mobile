import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/core/constants/constants.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mobile/src/profile/profile.dart';

@GenerateMocks([http.Client])
import 'profile_dummy_repository_test.mocks.dart';

class MockFile extends Mock implements File {}

void main() {
  late MockClient mockClient;
  late ProfileRepositoryAPI repository;

  setUp(() {
    mockClient = MockClient();
    repository = ProfileRepositoryAPI(client: mockClient);
  });

  group('ProfileRepositoryAPI', () {
    const token = '1';
    final url = Uri.parse('$API_BASE_URL/user/auth/profile');

    test('should return User when API call is successful', () async {
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

    test('should throw Exception when API call fails', () async {
      when(
        mockClient.get(url),
      ).thenAnswer((_) async => http.Response('Not found', 404));

      expect(() => repository.getCurrentUser(token), throwsException);
    });
  });
}
