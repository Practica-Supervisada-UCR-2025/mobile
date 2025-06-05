import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/core/core.dart';
import 'package:mobile/src/create/presenter/widgets/gif_picker_bottom_sheet.dart';
import 'package:mobile/src/shared/models/gif_model.dart';
import 'package:mobile/src/shared/services/tenor_gif_service.dart';

class MediaPickerRepositoryImpl implements MediaPickerRepository {
  final ImagePicker _imagePicker;

  MediaPickerRepositoryImpl({ImagePicker? imagePicker})
    : _imagePicker = imagePicker ?? ImagePicker();

  @override
  Future<GifModel?> pickGifFromTenor({
    required BuildContext context,
    TenorGifService? gifService,
  }) async {
    return await showModalBottomSheet<GifModel>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (bottomSheetContext) {
        return GifPickerBottomSheet(
          gifService: gifService,
          onGifSelected: (gif) {
            Navigator.of(bottomSheetContext).pop(gif);
          },
        );
      },
    );
  }

  @override
  Future<File?> pickImageFromGallery({
    required BuildContext context,
    required MediaPickerConfig config,
  }) async {
    final permissionsRepo = context.read<PermissionsRepository>();
    final hasPermission = await permissionsRepo.checkGalleryPermission(
      context: context,
    );

    if (hasPermission) {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: null,
      );

      if (image != null) {
        final isValid = await validateFile(file: image, config: config);
        if (isValid) {
          return File(image.path);
        }
      }
    }

    return null;
  }

  @override
  Future<File?> takePhoto({
    required BuildContext context,
    required MediaPickerConfig config,
  }) async {
    final permissionsRepo = context.read<PermissionsRepository>();
    final hasPermission = await permissionsRepo.checkCameraPermission(
      context: context,
    );

    if (hasPermission) {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: config.imageQuality,
      );

      if (image != null) {
        final isValid = await validateFile(file: image, config: config);
        if (isValid) {
          return File(image.path);
        }
      }
    }
    return null;
  }

  @override
  Future<bool> validateFile({
    required XFile file,
    required MediaPickerConfig config,
  }) async {
    final String extension = file.path.split('.').last.toLowerCase();

    if (!config.allowedExtensions.contains(extension)) {
      config.onInvalidFile?.call(
        'File type not allowed. Use ${config.allowedExtensions.join(', ')}.',
      );
      return false;
    }

    final File fileObj = File(file.path);
    final int fileSize = await fileObj.length();

    if (fileSize > config.maxSizeInBytes) {
      config.onInvalidFile?.call(
        'File exceeds the ${config.maxSizeInBytes ~/ (1024 * 1024)}MB limit.',
      );
      return false;
    }

    return true;
  }
}
