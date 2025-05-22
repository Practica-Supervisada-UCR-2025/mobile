import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:mobile/core/core.dart';

import 'api_service_impl_test.mocks.dart';

// Mock classes
@GenerateMocks([http.Client, LocalStorage])
void main() {
  late MockClient mockClient;
  late MockLocalStorage mockLocalStorage;
  late ApiServiceImpl apiService;

  setUp(() {
    mockClient = MockClient();
    mockLocalStorage = MockLocalStorage();
    apiService = ApiServiceImpl(
      client: mockClient,
      localStorage: mockLocalStorage,
      baseUrl: 'https://api.ucrconnect.com',
    );
  });

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
  });

  test('DELETE should send correct request', () async {
    when(mockLocalStorage.accessToken).thenReturn('token123');
    when(
      mockClient.delete(any, headers: anyNamed('headers')),
    ).thenAnswer((_) async => http.Response('{"deleted": true}', 200));

    final response = await apiService.delete('/delete');

    expect(response.statusCode, 200);
    expect(jsonDecode(response.body)['deleted'], true);
  });
}
