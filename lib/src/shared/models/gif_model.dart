class GifModel {
  final String id;
  final String tinyGifUrl;

  GifModel({
    required this.id,
    required this.tinyGifUrl,
  });

  factory GifModel.fromJson(Map<String, dynamic> json) {
    return GifModel(
      id: json['id'],
      tinyGifUrl: json['media_formats']['tinygif']['url'],
    );
  }
}
