import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:mobile/core/core.dart';
import 'package:mobile/src/create/create.dart';
import 'package:mobile/src/shared/models/gif_model.dart';

class CreatePostRepositoryImpl implements CreatePostRepository {
  final ApiService apiService;

  CreatePostRepositoryImpl({required this.apiService});

  @override
  Future<void> createPost({
    String? text,
    File? image,
    GifModel? selectedGif,
  }) async {
    final content = text ?? '';
    
    if (image != null) {
      return _createPostWithImage(content, image);
    }

    if (selectedGif != null) {
      return _createPostWithGif(content, selectedGif);
    }

    if (content.isNotEmpty) {
      return _createTextPost(content);
    }

    throw Exception('Cannot create empty post. Provide at least text, image, or gif.');
  }

  Future<void> _createTextPost(String text) async {
    final response = await apiService.post(
      'posts/newPost',
      body: {
        'content': text,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to create post: ${jsonDecode(response.body)['message']}');
    }
  }

  Future<void> _createPostWithImage(String text, File imageFile) async {
    final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
    
    final String mediaTypeValue = mimeType.startsWith('image/gif') ? '1' : '0';

    final file = await http.MultipartFile.fromPath(
      'file',
      imageFile.path,
      contentType: MediaType.parse(mimeType),
    );

    final fields = {
      'content': text.isEmpty ? ' ' : text,
      'mediaType': mediaTypeValue,
    };

    final response = await apiService.postMultipart(
      'posts/newPost',
      fields,
      [file],
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to create post with image: ${jsonDecode(response.body)['message']}');
    }
  }

  Future<void> _createPostWithGif(String text, GifModel gifData) async {
    final response = await apiService.post(
      'posts/newPost',
      body: {
        'content': text.isEmpty ? ' ' : text,
        'mediaType': 2,
        'gifUrl': gifData.tinyGifUrl,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to create post with GIF: ${jsonDecode(response.body)['message']}');
    }
  }
}
