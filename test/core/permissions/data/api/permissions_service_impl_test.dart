import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/permissions/data/api/permissions_service_impl.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('flutter.baseflow.com/permissions/methods');

  final service = PermissionServiceImpl();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getCameraStatus returns granted', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'checkPermissionStatus') {
        return 1; // 1 = PermissionStatus.granted
      }
      throw PlatformException(
          code: 'unimplemented', message: 'Method not implemented');
    });

    final result = await service.getCameraStatus();
    expect(result, PermissionStatus.granted);
  });

  test('requestCamera returns denied', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'requestPermissions') {
        return {
          1: 0, // 0 = PermissionStatus.denied
        };
      }
      throw PlatformException(
          code: 'unimplemented', message: 'Method not implemented');
    });

    final result = await service.requestCamera();
    expect(result, PermissionStatus.denied);
  });

   // getGalleryStatus
  test('getGalleryStatus returns granted', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'checkPermissionStatus') {
        return 1; // granted
      }
      throw PlatformException(
          code: 'unimplemented', message: 'Method not implemented');
    });

    final result = await service.getGalleryStatus();
    expect(result, PermissionStatus.granted);
  });

  // requestGallery
  test('requestGallery returns denied', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'requestPermissions') {
        return {
          Permission.photos.value: 0, // denied
        };
      }
      throw PlatformException(
          code: 'unimplemented', message: 'Method not implemented');
    });

    final result = await service.requestGallery();
    expect(result, PermissionStatus.denied);
  });

  // getStorageStatus
  test('getStorageStatus returns granted', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'checkPermissionStatus') {
        return 1; // granted
      }
      throw PlatformException(
          code: 'unimplemented', message: 'Method not implemented');
    });

    final result = await service.getStorageStatus();
    expect(result, PermissionStatus.granted);
  });

  // requestStorage
  test('requestStorage returns denied', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'requestPermissions') {
        return {
          Permission.storage.value: 0, // denied
        };
      }
      throw PlatformException(
          code: 'unimplemented', message: 'Method not implemented');
    });

    final result = await service.requestStorage();
    expect(result, PermissionStatus.denied);
  });

  // getPhotosStatus
  test('getPhotosStatus returns granted', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'checkPermissionStatus') {
        return 1; // granted
      }
      throw PlatformException(
          code: 'unimplemented', message: 'Method not implemented');
    });

    final result = await service.getPhotosStatus();
    expect(result, PermissionStatus.granted);
  });

  // requestPhotos
  test('requestPhotos returns denied', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'requestPermissions') {
        return {
          Permission.photos.value: 0, // denied
        };
      }
      throw PlatformException(
          code: 'unimplemented', message: 'Method not implemented');
    });

    final result = await service.requestPhotos();
    expect(result, PermissionStatus.denied);
  });

  // openSettings
  test('openSettings returns true', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'openAppSettings') {
        return true;
      }
      throw PlatformException(
          code: 'unimplemented', message: 'Method not implemented');
    });

    final result = await service.openSettings();
    expect(result, isTrue);
  });
}