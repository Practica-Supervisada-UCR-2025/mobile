import 'package:flutter/material.dart';

abstract class PermissionsRepository {
  Future<bool> checkCameraPermission({BuildContext? context});
  Future<bool> checkGalleryPermission({BuildContext? context});
  Future<bool> checkNotificationPermission({
    BuildContext? context,
    showDialogIfDenied,
  });

  Future<void> openSettings();
}
