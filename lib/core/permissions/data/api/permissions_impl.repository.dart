import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:mobile/core/core.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsRepositoryImpl implements PermissionsRepository {
  final DeviceInfoPlugin deviceInfoPlugin;
  final PermissionService permissionService;

  PermissionsRepositoryImpl({
    DeviceInfoPlugin? deviceInfoPlugin,
    required this.permissionService,
  }) : deviceInfoPlugin = deviceInfoPlugin ?? DeviceInfoPlugin();

  @override
  Future<bool> checkCameraPermission({BuildContext? context}) async {
    var status = await permissionService.getCameraStatus();

    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      if (context?.mounted == true) {
        PermissionSettingsDialog.show(context!, 'camera');
      }
      return false;
    }

    status = await permissionService.requestCamera();
    return status.isGranted;
  }

  @override
  Future<bool> checkGalleryPermission({BuildContext? context}) async {
    final androidInfo = await deviceInfoPlugin.androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    if (sdkInt >= 33) {
      var status = await permissionService.getPhotosStatus();

      if (status.isGranted) return true;

      if (status.isPermanentlyDenied) {
        if (context?.mounted == true) {
          PermissionSettingsDialog.show(context!, 'gallery');
        }
        return false;
      }

      status = await permissionService.requestPhotos();
      return status.isGranted;
    } else {
      var status = await permissionService.getStorageStatus();

      if (status.isGranted) return true;

      if (status.isPermanentlyDenied) {
        if (context?.mounted == true) {
          PermissionSettingsDialog.show(context!, 'storage');
        }
        return false;
      }

      status = await permissionService.requestStorage();
      return status.isGranted;
    }
  }

  @override
  Future<bool> checkNotificationPermission({
    BuildContext? context,
    showDialogIfDenied,
  }) async {
    final androidInfo = await deviceInfoPlugin.androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    if (sdkInt < 33) return true;

    var status = await permissionService.getNotificationsStatus();

    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      if (showDialogIfDenied == true && context?.mounted == true) {
        PermissionSettingsDialog.show(context!, 'notifications');
      }

      return false;
    }

    status = await permissionService.requestNotifications();
    return status.isGranted;
  }

  @override
  Future<void> openSettings() async {
    await permissionService.openSettings();
  }
}
