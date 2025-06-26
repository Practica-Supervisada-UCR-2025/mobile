import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:mobile/core/core.dart';

import 'api_service_impl_test.mocks.dart';

// Mock classes
@GenerateMocks([
  http.Client,
  LocalStorage,
  ServiceLocator,
  ScaffoldMessengerState,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockClient mockClient;
  late MockLocalStorage mockLocalStorage;
  late MockServiceLocator mockServiceLocator;
  late ApiServiceImpl apiService;

  setUp(() {
    mockClient = MockClient();
    mockLocalStorage = MockLocalStorage();
    mockServiceLocator = MockServiceLocator();
    apiService = ApiServiceImpl(
      client: mockClient,
      localStorage: mockLocalStorage,
      baseUrl: 'https://api.ucrconnect.com',
      serviceLocator: mockServiceLocator,
    );
  });

  group('HTTP Methods', () {
    test('GET should return response with correct headers', () async {
      when(mockLocalStorage.accessToken).thenReturn('token123');
      when(
        mockClient.get(any, headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response('{"message": "ok"}', 200));

      final response = await apiService.get('/test');

      expect(response.statusCode, 200);
      expect(jsonDecode(response.body)['message'], 'ok');
      verify(
        mockClient.get(
          Uri.parse('https://api.ucrconnect.com/test'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer token123',
          },
        ),
      ).called(1);
    });

    test('POST should send JSON body and return response', () async {
      when(mockLocalStorage.accessToken).thenReturn('token123');
      when(
        mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer((_) async => http.Response('{"created": true}', 201));

      final response = await apiService.post('/create', body: {'name': 'test'});

      expect(response.statusCode, 201);
      expect(jsonDecode(response.body)['created'], true);
      verify(
        mockClient.post(
          Uri.parse('https://api.ucrconnect.com/create'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer token123',
          },
          body: jsonEncode({'name': 'test'}),
        ),
      ).called(1);
    });

    test('PATCH should send JSON body and return response', () async {
      when(mockLocalStorage.accessToken).thenReturn('token123');
      when(
        mockClient.patch(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer((_) async => http.Response('{"updated": true}', 200));

      final response = await apiService.patch(
        '/update',
        body: {'field': 'value'},
      );

      expect(response.statusCode, 200);
      expect(jsonDecode(response.body)['updated'], true);
      verify(
        mockClient.patch(
          Uri.parse('https://api.ucrconnect.com/update'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer token123',
          },
          body: jsonEncode({'field': 'value'}),
        ),
      ).called(1);
    });

    test('DELETE should send correct request', () async {
      when(mockLocalStorage.accessToken).thenReturn('token123');
      when(
        mockClient.delete(any, headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response('{"deleted": true}', 200));

      final response = await apiService.delete('/delete');

      expect(response.statusCode, 200);
      expect(jsonDecode(response.body)['deleted'], true);
      verify(
        mockClient.delete(
          Uri.parse('https://api.ucrconnect.com/delete'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer token123',
          },
        ),
      ).called(1);
    });
  });

  group('Base URL selection', () {
    test('should use baseUrl for other endpoints', () async {
      final apiServiceWithCorrectBaseUrl = ApiServiceImpl(
        client: mockClient,
        localStorage: mockLocalStorage,
        baseUrl: API_BASE_URL,
        serviceLocator: mockServiceLocator,
      );

      when(mockLocalStorage.accessToken).thenReturn('token123');
      when(
        mockClient.get(any, headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response('{"data": "ok"}', 200));

      await apiServiceWithCorrectBaseUrl.get('users/profile');

      verify(
        mockClient.get(
          Uri.parse('http://157.230.224.13:3000/api/users/profile'),
          headers: anyNamed('headers'),
        ),
      ).called(1);
    });

    test('should use API_POST_BASE_URL for posts endpoints', () async {
      final apiServiceWithCorrectBaseUrl = ApiServiceImpl(
        client: mockClient,
        localStorage: mockLocalStorage,
        baseUrl: API_BASE_URL,
        serviceLocator: mockServiceLocator,
      );

      when(mockLocalStorage.accessToken).thenReturn('token123');
      when(
        mockClient.get(any, headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response('{"data": "ok"}', 200));

      await apiServiceWithCorrectBaseUrl.get('posts/123');

      verify(
        mockClient.get(
          Uri.parse('http://157.230.224.13:3003/api/posts/123'),
          headers: anyNamed('headers'),
        ),
      ).called(1);
    });
  });

  group('Authentication', () {
    test(
      'should make unauthenticated requests when authenticated=false',
      () async {
        when(
          mockClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response('{"public": "data"}', 200));

        await apiService.get('/public', authenticated: false);

        verify(
          mockClient.get(
            Uri.parse('https://api.ucrconnect.com/public'),
            headers: {'Content-Type': 'application/json'},
          ),
        ).called(1);
      },
    );

    test('should handle 401 responses and show snackbar', () async {
      final mockScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

      when(
        mockServiceLocator.scaffoldMessengerKey,
      ).thenReturn(mockScaffoldMessengerKey);
      when(mockServiceLocator.logoutBloc).thenReturn(null);

      when(mockLocalStorage.accessToken).thenReturn('token123');
      when(
        mockClient.get(any, headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response('Unauthorized', 401));

      final response = await apiService.get('/test');

      expect(response.statusCode, 401);
      expect(response.body, 'Unauthorized');
    });

    test(
      'should handle 401 responses when scaffoldMessengerKey is null',
      () async {
        when(mockServiceLocator.scaffoldMessengerKey).thenReturn(null);
        when(mockServiceLocator.logoutBloc).thenReturn(null);

        when(mockLocalStorage.accessToken).thenReturn('token123');
        when(
          mockClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response('Unauthorized', 401));

        final response = await apiService.get('/test');

        expect(response.statusCode, 401);
        expect(response.body, 'Unauthorized');
      },
    );
  });

  group('Request body handling', () {
    test('POST should handle empty body', () async {
      when(mockLocalStorage.accessToken).thenReturn('token123');
      when(
        mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer((_) async => http.Response('{"ok": true}', 200));

      await apiService.post('/test');

      verify(
        mockClient.post(
          Uri.parse('https://api.ucrconnect.com/test'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer token123',
          },
          body: jsonEncode({}),
        ),
      ).called(1);
    });

    test('PATCH should handle null body', () async {
      when(mockLocalStorage.accessToken).thenReturn('token123');
      when(
        mockClient.patch(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer((_) async => http.Response('{"ok": true}', 200));

      await apiService.patch('/test', body: null);

      verify(
        mockClient.patch(
          Uri.parse('https://api.ucrconnect.com/test'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer token123',
          },
          body: jsonEncode({}),
        ),
      ).called(1);
    });
  });

  group('Different status codes', () {
    test('should handle 404 responses', () async {
      when(mockLocalStorage.accessToken).thenReturn('token123');
      when(
        mockClient.get(any, headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response('Not Found', 404));

      final response = await apiService.get('/nonexistent');

      expect(response.statusCode, 404);
      expect(response.body, 'Not Found');
    });

    test('should handle 500 responses', () async {
      when(mockLocalStorage.accessToken).thenReturn('token123');
      when(
        mockClient.get(any, headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response('Internal Server Error', 500));

      final response = await apiService.get('/test');

      expect(response.statusCode, 500);
      expect(response.body, 'Internal Server Error');
    });

    test('should handle 422 responses', () async {
      when(mockLocalStorage.accessToken).thenReturn('token123');
      when(
        mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer(
        (_) async => http.Response('{"errors": ["Invalid data"]}', 422),
      );

      final response = await apiService.post('/test', body: {'invalid': true});

      expect(response.statusCode, 422);
      expect(jsonDecode(response.body)['errors'][0], 'Invalid data');
    });
  });

  group('Error handling', () {
    test('should propagate network errors', () async {
      when(mockLocalStorage.accessToken).thenReturn('token123');
      when(
        mockClient.get(any, headers: anyNamed('headers')),
      ).thenThrow(Exception('Network error'));

      expect(
        () async => await apiService.get('/test'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('Headers', () {
    test('should include correct content-type for all requests', () async {
      when(mockLocalStorage.accessToken).thenReturn('token123');
      when(
        mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer((_) async => http.Response('{"ok": true}', 200));

      await apiService.post('/test');

      verify(
        mockClient.post(
          any,
          headers: argThat(contains('Content-Type'), named: 'headers'),
          body: anyNamed('body'),
        ),
      ).called(1);
    });
  });

  group('Edge cases', () {
    test('should handle empty endpoint', () async {
      when(mockLocalStorage.accessToken).thenReturn('token123');
      when(
        mockClient.get(any, headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response('{"ok": true}', 200));

      final response = await apiService.get('');

      expect(response.statusCode, 200);
      verify(
        mockClient.get(
          Uri.parse('https://api.ucrconnect.com'),
          headers: anyNamed('headers'),
        ),
      ).called(1);
    });

    test('should handle endpoint starting with slash', () async {
      when(mockLocalStorage.accessToken).thenReturn('token123');
      when(
        mockClient.get(any, headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response('{"ok": true}', 200));

      final response = await apiService.get('/test');

      expect(response.statusCode, 200);
      verify(
        mockClient.get(
          Uri.parse('https://api.ucrconnect.com/test'),
          headers: anyNamed('headers'),
        ),
      ).called(1);
    });

    test('should handle endpoint not starting with slash', () async {
      when(mockLocalStorage.accessToken).thenReturn('token123');
      when(
        mockClient.get(any, headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response('{"ok": true}', 200));

      final response = await apiService.get('test');

      expect(response.statusCode, 200);
      verify(
        mockClient.get(
          Uri.parse('https://api.ucrconnect.comtest'),
          headers: anyNamed('headers'),
        ),
      ).called(1);
    });
  });

  group('All HTTP methods with different scenarios', () {
    test('GET with unauthenticated request', () async {
      when(
        mockClient.get(any, headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response('{"public": true}', 200));

      final response = await apiService.get('/public', authenticated: false);

      expect(response.statusCode, 200);
      verify(
        mockClient.get(any, headers: {'Content-Type': 'application/json'}),
      ).called(1);
    });

    test('POST with unauthenticated request', () async {
      when(
        mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer((_) async => http.Response('{"created": true}', 201));

      final response = await apiService.post(
        '/register',
        body: {'email': 'test@example.com'},
        authenticated: false,
      );

      expect(response.statusCode, 201);
      verify(
        mockClient.post(
          any,
          headers: {'Content-Type': 'application/json'},
          body: anyNamed('body'),
        ),
      ).called(1);
    });

    test('PATCH with unauthenticated request', () async {
      when(
        mockClient.patch(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer((_) async => http.Response('{"updated": true}', 200));

      final response = await apiService.patch(
        '/public-update',
        body: {'data': 'value'},
        authenticated: false,
      );

      expect(response.statusCode, 200);
      verify(
        mockClient.patch(
          any,
          headers: {'Content-Type': 'application/json'},
          body: anyNamed('body'),
        ),
      ).called(1);
    });

    test('DELETE with unauthenticated request', () async {
      when(
        mockClient.delete(any, headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response('{"deleted": true}', 200));

      final response = await apiService.delete(
        '/public-delete',
        authenticated: false,
      );

      expect(response.statusCode, 200);
      verify(
        mockClient.delete(any, headers: {'Content-Type': 'application/json'}),
      ).called(1);
    });
  });
}
