import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/core/core.dart';

class MediaPickerService {
  static Future<File?> pickImageFromGallery({
    required BuildContext context,
    void Function(String message)? onInvalidFile,
    required List<String> allowedExtensions,
    required int maxSizeInBytes,
  }) async {
    final permissionsRepo = context.read<PermissionsRepository>();
    bool hasPermission = await permissionsRepo.checkGalleryPermission(
      context: context,
    );

    if (hasPermission) {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: null,
      );

      if (image != null) {
        final isValid = await validateFile(
          file: image,
          onInvalidFile: onInvalidFile ?? (_) {},
          allowedExtensions: allowedExtensions,
          maxSizeInBytes: maxSizeInBytes,
        );

        if (isValid) {
          return File(image.path);
        }
      }
    }

    return null;
  }

  static Future<File?> takePhoto({
    required BuildContext context,
    required void Function(String errorMessage) onInvalidFile,
    int imageQuality = 80,
    required List<String> allowedExtensions,
    required int maxSizeInBytes,
  }) async {
    final permissionsRepo = context.read<PermissionsRepository>();
    final hasPermission = await permissionsRepo.checkCameraPermission(
      context: context,
    );

    if (hasPermission) {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: imageQuality,
      );

      if (image != null) {
        final isValid = await validateFile(
          file: image,
          onInvalidFile: onInvalidFile,
          allowedExtensions: allowedExtensions,
          maxSizeInBytes: maxSizeInBytes,
        );

        if (isValid) {
          return File(image.path);
        }
      }
    }
    return null;
  }

  static Future<bool> validateFile({
    required XFile file,
    required void Function(String message) onInvalidFile,
    required List<String> allowedExtensions,
    required int maxSizeInBytes,
  }) async {
    final String extension = file.path.split('.').last.toLowerCase();

    if (!allowedExtensions.contains(extension)) {
      onInvalidFile(
        'File type not allowed. Use ${allowedExtensions.join(', ')}.',
      );
      return false;
    }

    final File fileObj = File(file.path);
    final int fileSize = await fileObj.length();

    if (fileSize > maxSizeInBytes) {
      onInvalidFile(
        'File exceeds the ${maxSizeInBytes ~/ (1024 * 1024)}MB limit.',
      );
      return false;
    }

    return true;
  }
}
