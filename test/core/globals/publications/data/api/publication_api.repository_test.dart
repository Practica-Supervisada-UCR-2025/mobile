import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/core/globals/publications/data/api/publication_api.repository.dart';
import 'package:mobile/core/storage/user_session.storage.dart';

void main() {
  const MethodChannel preferencesChannel = MethodChannel('plugins.flutter.io/shared_preferences');
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // ignore: deprecated_member_use
    preferencesChannel.setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'getAll') {
        return <String, Object>{
          'accessToken': 'token123',
          'username': 'testuser',
          'userProfilePicture': 'pic://url',
        };
      }
      return null;
    });
    SharedPreferences.setMockInitialValues({
      'accessToken': 'token123',
      'username': 'testuser',
      'userProfilePicture': 'pic://url',
    });
    await LocalStorage.init();
  });

  group('PublicationRepositoryAPI', () {
    test('throws when JWT token is empty', () async {
      SharedPreferences.setMockInitialValues({'accessToken': ''});
      await LocalStorage.init();

      final repo = PublicationRepositoryAPI(endpoint: 'posts');
      expect(
        () => repo.fetchPublications(page: 1, limit: 10),
        throwsA(isA<Exception>()),
      );
    });

    test('throws on non-200 HTTP response', () async {
      final mockClient = MockClient((_) async => http.Response('', 404));
      final repo = PublicationRepositoryAPI(client: mockClient, endpoint: 'posts');

      expect(
        () => repo.fetchPublications(page: 1, limit: 5),
        throwsA(predicate((e) => e.toString().contains('Failed to load posts: 404'))),
      );
    });

    test('parses data list correctly', () async {
      final mockJson = {
        'data': [
          {
            'id': '1',
            'content': 'hello',
            'file_url': null,
            'created_at': '2025-06-15T00:00:00Z',
            'username': 'user1',
            'profile_picture': 'url1',
            'likes': 5,
            'comments': 2,
          }
        ],
        'metadata': {
          'totalPosts': 1,
          'totalPages': 1,
          'currentPage': 1,
        },
      };
      final mockClient = MockClient((_) async => http.Response(jsonEncode(mockJson), 200));
      final repo = PublicationRepositoryAPI(client: mockClient, endpoint: 'posts');

      final resp = await repo.fetchPublications(page: 1, limit: 10);
      expect(resp.publications, hasLength(1));
      final pub = resp.publications.first;
      expect(pub.id, equals('1'));
      expect(pub.content, equals('hello'));
      expect(pub.attachment, isNull);
      expect(pub.likes, equals(5));
      expect(pub.comments, equals(2));

      expect(resp.totalPosts, equals(1));
      expect(resp.totalPages, equals(1));
      expect(resp.currentPage, equals(1));
    });

    test('parses posts array when time filter is provided', () async {
      final timeFilter = '2025-06-14';
      final mockJson = {
        'posts': {
          'data': [
            {
              'id': '2',
              'content': 'hi',
              'file_url': 'fileUrl',
              'created_at': 'invalid-date',
              'likes': 0,
              'comments': 0,
            }
          ]
        },
        'metadata': {},
      };
      final mockClient = MockClient((_) async => http.Response(jsonEncode(mockJson), 200));
      final repo = PublicationRepositoryAPI(client: mockClient, endpoint: 'posts');

      final resp = await repo.fetchPublications(page: 1, limit: 5, time: timeFilter);
      expect(resp.publications, hasLength(1));
      expect(resp.publications.first.id, equals('2'));
    });
  });
}
