import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;

import 'package:mobile/core/core.dart';
import 'package:mobile/src/search/search.dart';

// Generate mocks
@GenerateMocks([ApiService])
import 'search_users_impl_test.mocks.dart';

void main() {
  group('SearchUsersRepositoryImpl', () {
    late SearchUsersRepositoryImpl repository;
    late MockApiService mockApiService;

    setUp(() {
      mockApiService = MockApiService();
      repository = SearchUsersRepositoryImpl(apiService: mockApiService);
    });

    group('searchUsers', () {
      test('should return empty list when name is empty', () async {
        final result = await repository.searchUsers('');

        expect(result, isEmpty);
        verifyNever(
          mockApiService.get(any, authenticated: anyNamed('authenticated')),
        );
      });

      test(
        'should return empty list when name contains only whitespace',
        () async {
          final result = await repository.searchUsers('   ');

          expect(result, isEmpty);
          verifyNever(
            mockApiService.get(any, authenticated: anyNamed('authenticated')),
          );
        },
      );

      test(
        'should return list of users when API returns 200 with data',
        () async {
          const searchName = 'john';
          final mockResponseBody = json.encode({
            'data': [
              {
                'id': '1',
                'username': 'john_doe',
                'user_fullname': 'John Doe',
                'profile_picture': 'https://example.com/john.jpg',
              },
              {
                'id': '2',
                'username': 'jane_doe',
                'user_fullname': 'Jane Doe',
                'profile_picture': 'https://example.com/jane.jpg',
              },
            ],
          });

          final mockResponse = http.Response(mockResponseBody, 200);

          when(
            mockApiService.get(
              '/user/search/?name=${Uri.encodeComponent(searchName)}',
              authenticated: true,
            ),
          ).thenAnswer((_) async => mockResponse);

          final result = await repository.searchUsers(searchName);

          expect(result, hasLength(2));
          expect(result[0].id, '1');
          expect(result[0].username, 'john_doe');
          expect(result[0].userFullname, 'John Doe');
          expect(result[0].profilePicture, 'https://example.com/john.jpg');
          expect(result[1].id, '2');
          expect(result[1].username, 'jane_doe');
          expect(result[1].userFullname, 'Jane Doe');
          expect(result[1].profilePicture, 'https://example.com/jane.jpg');

          verify(
            mockApiService.get(
              '/user/search/?name=${Uri.encodeComponent(searchName)}',
              authenticated: true,
            ),
          ).called(1);
        },
      );

      test(
        'should return empty list when API returns 200 with null data',
        () async {
          const searchName = 'john';
          final mockResponseBody = json.encode({'data': null});
          final mockResponse = http.Response(mockResponseBody, 200);

          when(
            mockApiService.get(
              '/user/search/?name=${Uri.encodeComponent(searchName)}',
              authenticated: true,
            ),
          ).thenAnswer((_) async => mockResponse);

          final result = await repository.searchUsers(searchName);

          expect(result, isEmpty);
        },
      );

      test(
        'should return empty list when API returns 200 with empty data array',
        () async {
          const searchName = 'john';
          final mockResponseBody = json.encode({'data': []});
          final mockResponse = http.Response(mockResponseBody, 200);

          when(
            mockApiService.get(
              '/user/search/?name=${Uri.encodeComponent(searchName)}',
              authenticated: true,
            ),
          ).thenAnswer((_) async => mockResponse);

          final result = await repository.searchUsers(searchName);

          expect(result, isEmpty);
        },
      );

      test('should return empty list when API returns 404', () async {
        const searchName = 'nonexistent';
        final mockResponse = http.Response('Not Found', 404);

        when(
          mockApiService.get(
            '/user/search/?name=${Uri.encodeComponent(searchName)}',
            authenticated: true,
          ),
        ).thenAnswer((_) async => mockResponse);

        final result = await repository.searchUsers(searchName);

        expect(result, isEmpty);
      });

      test(
        'should throw exception when API returns error status code',
        () async {
          const searchName = 'john';
          final mockResponse = http.Response('Internal Server Error', 500);

          when(
            mockApiService.get(
              '/user/search/?name=${Uri.encodeComponent(searchName)}',
              authenticated: true,
            ),
          ).thenAnswer((_) async => mockResponse);

          expect(
            () => repository.searchUsers(searchName),
            throwsA(
              isA<Exception>().having(
                (e) => e.toString(),
                'message',
                contains('Error searching users: 500'),
              ),
            ),
          );
        },
      );

      test(
        'should properly encode special characters in search name',
        () async {
          const searchName = 'john@doe.com';
          final mockResponseBody = json.encode({'data': []});
          final mockResponse = http.Response(mockResponseBody, 200);

          when(
            mockApiService.get(
              '/user/search/?name=${Uri.encodeComponent(searchName)}',
              authenticated: true,
            ),
          ).thenAnswer((_) async => mockResponse);

          await repository.searchUsers(searchName);

          verify(
            mockApiService.get(
              '/user/search/?name=john%40doe.com',
              authenticated: true,
            ),
          ).called(1);
        },
      );

      test('should handle missing fields in user data gracefully', () async {
        const searchName = 'john';
        final mockResponseBody = json.encode({
          'data': [
            {'id': '1', 'username': 'john_doe'},
            {'id': '2'},
          ],
        });

        final mockResponse = http.Response(mockResponseBody, 200);

        when(
          mockApiService.get(
            '/user/search/?name=${Uri.encodeComponent(searchName)}',
            authenticated: true,
          ),
        ).thenAnswer((_) async => mockResponse);

        final result = await repository.searchUsers(searchName);

        expect(result, hasLength(2));
        expect(result[0].id, '1');
        expect(result[0].username, 'john_doe');
        expect(result[0].userFullname, '');
        expect(result[0].profilePicture, '');
        expect(result[1].id, '2');
        expect(result[1].username, '');
        expect(result[1].userFullname, '');
        expect(result[1].profilePicture, '');
      });

      test(
        'should throw exception when API service throws exception',
        () async {
          const searchName = 'john';
          const errorMessage = 'Network error';

          when(
            mockApiService.get(
              '/user/search/?name=${Uri.encodeComponent(searchName)}',
              authenticated: true,
            ),
          ).thenThrow(Exception(errorMessage));

          expect(
            () => repository.searchUsers(searchName),
            throwsA(
              isA<Exception>().having(
                (e) => e.toString(),
                'message',
                contains('Error searching users: Exception: $errorMessage'),
              ),
            ),
          );
        },
      );

      test('should throw exception when JSON decode fails', () async {
        const searchName = 'john';
        const invalidJson = 'invalid json response';
        final mockResponse = http.Response(invalidJson, 200);

        when(
          mockApiService.get(
            '/user/search/?name=${Uri.encodeComponent(searchName)}',
            authenticated: true,
          ),
        ).thenAnswer((_) async => mockResponse);

        expect(
          () => repository.searchUsers(searchName),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Error searching users:'),
            ),
          ),
        );
      });

      test(
        'should trim whitespace from search name before checking if empty',
        () async {
          const searchName = '  john  ';
          final mockResponseBody = json.encode({'data': []});
          final mockResponse = http.Response(mockResponseBody, 200);

          when(
            mockApiService.get(
              '/user/search/?name=${Uri.encodeComponent(searchName)}',
              authenticated: true,
            ),
          ).thenAnswer((_) async => mockResponse);

          final result = await repository.searchUsers(searchName);

          expect(result, isEmpty);
          verify(
            mockApiService.get(
              '/user/search/?name=${Uri.encodeComponent(searchName)}',
              authenticated: true,
            ),
          ).called(1);
        },
      );
    });
  });
}
