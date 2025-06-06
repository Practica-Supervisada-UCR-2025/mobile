import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:mobile/src/shared/services/tenor_gif_service.dart';
import 'package:mobile/src/shared/models/gif_model.dart';
import 'package:mobile/src/shared/models/trending_response.dart'; 

import 'tenor_gif_service_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late MockClient mockHttpClient;
  late TenorGifService tenorGifService; 

  const String fakeApiKey = 'FAKE_API_KEY_FOR_TESTS';
  const String clientKey = 'ucr_conect'; 
  const String baseUrl = 'https://tenor.googleapis.com/v2';

  Map<String, dynamic> createSampleGifJson(String id, String tinyGifUrl) {
    return {
      'id': id,
      'content_description': 'A cute gif $id',
      'media_formats': {
        'tinygif': {'url': tinyGifUrl, 'dims': [100, 100], 'size': 12345},
      },
    };
  }

  setUp(() {
    mockHttpClient = MockClient();
    tenorGifService = TenorGifService(client: mockHttpClient, apiKey: fakeApiKey);
  });

  group('TenorGifService Tests', () {
    group('searchGifs', () {
      const String query = 'happy cat';
      const int limit = 5;
      const int pos = 0;

      final searchUri = Uri.parse(
          '$baseUrl/search?q=$query&key=$fakeApiKey&client_key=$clientKey&limit=$limit&pos=$pos&media_filter=tinygif');

      test('returns List<GifModel> on successful search (200 OK)', () async {
        final mockGifListJson = [
          createSampleGifJson('gif1', 'http://example.com/gif1_tiny.gif'),
          createSampleGifJson('gif2', 'http://example.com/gif2_tiny.gif'),
        ];
        final mockResponseBody = json.encode({'results': mockGifListJson, 'next': 'some_next_value_if_applicable'});

        when(mockHttpClient.get(searchUri))
            .thenAnswer((_) async => http.Response(mockResponseBody, 200));

        final result = await tenorGifService.searchGifs(query, limit: limit, pos: pos);

        expect(result, isA<List<GifModel>>());
        expect(result.length, 2);
        expect(result[0].id, 'gif1');
        expect(result[0].tinyGifUrl, 'http://example.com/gif1_tiny.gif');
        verify(mockHttpClient.get(searchUri)).called(1);
      });

      test('throws Exception on search API error (e.g., 401 Unauthorized)', () async {
        when(mockHttpClient.get(searchUri))
            .thenAnswer((_) async => http.Response('{"error": "API key invalid"}', 401));

        expect(
          () => tenorGifService.searchGifs(query, limit: limit, pos: pos),
          throwsA(isA<Exception>().having(
              (e) => e.toString(), 'message', contains('Failed to load GIFs'))),
        );
        verify(mockHttpClient.get(searchUri)).called(1);
      });

      test('throws Exception on search JSON missing "results" key (200 OK but bad structure)', () async {
        final mockResponseBody = json.encode({'data': []}); 
        when(mockHttpClient.get(searchUri))
            .thenAnswer((_) async => http.Response(mockResponseBody, 200));

        expect(
          () => tenorGifService.searchGifs(query, limit: limit, pos: pos),
          throwsA(isA<Exception>().having((e) => e.toString(), 'message',
              contains('Failed to load GIFs: Missing "results" key in JSON or invalid structure'))),
        );
        verify(mockHttpClient.get(searchUri)).called(1); 
      });
    });

    group('getTrendingGifs', () {
      const int limit = 3;
      const String? initialPos = null;
      const String nextPosToken = 'NEXT_TOKEN_123';

      final trendingUriNoPos = Uri.parse(
          '$baseUrl/featured?key=$fakeApiKey&client_key=$clientKey&limit=$limit&media_filter=tinygif');
      final trendingUriWithPos = Uri.parse(
          '$baseUrl/featured?key=$fakeApiKey&client_key=$clientKey&limit=$limit&pos=$nextPosToken&media_filter=tinygif');

      test('returns TrendingGifResponse on successful trending request (200 OK, no initial pos)', () async {
        final mockGifListJson = [
          createSampleGifJson('trend1', 'http://example.com/trend1_tiny.gif'),
        ];
        final mockResponseBody = json.encode({'results': mockGifListJson, 'next': 'some_next_pos'});

        when(mockHttpClient.get(trendingUriNoPos, headers: {'Accept': 'application/json'}))
            .thenAnswer((_) async => http.Response(mockResponseBody, 200));

        final result = await tenorGifService.getTrendingGifs(limit: limit, pos: initialPos);

        expect(result, isA<TrendingGifResponse>());
        expect(result.gifs.length, 1);
        expect(result.gifs[0].id, 'trend1');
        expect(result.next, 'some_next_pos');
        verify(mockHttpClient.get(trendingUriNoPos, headers: {'Accept': 'application/json'})).called(1);
      });

      test('returns TrendingGifResponse on successful trending request (200 OK, with pos)', () async {
        final mockGifListJson = [
          createSampleGifJson('trend2', 'http://example.com/trend2_tiny.gif'),
        ];
        final mockResponseBody = json.encode({'results': mockGifListJson, 'next': 'final_page_pos'});

        when(mockHttpClient.get(trendingUriWithPos, headers: {'Accept': 'application/json'}))
            .thenAnswer((_) async => http.Response(mockResponseBody, 200));
        final result = await tenorGifService.getTrendingGifs(limit: limit, pos: nextPosToken);

        expect(result, isA<TrendingGifResponse>());
        expect(result.gifs.length, 1);
        expect(result.gifs[0].id, 'trend2');
        expect(result.next, 'final_page_pos');
        verify(mockHttpClient.get(trendingUriWithPos, headers: {'Accept': 'application/json'})).called(1);
      });

      test('throws Exception on trending API error (e.g., 500 Server Error)', () async {
        when(mockHttpClient.get(trendingUriNoPos, headers: {'Accept': 'application/json'}))
            .thenAnswer((_) async => http.Response('{"error": "Server meltdown"}', 500));

        expect(
          () => tenorGifService.getTrendingGifs(limit: limit, pos: initialPos),
          throwsA(isA<Exception>().having((e) => e.toString(), 'message',
              contains('Failed to load trending GIFs'))),
        );
        verify(mockHttpClient.get(trendingUriNoPos, headers: {'Accept': 'application/json'})).called(1);
      });

      test('throws Exception on trending JSON parsing error (200 OK but invalid JSON)', () async {
        when(mockHttpClient.get(trendingUriNoPos, headers: {'Accept': 'application/json'}))
            .thenAnswer((_) async => http.Response('This is not JSON at all', 200));

        expect(
          () => tenorGifService.getTrendingGifs(limit: limit, pos: initialPos),
          throwsA(isA<Exception>().having((e) => e.toString(), 'message',
              contains('Failed to load trending GIFs: Invalid JSON format'))),
        );
        verify(mockHttpClient.get(trendingUriNoPos, headers: {'Accept': 'application/json'})).called(1);
      });

      test('throws Exception on trending JSON missing "results" key (200 OK but bad structure)', () async {
        final mockResponseBodyMissingResults = json.encode({'next': 'somePos'});

        when(mockHttpClient.get(trendingUriNoPos, headers: {'Accept': 'application/json'}))
            .thenAnswer((_) async => http.Response(mockResponseBodyMissingResults, 200));

        expect(
          () => tenorGifService.getTrendingGifs(limit: limit, pos: initialPos),
          throwsA(isA<Exception>().having((e) => e.toString(), 'message',
              contains('Failed to load trending GIFs: Missing "results" key in JSON or invalid structure'))),
        );
        verify(mockHttpClient.get(trendingUriNoPos, headers: {'Accept': 'application/json'})).called(1);
      });
    });

    test('TenorGifService (real) constructor uses provided apiKey', () {
        expect(tenorGifService.currentApiKeyForTests, fakeApiKey);
    });
  });
}