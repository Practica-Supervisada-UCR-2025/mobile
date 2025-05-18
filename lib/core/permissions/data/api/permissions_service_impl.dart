
import 'package:permission_handler/permission_handler.dart';
import 'api.dart';

class PermissionServiceImpl implements PermissionService {
  @override
  Future<PermissionStatus> getCameraStatus() => Permission.camera.status;

  @override
  Future<PermissionStatus> requestCamera() => Permission.camera.request();

  @override
  Future<PermissionStatus> getGalleryStatus() => Permission.photos.status;

  @override
  Future<PermissionStatus> requestGallery() => Permission.photos.request();

  @override
  Future<PermissionStatus> getStorageStatus() => Permission.storage.status;

  @override
  Future<PermissionStatus> requestStorage() => Permission.storage.request();

  @override
  Future<PermissionStatus> getPhotosStatus() => Permission.photos.status;

  @override
  Future<PermissionStatus> requestPhotos() => Permission.photos.request();

  @override
  Future<bool> openSettings() => openAppSettings();
}