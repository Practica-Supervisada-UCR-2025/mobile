import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:mobile/core/core.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsRepositoryImpl implements PermissionsRepository {
  final DeviceInfoPlugin deviceInfoPlugin;

  PermissionsRepositoryImpl({DeviceInfoPlugin? deviceInfoPlugin})
    : deviceInfoPlugin = deviceInfoPlugin ?? DeviceInfoPlugin();

  @override
  Future<bool> checkCameraPermission({BuildContext? context}) async {
    var status = await Permission.camera.status;
    // verify if the permission is already granted
    if (status.isGranted) {
      return true;
    }

    // If the permission is permanently denied, then we can show a custom dialog
    // to inform the user that they need to go to settings to enable it
    if (status.isPermanentlyDenied) {
      if (context != null && context.mounted) {
        PermissionSettingsDialog.show(context, 'camera');
      }
      return false;
    }

    // If the permission is denied but not permanently, just request it
    if (status.isDenied) {
      status = await Permission.camera.request();
      return status.isGranted;
    }

    return false;
  }

  @override
  Future<bool> checkGalleryPermission({BuildContext? context}) async {
    final androidInfo = await deviceInfoPlugin.androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    if (sdkInt >= 33) {
      var status = await Permission.photos.status;
      if (status.isGranted) return true;

      if (status.isPermanentlyDenied) {
        if (context != null && context.mounted) {
          PermissionSettingsDialog.show(context, 'gallery');
        }
        return false;
      }

      status = await Permission.photos.request();
      return status.isGranted;
    } else {
      var status = await Permission.storage.status;
      if (status.isGranted) return true;

      if (status.isPermanentlyDenied) {
        if (context != null && context.mounted) {
          PermissionSettingsDialog.show(context, 'storage');
        }
        return false;
      }

      status = await Permission.storage.request();
      return status.isGranted;
    }
  }

  @override
  Future<void> openSettings() async {
    await openAppSettings();
  }
}
