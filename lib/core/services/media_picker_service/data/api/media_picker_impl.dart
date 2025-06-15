import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/core/core.dart';
import 'package:mobile/core/globals/widgets/gif_picker_bottom_sheet.dart';
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
        imageQuality: config.imageQuality,
      );

      if (image != null) {
        final validationResult = await validateFile(
          file: image,
          config: config,
        );
        if (validationResult.isValid) {
          return File(image.path);
        } else {
          config.onInvalidFile?.call(validationResult.errorMessage!);
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
        final validationResult = await validateFile(
          file: image,
          config: config,
        );
        if (validationResult.isValid) {
          return File(image.path);
        } else {
          config.onInvalidFile?.call(validationResult.errorMessage!);
        }
      }
    }
    return null;
  }

  @override
  Future<ValidationResult> validateFile({
    required XFile file,
    required MediaPickerConfig config,
  }) async {
    final String extension = file.path.split('.').last.toLowerCase();

    if (!config.allowedExtensions.contains(extension)) {
      return ValidationResult(
        isValid: false,
        errorMessage:
            'File type not allowed. Use ${config.allowedExtensions.join(', ')}.',
      );
    }

    final File fileObj = File(file.path);
    final int fileSize = await fileObj.length();

    if (fileSize > config.maxSizeInBytes) {
      return ValidationResult(
        isValid: false,
        errorMessage:
            'File exceeds the ${config.maxSizeInBytes ~/ (1024 * 1024)}MB limit.',
      );
    }

    return ValidationResult(isValid: true);
  }
}
