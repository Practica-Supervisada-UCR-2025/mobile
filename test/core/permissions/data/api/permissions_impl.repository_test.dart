import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mobile/core/permissions/data/api/api.dart';
import 'package:permission_handler/permission_handler.dart';

import 'permissions_impl.repository_test.mocks.dart';

@GenerateMocks([
  PermissionService,
  DeviceInfoPlugin,
  AndroidDeviceInfo,
  AndroidBuildVersion,
  BuildContext,
])
void main() {
  late MockPermissionService mockPermissionService;
  late MockDeviceInfoPlugin mockDeviceInfoPlugin;
  late MockAndroidDeviceInfo mockAndroidDeviceInfo;
  late PermissionsRepositoryImpl repository;
  late MockBuildContext mockBuildContext;

  setUp(() {
    mockPermissionService = MockPermissionService();
    mockDeviceInfoPlugin = MockDeviceInfoPlugin();
    mockAndroidDeviceInfo = MockAndroidDeviceInfo();
    mockBuildContext = MockBuildContext();

    repository = PermissionsRepositoryImpl(
      permissionService: mockPermissionService,
      deviceInfoPlugin: mockDeviceInfoPlugin,
    );
  });

  group('checkCameraPermission', () {
    test('returns true if camera permission is granted', () async {
      when(mockPermissionService.getCameraStatus())
          .thenAnswer((_) async => PermissionStatus.granted);

      final result = await repository.checkCameraPermission();

      expect(result, isTrue);
    });

    test('returns false if camera permission is permanently denied', () async {
      when(mockPermissionService.getCameraStatus())
          .thenAnswer((_) async => PermissionStatus.permanentlyDenied);

      final result = await repository.checkCameraPermission();

      expect(result, isFalse);
    });

    test('requests permission if not granted or permanently denied', () async {
      when(mockPermissionService.getCameraStatus())
          .thenAnswer((_) async => PermissionStatus.denied);
      when(mockPermissionService.requestCamera())
          .thenAnswer((_) async => PermissionStatus.granted);

      final result = await repository.checkCameraPermission();

      expect(result, isTrue);
    });

    test('returns false if camera permission is permanently denied (without context)', () async {
      when(mockPermissionService.getCameraStatus())
          .thenAnswer((_) async => PermissionStatus.permanentlyDenied);

      final result = await repository.checkCameraPermission();

      expect(result, isFalse);
    });
  });

  group('checkGalleryPermission', () {
    late MockAndroidBuildVersion mockBuildVersion;

    setUp(() {
      mockBuildVersion = MockAndroidBuildVersion();
      when(mockAndroidDeviceInfo.version).thenReturn(mockBuildVersion);
      when(mockDeviceInfoPlugin.androidInfo)
          .thenAnswer((_) async => mockAndroidDeviceInfo);
    });

    test('uses getPhotosStatus when SDK >= 33 and permission granted', () async {
      when(mockBuildVersion.sdkInt).thenReturn(34);
      when(mockPermissionService.getPhotosStatus())
          .thenAnswer((_) async => PermissionStatus.granted);

      final result = await repository.checkGalleryPermission();

      expect(result, isTrue);
    });

    test('shows dialog if photos permission permanently denied and context mounted', () async {
      when(mockBuildVersion.sdkInt).thenReturn(34);
      when(mockPermissionService.getPhotosStatus())
          .thenAnswer((_) async => PermissionStatus.permanentlyDenied);
      when(mockBuildContext.mounted).thenReturn(true);

      final result = await repository.checkGalleryPermission();

      expect(result, isFalse);
    });

    test('requests photos permission and returns false if not granted', () async {
      when(mockBuildVersion.sdkInt).thenReturn(34);
      when(mockPermissionService.getPhotosStatus())
          .thenAnswer((_) async => PermissionStatus.denied);
      when(mockPermissionService.requestPhotos())
          .thenAnswer((_) async => PermissionStatus.denied);

      final result = await repository.checkGalleryPermission();

      expect(result, isFalse);
    });

    test('uses getStorageStatus when SDK < 33 and permission granted', () async {
      when(mockBuildVersion.sdkInt).thenReturn(30);
      when(mockPermissionService.getStorageStatus())
          .thenAnswer((_) async => PermissionStatus.granted);

      final result = await repository.checkGalleryPermission();

      expect(result, isTrue);
    });

    test('shows dialog if storage permission permanently denied and context mounted', () async {
      when(mockBuildVersion.sdkInt).thenReturn(30);
      when(mockPermissionService.getStorageStatus())
          .thenAnswer((_) async => PermissionStatus.permanentlyDenied);
      when(mockBuildContext.mounted).thenReturn(true);

      final result = await repository.checkGalleryPermission();

      expect(result, isFalse);
    });

    test('requests storage permission and returns false if not granted', () async {
      when(mockBuildVersion.sdkInt).thenReturn(30);
      when(mockPermissionService.getStorageStatus())
          .thenAnswer((_) async => PermissionStatus.denied);
      when(mockPermissionService.requestStorage())
          .thenAnswer((_) async => PermissionStatus.denied);

      final result = await repository.checkGalleryPermission();

      expect(result, isFalse);
    });

    test('uses default DeviceInfoPlugin if not provided', () async {
      final repo = PermissionsRepositoryImpl(permissionService: mockPermissionService);
      expect(repo.deviceInfoPlugin, isA<DeviceInfoPlugin>());
    });

    testWidgets('shows dialog if camera permission is permanently denied', (WidgetTester tester) async {
        when(mockPermissionService.getCameraStatus())
            .thenAnswer((_) async => PermissionStatus.permanentlyDenied);

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                Future.microtask(() {
                  repository.checkCameraPermission(context: context);
                });
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
      });

  });

  group('openSettings', () {
    test('calls permissionService.openSettings', () async {
      when(mockPermissionService.openSettings())
          .thenAnswer((_) async => true);

      await repository.openSettings();

      verify(mockPermissionService.openSettings()).called(1);
    });
  });
}
