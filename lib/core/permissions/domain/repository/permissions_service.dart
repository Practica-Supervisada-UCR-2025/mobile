import 'package:permission_handler/permission_handler.dart';

abstract class PermissionService {
  Future<PermissionStatus> getCameraStatus();
  Future<PermissionStatus> requestCamera();

  Future<PermissionStatus> getGalleryStatus();
  Future<PermissionStatus> requestGallery();

  Future<PermissionStatus> getStorageStatus();
  Future<PermissionStatus> requestStorage();

  Future<PermissionStatus> getPhotosStatus();
  Future<PermissionStatus> requestPhotos();

  Future<PermissionStatus> getNotificationsStatus();
  Future<PermissionStatus> requestNotifications();

  Future<bool> openSettings();
}
