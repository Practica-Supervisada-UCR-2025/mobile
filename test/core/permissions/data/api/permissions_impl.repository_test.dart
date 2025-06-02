import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/core.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:permission_handler/permission_handler.dart';

import 'permissions_impl.repository_test.mocks.dart';

@GenerateMocks([
  PermissionService,
  DeviceInfoPlugin,
  AndroidDeviceInfo,
  AndroidBuildVersion,
])
void main() {
  late MockPermissionService mockPermissionService;
  late MockDeviceInfoPlugin mockDeviceInfoPlugin;
  late MockAndroidDeviceInfo mockAndroidDeviceInfo;
  late PermissionsRepositoryImpl repository;

  setUp(() {
    mockPermissionService = MockPermissionService();
    mockDeviceInfoPlugin = MockDeviceInfoPlugin();
    mockAndroidDeviceInfo = MockAndroidDeviceInfo();

    repository = PermissionsRepositoryImpl(
      permissionService: mockPermissionService,
      deviceInfoPlugin: mockDeviceInfoPlugin,
    );
  });

  group('checkCameraPermission', () {
    test('returns true if camera permission is granted', () async {
      when(
        mockPermissionService.getCameraStatus(),
      ).thenAnswer((_) async => PermissionStatus.granted);

      final result = await repository.checkCameraPermission();

      expect(result, isTrue);
    });

    test('returns false if camera permission is permanently denied', () async {
      when(
        mockPermissionService.getCameraStatus(),
      ).thenAnswer((_) async => PermissionStatus.permanentlyDenied);

      final result = await repository.checkCameraPermission();

      expect(result, isFalse);
    });

    test(
      'requests permission if denied, and returns true if granted',
      () async {
        when(
          mockPermissionService.getCameraStatus(),
        ).thenAnswer((_) async => PermissionStatus.denied);
        when(
          mockPermissionService.requestCamera(),
        ).thenAnswer((_) async => PermissionStatus.granted);

        final result = await repository.checkCameraPermission();

        expect(result, isTrue);
      },
    );
  });

  group('checkGalleryPermission - Android SDK >= 33', () {
    late MockAndroidBuildVersion mockBuildVersion;

    setUp(() {
      mockBuildVersion = MockAndroidBuildVersion();
      when(mockAndroidDeviceInfo.version).thenReturn(mockBuildVersion);
      when(
        mockDeviceInfoPlugin.androidInfo,
      ).thenAnswer((_) async => mockAndroidDeviceInfo);
      when(mockBuildVersion.sdkInt).thenReturn(34);
    });

    test('returns true if photos permission is granted', () async {
      when(
        mockPermissionService.getPhotosStatus(),
      ).thenAnswer((_) async => PermissionStatus.granted);

      final result = await repository.checkGalleryPermission();

      expect(result, isTrue);
    });

    test('returns false if photos permission is permanently denied', () async {
      when(
        mockPermissionService.getPhotosStatus(),
      ).thenAnswer((_) async => PermissionStatus.permanentlyDenied);

      final result = await repository.checkGalleryPermission();

      expect(result, isFalse);
    });

    test('requests permission and returns false if not granted', () async {
      when(
        mockPermissionService.getPhotosStatus(),
      ).thenAnswer((_) async => PermissionStatus.denied);
      when(
        mockPermissionService.requestPhotos(),
      ).thenAnswer((_) async => PermissionStatus.denied);

      final result = await repository.checkGalleryPermission();

      expect(result, isFalse);
    });

    testWidgets(
      'shows settings dialog if photos permission is permanently denied and context is mounted',
      (tester) async {
        when(
          mockPermissionService.getPhotosStatus(),
        ).thenAnswer((_) async => PermissionStatus.permanentlyDenied);

        final testWidget = Builder(
          builder: (context) {
            repository.checkGalleryPermission(context: context);
            return const SizedBox();
          },
        );

        await tester.pumpWidget(MaterialApp(home: testWidget));
      },
    );
  });

  group('checkGalleryPermission - Android SDK < 33', () {
    late MockAndroidBuildVersion mockBuildVersion;

    setUp(() {
      mockBuildVersion = MockAndroidBuildVersion();
      when(mockAndroidDeviceInfo.version).thenReturn(mockBuildVersion);
      when(
        mockDeviceInfoPlugin.androidInfo,
      ).thenAnswer((_) async => mockAndroidDeviceInfo);
      when(mockBuildVersion.sdkInt).thenReturn(30);
    });

    test('returns true if storage permission is granted', () async {
      when(
        mockPermissionService.getStorageStatus(),
      ).thenAnswer((_) async => PermissionStatus.granted);

      final result = await repository.checkGalleryPermission();

      expect(result, isTrue);
    });

    test('returns false if storage permission is permanently denied', () async {
      when(
        mockPermissionService.getStorageStatus(),
      ).thenAnswer((_) async => PermissionStatus.permanentlyDenied);

      final result = await repository.checkGalleryPermission();

      expect(result, isFalse);
    });

    test(
      'requests storage permission and returns false if not granted',
      () async {
        when(
          mockPermissionService.getStorageStatus(),
        ).thenAnswer((_) async => PermissionStatus.denied);
        when(
          mockPermissionService.requestStorage(),
        ).thenAnswer((_) async => PermissionStatus.denied);

        final result = await repository.checkGalleryPermission();

        expect(result, isFalse);
      },
    );

    testWidgets(
      'shows settings dialog if storage permission is permanently denied and context is mounted',
      (tester) async {
        when(mockBuildVersion.sdkInt).thenReturn(30);
        when(
          mockPermissionService.getStorageStatus(),
        ).thenAnswer((_) async => PermissionStatus.permanentlyDenied);
        when(
          mockDeviceInfoPlugin.androidInfo,
        ).thenAnswer((_) async => mockAndroidDeviceInfo);
        when(mockAndroidDeviceInfo.version).thenReturn(mockBuildVersion);

        final testWidget = Builder(
          builder: (context) {
            repository.checkGalleryPermission(context: context);
            return const SizedBox();
          },
        );

        await tester.pumpWidget(MaterialApp(home: testWidget));
      },
    );
  });

  group('default behavior', () {
    test('uses default DeviceInfoPlugin if not provided', () async {
      final repo = PermissionsRepositoryImpl(
        permissionService: mockPermissionService,
      );

      expect(repo.deviceInfoPlugin, isA<DeviceInfoPlugin>());
    });
  });

  group('UI tests (Dialogs)', () {
    testWidgets('shows dialog if camera permission is permanently denied', (
      WidgetTester tester,
    ) async {
      when(
        mockPermissionService.getCameraStatus(),
      ).thenAnswer((_) async => PermissionStatus.permanentlyDenied);

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

  group('checkNotificationPermission', () {
    late MockAndroidBuildVersion mockBuildVersion;

    setUp(() {
      mockBuildVersion = MockAndroidBuildVersion();
      when(mockAndroidDeviceInfo.version).thenReturn(mockBuildVersion);
      when(
        mockDeviceInfoPlugin.androidInfo,
      ).thenAnswer((_) async => mockAndroidDeviceInfo);
    });

    test('returns true if SDK < 33 (permission not required)', () async {
      when(mockBuildVersion.sdkInt).thenReturn(32);

      final result = await repository.checkNotificationPermission();

      expect(result, isTrue);
    });

    test('returns true if permission is already granted', () async {
      when(mockBuildVersion.sdkInt).thenReturn(33);
      when(
        mockPermissionService.getNotificationsStatus(),
      ).thenAnswer((_) async => PermissionStatus.granted);

      final result = await repository.checkNotificationPermission();

      expect(result, isTrue);
    });

    test(
      'returns false if permission is permanently denied and no context',
      () async {
        when(mockBuildVersion.sdkInt).thenReturn(33);
        when(
          mockPermissionService.getNotificationsStatus(),
        ).thenAnswer((_) async => PermissionStatus.permanentlyDenied);

        final result = await repository.checkNotificationPermission();

        expect(result, isFalse);
      },
    );

    testWidgets(
      'shows dialog if permission is permanently denied and context is mounted and showDialogIfDenied is true',
      (WidgetTester tester) async {
        when(mockBuildVersion.sdkInt).thenReturn(33);
        when(
          mockPermissionService.getNotificationsStatus(),
        ).thenAnswer((_) async => PermissionStatus.permanentlyDenied);

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                Future.microtask(() {
                  repository.checkNotificationPermission(
                    context: context,
                    showDialogIfDenied: true,
                  );
                });
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
      },
    );

    test('requests permission if not granted or permanently denied', () async {
      when(mockBuildVersion.sdkInt).thenReturn(33);
      when(
        mockPermissionService.getNotificationsStatus(),
      ).thenAnswer((_) async => PermissionStatus.denied);
      when(
        mockPermissionService.requestNotifications(),
      ).thenAnswer((_) async => PermissionStatus.granted);

      final result = await repository.checkNotificationPermission();

      expect(result, isTrue);
    });

    test('returns false if permission request is denied', () async {
      when(mockBuildVersion.sdkInt).thenReturn(33);
      when(
        mockPermissionService.getNotificationsStatus(),
      ).thenAnswer((_) async => PermissionStatus.denied);
      when(
        mockPermissionService.requestNotifications(),
      ).thenAnswer((_) async => PermissionStatus.denied);

      final result = await repository.checkNotificationPermission();

      expect(result, isFalse);
    });
  });

  group('openSettings', () {
    test('calls permissionService.openSettings', () async {
      when(mockPermissionService.openSettings()).thenAnswer((_) async => true);

      await repository.openSettings();

      verify(mockPermissionService.openSettings()).called(1);
    });
  });
}
