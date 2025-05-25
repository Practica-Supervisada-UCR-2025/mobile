import 'gif_model.dart';

class TrendingGifResponse {
  final List<GifModel> gifs;
  final String? next;

  TrendingGifResponse({required this.gifs, this.next});
}
