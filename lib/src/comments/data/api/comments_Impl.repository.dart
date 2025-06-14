import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:mobile/src/comments/comments.dart';
import 'package:mobile/core/services/api_service/domain/repository/api_service.dart';
import 'package:mobile/src/shared/models/gif_model.dart';

class CommentsRepositoryImpl implements CommentsRepository {
  final ApiService apiService;

  CommentsRepositoryImpl({required this.apiService});

  @override
  Future<CommentsResponse> fetchComments({
    required String postId,
    required DateTime startTime,
  }) async {
    print('[Repository] Consultando comentarios para postId: $postId');
    print('[Repository] startTime: ${startTime.toUtc().toIso8601String()}');
    final endpoint = 'http://192.168.100.77:3000/api/posts/$postId/comments?startTime=${startTime.toUtc().toIso8601String()}';

    final response = await apiService.get(endpoint);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return CommentsResponse.fromJson(data);
    } else {
      return CommentsResponse(comments: [], totalItems: 0, currentIndex: 0);
    }
  }

  @override
  Future<void> sendComment({
    required String postId,
    String? text,
    File? image,
    GifModel? selectedGif,
  }) async {
    final content = text ?? '';
    
    if (image != null) {
      return _sendCommentWithImage(postId, content, image);
    }

    if (selectedGif != null) {
      return _sendCommentWithGif(postId, content, selectedGif);
    }

    if (content.isNotEmpty) {
      return _sendTextComment(postId, content);
    }

    throw CommentsException('Cannot send empty comment. Provide at least text, image, or gif.');
  }

  Future<void> _sendTextComment(String postId, String text) async {
    final response = await apiService.post(
      'posts/newComment',
      body: {
        'content': text,
        'postId': postId,
      },
    );

    if (response.statusCode != 201) {
      String errorMessage;
      try {
        errorMessage = jsonDecode(response.body)['message'];
      } catch (e) {
        errorMessage = 'Unknown error occurred';
      }
      throw CommentsException('Failed to send comment: $errorMessage');
    }
  }

  Future<void> _sendCommentWithImage(String postId, String text, File imageFile) async {
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
      'postId': postId,
    };

    final response = await apiService.postMultipart(
      'posts/newComment',
      fields,
      [file],
    );

    if (response.statusCode != 201) {
      String errorMessage;
      try {
        errorMessage = jsonDecode(response.body)['message'];
      } catch (e) {
        errorMessage = 'Unknown error occurred';
      }
      throw CommentsException('Failed to send comment with image: $errorMessage');
    }
  }

  Future<void> _sendCommentWithGif(String postId, String text, GifModel gifData) async {
    final response = await apiService.post(
      'posts/newComment',
      body: {
        'content': text.isEmpty ? ' ' : text,
        'mediaType': 2,
        'gifUrl': gifData.tinyGifUrl,
        'postId': postId,
      },
    );

    if (response.statusCode != 201) {
      String errorMessage;
      try {
        errorMessage = jsonDecode(response.body)['message'];
      } catch (e) {
        errorMessage = 'Unknown error occurred';
      }
      throw CommentsException('Failed to send comment with GIF: $errorMessage');
    }
  }
}
