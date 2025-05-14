import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile/src/profile/profile.dart';

void main() {
  group('PublicationRepositoryAPI', () {
    test('returns list of publications when status code is 200', () async {
      final mockResponse = {
        'posts': [
          {
            'id': 1,
            'title': 'Test Post',
            'body': 'This is a test post',
            'userId': 1,
            'reactions': 5
          },
          {
            'id': 2,
            'title': 'Another Post',
            'body': 'More testing',
            'userId': 2,
            'reactions': 3
          },
        ]
      };

      final mockClient = MockClient((request) async {
        expect(request.url.toString(), contains('https://dummyjson.com/posts?limit=14'));
        return http.Response(jsonEncode(mockResponse), 200);
      });

      final repo = PublicationRepositoryAPI(client: mockClient);
      final publications = await repo.fetchPublications();

      expect(publications, isA<List<Publication>>());
      expect(publications.length, 2);
      expect(publications[0].content, 'This is a test post');
    });

    test('throws exception when status code is not 200', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final repo = PublicationRepositoryAPI(client: mockClient);

      expect(
        () async => await repo.fetchPublications(),
        throwsA(isA<Exception>()),
      );
    });

    test('respects limit parameter', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.toString(), contains('limit=5'));
        return http.Response(jsonEncode({'posts': []}), 200);
      });

      final repo = PublicationRepositoryAPI(client: mockClient);
      await repo.fetchPublications(limit: 5);
    });
  });
}
