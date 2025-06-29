import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile/core/constants/constants.dart';
import 'package:mobile/core/storage/storage.dart';
import 'package:mobile/core/globals/publications/publications.dart';
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
      final repo = PublicationRepositoryAPI(
        endpoint: ENDPOINT_OWN_PUBLICATIONS,
      ); // should trigger line 11
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
          },
        ],
        'metadata': {'totalPosts': 1, 'totalPages': 1, 'currentPage': 1},
      };

      repository = PublicationRepositoryAPI(
        endpoint: ENDPOINT_OWN_PUBLICATIONS,
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
        'metadata': {'totalPosts': 0, 'totalPages': 0, 'currentPage': 1},
      };

      repository = PublicationRepositoryAPI(
        endpoint: ENDPOINT_OWN_PUBLICATIONS,
        client: MockClient((request) async {
          return http.Response(jsonEncode(mockResponse), 200);
        }),
      );

      final result = await repository.fetchPublications(page: 1, limit: 10);
      expect(result.publications, isEmpty);
    });

    test('returns default metadata values if metadata is missing', () async {
      final mockResponse = {'data': []};

      repository = PublicationRepositoryAPI(
        endpoint: ENDPOINT_OWN_PUBLICATIONS,
        client: MockClient((request) async {
          return http.Response(jsonEncode(mockResponse), 200);
        }),
      );

      final result = await repository.fetchPublications(page: 3, limit: 10);
      expect(result.currentPage, 3);
    });

    test('throws exception on non-200 response', () async {
      repository = PublicationRepositoryAPI(
        endpoint: ENDPOINT_OWN_PUBLICATIONS,
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

      repository = PublicationRepositoryAPI(
        endpoint: ENDPOINT_OWN_PUBLICATIONS,
      );

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
          },
        ],
        'metadata': {'totalPosts': 1, 'totalPages': 1, 'currentPage': 1},
      };

      repository = PublicationRepositoryAPI(
        endpoint: ENDPOINT_OWN_PUBLICATIONS,
        client: MockClient((request) async {
          return http.Response(jsonEncode(mockResponse), 200);
        }),
      );

      final result = await repository.fetchPublications(page: 1, limit: 10);
      expect(result.publications.first.createdAt, isA<DateTime>());
    });
    test('fetches posts with time filter using "date" parameter', () async {
      final mockResponse = {
        'data': [
          {
            'id': '1',
            'content': 'Post with date filter',
            'created_at': '2024-01-01T12:00:00Z',
          },
        ],
        'metadata': {'totalPosts': 1, 'totalPages': 1, 'currentPage': 1},
      };

      repository = PublicationRepositoryAPI(
        endpoint: ENDPOINT_OWN_PUBLICATIONS,
        client: MockClient((request) async {
          expect(request.url.query.contains('date=2024-01-01'), isTrue);
          return http.Response(jsonEncode(mockResponse), 200);
        }),
      );

      final result = await repository.fetchPublications(
        page: 1,
        limit: 10,
        time: '2024-01-01',
      );

      expect(result.publications.length, 1);
      expect(result.publications.first.content, 'Post with date filter');
    });

    test('parses comment count from _count.comments', () async {
      final mockResponse = {
        'data': [
          {
            'id': '1',
            'content': 'With comments',
            'created_at': '2024-01-01T12:00:00Z',
            '_count': {'comments': 7},
          },
        ],
        'metadata': {'totalPosts': 1, 'totalPages': 1, 'currentPage': 1},
      };

      repository = PublicationRepositoryAPI(
        endpoint: ENDPOINT_OWN_PUBLICATIONS,
        client: MockClient((request) async {
          return http.Response(jsonEncode(mockResponse), 200);
        }),
      );

      final result = await repository.fetchPublications(page: 1, limit: 10);
      expect(result.publications.first.comments, 7);
    });

    test('assigns userId when it is present in the response', () async {
      final mockResponse = {
        'data': [
          {
            'id': '1',
            'content': 'Post with userId',
            'created_at': '2024-01-01T12:00:00Z',
            'user_id': 'user-456',
          },
        ],
        'metadata': {'totalPosts': 1, 'totalPages': 1, 'currentPage': 1},
      };

      repository = PublicationRepositoryAPI(
        endpoint: ENDPOINT_OWN_PUBLICATIONS,
        client: MockClient((request) async {
          return http.Response(jsonEncode(mockResponse), 200);
        }),
      );

      final result = await repository.fetchPublications(page: 1, limit: 10);
      expect(result.publications.first.userId, 'user-456');
    });

    test('uses fallback username if not present in post data', () async {
      final mockResponse = {
        'data': [
          {
            'id': '1',
            'content': 'No username field',
            'created_at': '2024-01-01T12:00:00Z',
          },
        ],
        'metadata': {'totalPosts': 1, 'totalPages': 1, 'currentPage': 1},
      };

      repository = PublicationRepositoryAPI(
        endpoint: ENDPOINT_OWN_PUBLICATIONS,
        client: MockClient((request) async {
          return http.Response(jsonEncode(mockResponse), 200);
        }),
      );

      final result = await repository.fetchPublications(page: 1, limit: 10);

      expect(result.publications.first.username.isNotEmpty, true);
    });
    test('uses fallback profile image if not present in post data', () async {
      final mockResponse = {
        'data': [
          {
            'id': '1',
            'content': 'No profile picture field',
            'created_at': '2024-01-01T12:00:00Z',
          },
        ],
        'metadata': {'totalPosts': 1, 'totalPages': 1, 'currentPage': 1},
      };

      repository = PublicationRepositoryAPI(
        endpoint: ENDPOINT_OWN_PUBLICATIONS,
        client: MockClient((request) async {
          return http.Response(jsonEncode(mockResponse), 200);
        }),
      );

      final result = await repository.fetchPublications(page: 1, limit: 10);

      expect(result.publications.first.profileImageUrl.isNotEmpty, true);
    });
    test('parses comment count from commentCount field directly', () async {
      final mockResponse = {
        'data': [
          {
            'id': '2',
            'content': 'Direct comment count',
            'created_at': '2024-01-01T12:00:00Z',
            'commentCount': 4,
          },
        ],
        'metadata': {'totalPosts': 1, 'totalPages': 1, 'currentPage': 1},
      };

      repository = PublicationRepositoryAPI(
        endpoint: ENDPOINT_OWN_PUBLICATIONS,
        client: MockClient((request) async {
          return http.Response(jsonEncode(mockResponse), 200);
        }),
      );

      final result = await repository.fetchPublications(page: 1, limit: 10);
      expect(result.publications.first.comments, 4);
    });

    test('handles missing metadata keys gracefully', () async {
      final mockResponse = {
        'data': [
          {
            'id': '1',
            'content': 'Post without full metadata',
            'created_at': '2024-01-01T12:00:00Z',
          },
        ],
        'metadata': {},
      };

      repository = PublicationRepositoryAPI(
        endpoint: ENDPOINT_OWN_PUBLICATIONS,
        client: MockClient((request) async {
          return http.Response(jsonEncode(mockResponse), 200);
        }),
      );

      final result = await repository.fetchPublications(page: 5, limit: 10);
      expect(result.totalPosts, 0);
      expect(result.totalPages, 0);
      expect(result.currentPage, 5);
    });
    test(
      'fetches other user\'s post when isOtherUser is true and avoids profile load',
      () async {
        final postResponse = {
          'posts': {
            'data': [
              {
                'id': '1',
                'content': 'Other user post',
                'created_at': '2024-01-01T12:00:00Z',
                'user_id': 'user-123',
                'username': 'OtherUser',
                'profile_picture': 'https://example.com/otheruser.jpg',
                'likes': 2,
                'commentCount': 1,
              },
            ],
          },
          'metadata': {'totalPosts': 1, 'totalPages': 1, 'currentPage': 1},
        };

        final userProfileResponse = {
          'message': 'User profile retrieved successfully',
          'data': {
            'email': 'mock@ucr.ac.cr',
            'username': 'OtherUser',
            'full_name': 'Mock Name',
            'profile_picture': 'https://example.com/otheruser.jpg',
          },
        };

        repository = PublicationRepositoryAPI(
          endpoint: ENDPOINT_OWN_PUBLICATIONS,
          client: MockClient((request) async {
            final url = request.url.toString();

            if (url.contains('/user/profile/')) {
              // Respuesta mock para la llamada al perfil de usuario
              final profileResponse = {
                'message': 'User profile retrieved successfully',
                'data': {
                  'email': 'mock@ucr.ac.cr',
                  'username': 'OtherUser',
                  'full_name': 'Mock Name',
                  'profile_picture': 'https://example.com/otheruser.jpg',
                },
              };
              return http.Response(jsonEncode(profileResponse), 200);
            }

            // Respuesta mock para la llamada de publicaciones
            final postResponse = {
              'posts': {
                'data': [
                  {
                    'id': '1',
                    'content': 'Other user post',
                    'created_at': '2024-01-01T12:00:00Z',
                    'user_id': 'user-123',
                    'username': 'OtherUser',
                    'profile_picture': 'https://example.com/otheruser.jpg',
                    'likes': 2,
                    'commentCount': 1,
                  },
                ],
              },
              'metadata': {'totalPosts': 1, 'totalPages': 1, 'currentPage': 1},
            };
            return http.Response(jsonEncode(postResponse), 200);
          }),
        );

        final result = await repository.fetchPublications(
          page: 1,
          limit: 10,
          time: '2024-01-01',
          isOtherUser: true,
        );

        expect(result.publications.length, 1);
        expect(result.publications.first.id, '1');
        expect(result.publications.first.username, 'OtherUser');
        expect(
          result.publications.first.profileImageUrl,
          'https://example.com/otheruser.jpg',
        );
      },
    );
  });
}
