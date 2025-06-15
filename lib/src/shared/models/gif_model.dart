import 'package:equatable/equatable.dart';

class GifModel extends Equatable {
  final String id;
  final String tinyGifUrl;
  final int? sizeBytes;

  const GifModel({
    required this.id,
    required this.tinyGifUrl,
    this.sizeBytes,
  });

  factory GifModel.fromJson(Map<String, dynamic> json) {
    return GifModel(
      id: json['id'],
      tinyGifUrl: json['media_formats']['tinygif']['url'],
      sizeBytes: json['media_formats']['tinygif']['size'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, tinyGifUrl, sizeBytes];
}