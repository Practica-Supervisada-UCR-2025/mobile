import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/core/core.dart';

class MediaPickerService {
  static Future<File?> pickImageFromGallery({
    required BuildContext context,
    int imageQuality = 80,
  }) async {
    final permissionsRepo = context.read<PermissionsRepository>();
    bool hasPermission = await permissionsRepo.checkGalleryPermission(
      context: context,
    );

    if (hasPermission) {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: imageQuality,
      );

      if (image != null) {
        return File(image.path);
      }
    }

    return null;
  }

  static Future<File?> takePhoto({
    required BuildContext context,
    int imageQuality = 80,
  }) async {
    final permissionsRepo = context.read<PermissionsRepository>();
    bool hasPermission = await permissionsRepo.checkCameraPermission(
      context: context,
    );

    if (hasPermission) {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: imageQuality,
      );

      if (photo != null) {
        return File(photo.path);
      }
    }

    return null;
  }
}
