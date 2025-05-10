import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/gif_model.dart'; // lo crearemos abajo

class TenorGifService {
  final String _baseUrl = 'https://tenor.googleapis.com/v2';
  final String _apiKey = 'AIzaSyArCGZttLRT0dmRVv-EBdUHcTzErxojHB0'; // tu API key

  Future<List<GifModel>> searchGifs(String query, {int limit = 20}) async {
    final response = await http.get(Uri.parse(
      '$_baseUrl/search?q=$query&key=$_apiKey&limit=$limit&media_filter=tinygif',
    ));

    if (response.statusCode == 200) {
      final List results = json.decode(response.body)['results'];
      return results.map((e) => GifModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load GIFs');
    }
  }

  Future<List<GifModel>> getTrendingGifs({int limit = 20}) async {
    final response = await http.get(Uri.parse(
      '$_baseUrl/trending?key=$_apiKey&limit=$limit&media_filter=tinygif',
    ));

    if (response.statusCode == 200) {
      final List results = json.decode(response.body)['results'];
      return results.map((e) => GifModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load trending GIFs');
    }
  }
}
