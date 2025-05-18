import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/trending_response.dart';
import '../models/gif_model.dart';

class TenorGifService {
  final String _baseUrl = 'https://tenor.googleapis.com/v2';
  final String _internalApiKey;
  final String _clientKey = 'ucr_conect';
  final http.Client _client;

  TenorGifService({http.Client? client, String? apiKey})
      : _client = client ?? http.Client(),
        _internalApiKey = apiKey ?? dotenv.env['TENOR_API_KEY'] ?? '';

  String get currentApiKeyForTests => _internalApiKey;

  Future<List<GifModel>> searchGifs(String query, {int limit = 20, int pos = 0}) async {
    final uri = Uri.parse(
      '$_baseUrl/search?q=$query&key=$_internalApiKey&client_key=$_clientKey'
      '&limit=$limit&pos=$pos&media_filter=tinygif',
    );

    final response = await _client.get(uri);
    log('Tenor Search Response Code: ${response.statusCode}', name: 'TenorGifService');
    log('Tenor Search Response Body: ${response.body}', name: 'TenorGifService');

    if (response.statusCode == 200) {
      final dynamic decodedBody;
      try {
        decodedBody = json.decode(response.body);
      } catch (e, s) {
        log('JSON decoding error in searchGifs: $e\nStacktrace: $s', name: 'TenorGifService');
        throw Exception('Failed to load GIFs: Invalid JSON format');
      }

      if (decodedBody is Map &&
          decodedBody.containsKey('results') &&
          decodedBody['results'] is List) {
        final List results = decodedBody['results'];
        return results.map((e) => GifModel.fromJson(e)).toList();
      } else {
        log('Missing "results" key or invalid structure in searchGifs JSON. Decoded body: $decodedBody', name: 'TenorGifService');
        throw Exception('Failed to load GIFs: Missing "results" key in JSON or invalid structure');
      }
    } else {
      log('Failed to load GIFs. Status code: ${response.statusCode}, Body: ${response.body}', name: 'TenorGifService');
      throw Exception('Failed to load GIFs');
    }
  }

  Future<TrendingGifResponse> getTrendingGifs({int limit = 20, String? pos}) async {
    final uri = Uri.parse(
      '$_baseUrl/featured?key=$_internalApiKey&client_key=$_clientKey'
      '&limit=$limit${pos != null ? '&pos=$pos' : ''}&media_filter=tinygif',
    );

    final response = await _client.get(uri, headers: {'Accept': 'application/json'});
    log('Tenor Trending Response Code: ${response.statusCode}', name: 'TenorGifService');
    log('Tenor Trending Response Body: ${response.body}', name: 'TenorGifService');

    if (response.statusCode == 200) {
      final dynamic decoded;
      try {
        // Paso 1: Intentar decodificar el JSON
        decoded = json.decode(response.body);
      } catch (e, s) {
        // Si json.decode falla, es un error de formato JSON.
        log('JSON decoding error in getTrendingGifs: $e\nStacktrace: $s', name: 'TenorGifService');
        throw Exception('Failed to load trending GIFs: Invalid JSON format');
      }

      // Paso 2: Verificar la estructura del JSON decodificado.
      // No necesitamos un try-catch aquí si las verificaciones son cuidadosas.
      if (decoded is Map) {
        if (decoded.containsKey('results') && decoded['results'] is List) {
          final List results = decoded['results'];
          // Asegurarse de que 'next' se maneje correctamente si no existe o es null.
          final next = decoded.containsKey('next') ? decoded['next']?.toString() : null;
          final gifs = results.map((e) => GifModel.fromJson(e)).toList();
          return TrendingGifResponse(gifs: gifs, next: next);
        } else {
          // El JSON es un mapa, pero no tiene 'results' o 'results' no es una lista.
          log('Missing "results" key or invalid structure in getTrendingGifs JSON. Decoded Map: $decoded', name: 'TenorGifService');
          throw Exception('Failed to load trending GIFs: Missing "results" key in JSON or invalid structure');
        }
      } else {
        // El JSON decodificado no es un mapa en absoluto.
        log('Decoded JSON is not a Map in getTrendingGifs. Actual type: ${decoded.runtimeType}. Value: $decoded', name: 'TenorGifService');
        throw Exception('Failed to load trending GIFs: JSON structure is not a Map'); // Podrías usar el mensaje de "invalid structure" también.
      }
    } else {
      log('Failed to load trending GIFs. Status code: ${response.statusCode}, Body: ${response.body}', name: 'TenorGifService');
      throw Exception('Failed to load trending GIFs');
    }
  }
}