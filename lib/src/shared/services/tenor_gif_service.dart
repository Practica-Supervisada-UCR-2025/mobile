import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/trending_response.dart';
import '../models/gif_model.dart';

class TenorGifService {
  final String _baseUrl = 'https://tenor.googleapis.com/v2';
  final String _apiKey = dotenv.env['TENOR_API_KEY'] ?? '';
  final String _clientKey = 'ucr_conect';

  Future<List<GifModel>> searchGifs(String query, {int limit = 20, int pos = 0}) async {
    final response = await http.get(Uri.parse(
      '$_baseUrl/search?q=$query&key=$_apiKey&client_key=$_clientKey'
      '&limit=$limit&pos=$pos&media_filter=tinygif',
    ));

    print('RESPONSE: ${response.body}');

    if (response.statusCode == 200) {
      final List results = json.decode(response.body)['results'];
      return results.map((e) => GifModel.fromJson(e)).toList();
    } else {
      print('Failed to load GIFs. Status code: ${response.statusCode}');
      print('Body: ${response.body}');
      throw Exception('Failed to load GIFs');
    }
  }

  Future<TrendingGifResponse> getTrendingGifs({int limit = 20, String? pos}) async {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/featured?key=$_apiKey&client_key=$_clientKey'
        '&limit=$limit${pos != null ? '&pos=$pos' : ''}&media_filter=tinygif',
      ),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List results = decoded['results'];
      final next = decoded['next'];

      final gifs = results.map((e) => GifModel.fromJson(e)).toList();
      return TrendingGifResponse(gifs: gifs, next: next);
    } else {
      print('Failed to load trending GIFs. Status code: ${response.statusCode}');
      print('Body: ${response.body}');
      throw Exception('Failed to load trending GIFs');
    }
  }
}