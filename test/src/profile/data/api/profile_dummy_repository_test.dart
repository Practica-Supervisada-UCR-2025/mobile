import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mobile/src/profile/profile.dart';

@GenerateMocks([http.Client])
import 'profile_dummy_repository_test.mocks.dart';

void main() {
  late MockClient mockClient;
  late ProfileRepositoryAPI repository;

  setUp(() {
    mockClient = MockClient();
    repository = ProfileRepositoryAPI(client: mockClient);
  });

  group('ProfileRepositoryAPI', () {
    const token = '1'; // este token es el ID del usuario en la API dummy
    final url = Uri.parse('https://dummyjson.com/users/$token');

    test('should return User when API call is successful', () async {
      final mockUserData = {
        'firstName': 'John',
        'lastName': 'Doe',
        'username': 'johndoe',
        'email': 'user@ucr.ac.cr',
        'image': 'https://dummyjson.com/icon/emilys/128',
      };

      when(mockClient.get(url)).thenAnswer(
        (_) async => http.Response(jsonEncode(mockUserData), 200),
      );

      final result = await repository.getCurrentUser(token);

      expect(result.firstName, equals('John'));
      expect(result.lastName, equals('Doe'));
      expect(result.username, equals('johndoe'));
      expect(result.email, equals('user@ucr.ac.cr'));
      expect(result.image, equals('https://dummyjson.com/icon/emilys/128'));
    });

    test('should throw Exception when API call fails', () async {
      when(mockClient.get(url)).thenAnswer(
        (_) async => http.Response('Not found', 404),
      );

      expect(() => repository.getCurrentUser(token), throwsException);
    });
  });
}
