import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile/core/storage/storage.dart';
import 'package:mobile/src/profile/_children/show_own_publications/show_own_publications.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PublicationRepositoryAPI.fetchPublications', () {
    late PublicationRepositoryAPI repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'accessToken': 'mock-token',
        'username': 'MockUser',
      });
      await LocalStorage.init();
    });

    test('uses default http.Client if none is provided', () {
      final repo = PublicationRepositoryAPI(); // should trigger line 11
      expect(repo, isA<PublicationRepositoryAPI>());
    });

    test('returns list of publications when response is valid', () async {
      final mockResponse = {
        'data': [
          {
            'id': '1',
            'content': 'Test content',
            'created_at': '2024-01-01T12:00:00Z',
            'file_url': 'https://example.com/image.png',
            'likes': 5,
            'comments': 3,
          }
        ],
        'metadata': {
          'totalPosts': 1,
          'totalPages': 1,
          'currentPage': 1,
        },
      };

      repository = PublicationRepositoryAPI(
        client: MockClient((request) async {
          return http.Response(jsonEncode(mockResponse), 200);
        }),
      );

      final result = await repository.fetchPublications(page: 1, limit: 10);

      expect(result.publications.length, 1);
      expect(result.publications.first.id, '1');
      expect(result.totalPosts, 1);
    });

    test('returns empty list if data is empty', () async {
      final mockResponse = {
        'data': [],
        'metadata': {
          'totalPosts': 0,
          'totalPages': 0,
          'currentPage': 1,
        },
      };

      repository = PublicationRepositoryAPI(
        client: MockClient((request) async {
          return http.Response(jsonEncode(mockResponse), 200);
        }),
      );

      final result = await repository.fetchPublications(page: 1, limit: 10);
      expect(result.publications, isEmpty);
    });

    test('returns default metadata values if metadata is missing', () async {
      final mockResponse = {
        'data': [],
      };

      repository = PublicationRepositoryAPI(
        client: MockClient((request) async {
          return http.Response(jsonEncode(mockResponse), 200);
        }),
      );

      final result = await repository.fetchPublications(page: 3, limit: 10);
      expect(result.currentPage, 3);
    });

    test('throws exception on non-200 response', () async {
      repository = PublicationRepositoryAPI(
        client: MockClient((request) async {
          return http.Response('Unauthorized', 401);
        }),
      );

      expect(
        () async => await repository.fetchPublications(page: 1, limit: 10),
        throwsException,
      );
    });

    test('throws exception if token is empty', () async {
      SharedPreferences.setMockInitialValues({
        'accessToken': '',
        'username': 'MockUser',
      });
      await LocalStorage.init();

      repository = PublicationRepositoryAPI();

      await expectLater(
        () async => await repository.fetchPublications(page: 1, limit: 10),
        throwsException,
      );
    });

    test('uses fallback DateTime.now() when created_at is invalid', () async {
      final mockResponse = {
        'data': [
          {
            'id': '1',
            'content': 'Broken date',
            'created_at': 'invalid-date',
            'file_url': '',
            'likes': 0,
            'comments': 0,
          }
        ],
        'metadata': {
          'totalPosts': 1,
          'totalPages': 1,
          'currentPage': 1,
        },
      };

      repository = PublicationRepositoryAPI(
        client: MockClient((request) async {
          return http.Response(jsonEncode(mockResponse), 200);
        }),
      );

      final result = await repository.fetchPublications(page: 1, limit: 10);
      expect(result.publications.first.createdAt, isA<DateTime>());
    });    
  });

  group('PublicationRepositoryAPI.deletePublication', () {
    late PublicationRepositoryAPI repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'accessToken': 'mock-token',
        'username': 'MockUser',
      });
      await LocalStorage.init();
    });

    test('successfully deletes a publication', () async {
      final mockResponse = {
        'status': 'success',
        'data': {'deleted': true},
      };

      repository = PublicationRepositoryAPI(
        client: MockClient((request) async {
          expect(request.method, equals('DELETE'));
          expect(request.url.path, contains('/api/user/posts/delete/42'));
          expect(request.body, isEmpty);
          return http.Response(jsonEncode(mockResponse), 200);
        }),
      );

      await repository.deletePublication(postId: '42');
    });

    test('throws exception if status is not success', () async {
      final mockResponse = {
        'status': 'error',
        'message': 'Post could not be deleted.',
      };

      repository = PublicationRepositoryAPI(
        client: MockClient((request) async {
          return http.Response(jsonEncode(mockResponse), 200);
        }),
      );

      expect(
        () async => await repository.deletePublication(postId: '42'),
        throwsA(predicate((e) =>
            e is Exception && e.toString().contains('Post could not be deleted'))),
      );
    });

    test('throws exception if deleted flag is false', () async {
      final mockResponse = {
        'status': 'success',
        'data': {'deleted': false},
      };

      repository = PublicationRepositoryAPI(
        client: MockClient((request) async {
          return http.Response(jsonEncode(mockResponse), 200);
        }),
      );

      expect(
        () async => await repository.deletePublication(postId: '42'),
        throwsA(predicate((e) =>
            e is Exception &&
            e.toString().contains('The post was not deleted properly'))),
      );
    });

    test('throws exception on non-200 response with message', () async {
      final mockResponse = {
        'message': 'Error 401: Invalid response from the server.',
      };

      repository = PublicationRepositoryAPI(
        client: MockClient((request) async {
          return http.Response(jsonEncode(mockResponse), 401);
        }),
      );

      expect(
        () async => await repository.deletePublication(postId: '42'),
        throwsA(predicate((e) =>
            e is Exception &&
            e.toString().contains('Error 401: Invalid response from the server.'))),
      );
    });

    test('throws generic exception on malformed response body', () async {
      repository = PublicationRepositoryAPI(
        client: MockClient((request) async {
          return http.Response('Not JSON', 500);
        }),
      );

      expect(
        () async => await repository.deletePublication(postId: '42'),
        throwsA(predicate((e) =>
            e is Exception &&
            e.toString().contains('Invalid response from the server'))),
      );
    });

    test('throws exception if token is empty', () async {
      SharedPreferences.setMockInitialValues({
        'accessToken': '',
        'username': 'MockUser',
      });
      await LocalStorage.init();

      repository = PublicationRepositoryAPI();

      expect(
        () async => await repository.deletePublication(postId: '42'),
        throwsA(predicate(
            (e) => e is Exception && e.toString().contains('Error 400: Invalid response from the server.'))),
      );
    });
  });

}
