import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:mobile/core/core.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsRepositoryImpl implements PermissionsRepository {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

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
    try {
      final androidInfo = await _deviceInfo.androidInfo;
      final int sdkInt = androidInfo.version.sdkInt;

      // Check if the device is running Android 13 (API level 33) or higher
      // and set the permission type accordingly
      final Permission permissionType =
          sdkInt >= 33 ? Permission.photos : Permission.storage;
      final String permissionName = sdkInt >= 33 ? 'gallery' : 'storage';

      var status = await permissionType.status;

      if (status.isGranted) {
        return true;
      }

      if (status.isPermanentlyDenied) {
        if (context != null && context.mounted) {
          PermissionSettingsDialog.show(context, permissionName);
        }
        return false;
      }

      if (status.isDenied) {
        status = await permissionType.request();
        return status.isGranted;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> openSettings() async {
    await openAppSettings();
  }
}
