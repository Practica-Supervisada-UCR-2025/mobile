import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/core/core.dart';
import 'package:mobile/src/shared/models/gif_model.dart';
import 'package:mobile/src/shared/services/tenor_gif_service.dart';

abstract class MediaPickerRepository {
  Future<GifModel?> pickGifFromTenor({
    required BuildContext context,
    TenorGifService? gifService,
  });

  Future<PickerResult> pickImageFromGallery({
    required BuildContext context,
    required MediaPickerConfig config,
  });

  Future<File?> takePhoto({
    required BuildContext context,
    required MediaPickerConfig config,
  });

  Future<ValidationResult> validateFile({
    required XFile file,
    required MediaPickerConfig config,
  });
}
