import 'dart:io';

import 'package:mobile/src/shared/models/gif_model.dart';

abstract class CreatePostRepository {
  Future<void> createPost({
    String? text,
    File? image,
    GifModel? selectedGif,
  });
}
