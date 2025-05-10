import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  static Future<bool> checkCameraPermission({BuildContext? context}) async {
    var status = await Permission.camera.status;

    // verify if the permission is already granted
    if (status.isGranted) {
      return true;
    }

    // If the permission is permanently denied, then we can show a custom dialog
    // to inform the user that they need to go to settings to enable it
    if (status.isPermanentlyDenied) {
      if (context != null) {
        // Check if the context is still valid before showing dialog
        if (context.mounted) {
          _showOpenSettingsDialog(context, 'camera');
        }
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

  static Future<bool> checkGalleryPermission({BuildContext? context}) async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
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
        if (context != null) {
          if (context.mounted) {
            _showOpenSettingsDialog(context, permissionName);
          }
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

  static void _showOpenSettingsDialog(BuildContext context, String resource) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Permission Denied'),
          content: Text(
            'You have permanently denied permission to access the $resource. '
            'You can enable it in the app settings.',
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Go to Settings'),
              onPressed: () {
                context.pop();
                openAppSettings();
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                context.pop();
              },
            ),
          ],
        );
      },
    );
  }
}
