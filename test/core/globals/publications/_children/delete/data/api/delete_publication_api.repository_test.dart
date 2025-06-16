import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile/core/storage/storage.dart';
import 'package:mobile/core/globals/publications/publications.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DeletePublicationRepositoryAPI', () {
    late DeletePublicationRepositoryAPI repository;

    const publicationId = 'post123';

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'accessToken': 'mock-token',
        'username': 'MockUser',
      });
      await LocalStorage.init();
    });

    test('deletePublication succeeds with valid response', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'DELETE');
        expect(request.headers['Authorization'], 'Bearer mock-token');
        expect(request.headers['Content-Type'], 'application/json');
        expect(request.url.toString(), contains(publicationId));

        return http.Response(
          jsonEncode({
            'status': 'success',
            'data': {'deleted': true},
          }),
          200,
        );
      });

      repository = DeletePublicationRepositoryAPI(client: mockClient);

      expect(
        repository.deletePublication(publicationId: publicationId),
        completes,
      );
    });

    test('throws exception if token is missing', () async {
      SharedPreferences.setMockInitialValues({'accessToken': ''});
      await LocalStorage.init();

      repository = DeletePublicationRepositoryAPI(
        client: MockClient((_) async {
          return http.Response('{}', 200);
        }),
      );

      await expectLater(
        repository.deletePublication(publicationId: publicationId),
        throwsA(isA<Exception>()),
      );
    });

    test(
      'throws exception if statusCode is not 200 and response is valid JSON',
      () async {
        final mockClient = MockClient((_) async {
          return http.Response(jsonEncode({'message': 'Not allowed'}), 403);
        });

        repository = DeletePublicationRepositoryAPI(client: mockClient);

        await expectLater(
          repository.deletePublication(publicationId: publicationId),
          throwsA(predicate((e) => e.toString().contains('Error 403'))),
        );
      },
    );

    test(
      'throws exception if statusCode is not 200 and response is invalid JSON',
      () async {
        final mockClient = MockClient((_) async {
          return http.Response('Invalid HTML response', 500);
        });

        repository = DeletePublicationRepositoryAPI(client: mockClient);

        expect(
          () => repository.deletePublication(publicationId: publicationId),
          throwsA(predicate((e) => e.toString().contains('Invalid response'))),
        );
      },
    );

    test('throws exception if response status is not success', () async {
      final mockClient = MockClient((_) async {
        return http.Response(
          jsonEncode({'status': 'error', 'message': 'Deletion failed'}),
          200,
        );
      });

      repository = DeletePublicationRepositoryAPI(client: mockClient);

      expect(
        () => repository.deletePublication(publicationId: publicationId),
        throwsA(predicate((e) => e.toString().contains('Deletion failed'))),
      );
    });

    test('throws exception if deleted is not true', () async {
      final mockClient = MockClient((_) async {
        return http.Response(
          jsonEncode({
            'status': 'success',
            'data': {'deleted': false},
          }),
          200,
        );
      });

      repository = DeletePublicationRepositoryAPI(client: mockClient);

      expect(
        () => repository.deletePublication(publicationId: publicationId),
        throwsA(
          predicate((e) => e.toString().contains('not deleted properly')),
        ),
      );
    });

    test('deletePublication uses JWT token from LocalStorage', () async {
      SharedPreferences.setMockInitialValues({'accessToken': 'jwt-test-token'});

      LocalStorage.resetInstance();
      await LocalStorage.init();

      final mockClient = MockClient((request) async {
        expect(request.headers['Authorization'], 'Bearer jwt-test-token');
        expect(request.method, 'DELETE');

        return http.Response(
          jsonEncode({
            'status': 'success',
            'data': {'deleted': true},
          }),
          200,
        );
      });

      final repository = DeletePublicationRepositoryAPI(client: mockClient);
      await repository.deletePublication(publicationId: 'some-id');
    });
  });
}
