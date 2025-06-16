import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile/core/globals/publications/publications.dart';
import 'package:mobile/core/storage/storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ReportPublicationRepositoryAPI.reportPublication', () {
    late ReportPublicationRepositoryAPI repository;

    const postId = 'abc123';
    const reason = 'Inappropriate content';

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'accessToken': 'mock-token',
        'username': 'MockUser',
      });
      await LocalStorage.init();
    });

    test('uses default http.Client if none is provided', () {
      final repo = ReportPublicationRepositoryAPI();
      expect(repo, isA<ReportPublicationRepositoryAPI>());
    });

    test('completes successfully on HTTP 201 response', () async {
      repository = ReportPublicationRepositoryAPI(
        client: MockClient((request) async {
          expect(request.headers['Authorization'], 'Bearer mock-token');
          expect(request.headers['Content-Type'], contains('application/json'));
          expect(request.method, equals('POST'));
          final body = json.decode(request.body);
          expect(body['postID'], postId);
          expect(body['reason'], reason);

          return http.Response('{}', 201);
        }),
      );

      expect(
        () =>
            repository.reportPublication(publicationId: postId, reason: reason),
        returnsNormally,
      );
    });

    test('throws on missing token', () async {
      SharedPreferences.setMockInitialValues({'accessToken': ''});
      await LocalStorage.init();

      repository = ReportPublicationRepositoryAPI();

      expect(
        () =>
            repository.reportPublication(publicationId: postId, reason: reason),
        throwsException,
      );
    });

    test('throws with detailed error on 400 with details', () async {
      repository = ReportPublicationRepositoryAPI(
        client: MockClient((request) async {
          return http.Response(
            json.encode({
              'message': 'Validation failed',
              'details': ['Invalid reason', 'Missing postID'],
            }),
            400,
          );
        }),
      );

      expect(
        () =>
            repository.reportPublication(publicationId: postId, reason: reason),
        throwsA(
          predicate(
            (e) =>
                e is Exception &&
                e.toString().contains('Invalid reason') &&
                e.toString().contains('Missing postID'),
          ),
        ),
      );
    });

    test('throws with general message on 400 without details', () async {
      repository = ReportPublicationRepositoryAPI(
        client: MockClient((request) async {
          return http.Response(json.encode({'message': 'Bad request'}), 400);
        }),
      );

      expect(
        () =>
            repository.reportPublication(publicationId: postId, reason: reason),
        throwsException,
      );
    });

    test('throws with conflict error message on 409', () async {
      repository = ReportPublicationRepositoryAPI(
        client: MockClient((request) async {
          return http.Response(
            json.encode({'message': 'Post already reported'}),
            409,
          );
        }),
      );

      expect(
        () =>
            repository.reportPublication(publicationId: postId, reason: reason),
        throwsA(
          predicate(
            (e) =>
                e is Exception &&
                e.toString().contains('Post already reported'),
          ),
        ),
      );
    });

    test('throws with server error message on 500', () async {
      repository = ReportPublicationRepositoryAPI(
        client: MockClient((request) async {
          return http.Response(
            json.encode({'message': 'Server error occurred'}),
            500,
          );
        }),
      );

      expect(
        () =>
            repository.reportPublication(publicationId: postId, reason: reason),
        throwsA(
          predicate(
            (e) =>
                e is Exception &&
                e.toString().contains('Server error occurred'),
          ),
        ),
      );
    });

    test('throws with unexpected error on unknown status code', () async {
      repository = ReportPublicationRepositoryAPI(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({'message': 'Unexpected response'}),
            418,
          );
        }),
      );

      expect(
        () =>
            repository.reportPublication(publicationId: postId, reason: reason),
        throwsA(
          predicate(
            (e) =>
                e is Exception &&
                e.toString().contains('Unexpected error: 418'),
          ),
        ),
      );
    });
  });
}
