import 'dart:io';
import '../models/comments_response.dart';
import 'package:mobile/src/shared/models/gif_model.dart';

abstract class CommentsRepository {
  Future<CommentsResponse> fetchComments({
    required String postId,
    required DateTime startTime,
    int? limit,
    int? index,
  });

  Future<void> sendComment({
    required String postId,
    String? text,
    File? image,
    GifModel? selectedGif,
  });
}
