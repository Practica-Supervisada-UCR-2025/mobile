import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/core.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([PermissionsRepository, FCMService, LocalStorage])
import 'notifications_service_impl_test.mocks.dart';

void main() {
  late NotificationsServiceImpl notificationsService;
  late MockPermissionsRepository mockPermissionsRepository;
  late MockFCMService mockFCMService;
  late MockLocalStorage mockLocalStorage;

  setUp(() {
    mockPermissionsRepository = MockPermissionsRepository();
    mockFCMService = MockFCMService();
    mockLocalStorage = MockLocalStorage();

    notificationsService = NotificationsServiceImpl(
      permissionsRepository: mockPermissionsRepository,
      fcmService: mockFCMService,
      localStorage: mockLocalStorage,
    );

    debugPrint = (message, {wrapWidth}) {};
  });

  tearDown(() {
    debugPrint = debugPrintThrottled;
  });

  group('setupNotifications', () {
    test('should return failed result when permission is denied', () async {
      when(
        mockPermissionsRepository.checkNotificationPermission(
          context: null,
          showDialogIfDenied: anyNamed('showDialogIfDenied'),
        ),
      ).thenAnswer((_) async => false);

      final result = await notificationsService.setupNotifications();

      expect(result.hasPermission, false);
      expect(result.hasFCMToken, false);
      expect(result.success, false);

      verify(
        mockPermissionsRepository.checkNotificationPermission(
          context: null,
          showDialogIfDenied: true,
        ),
      ).called(1);
      verifyNever(mockLocalStorage.fcmToken);
    });

    test(
      'should return success when permission granted and FCM token exists',
      () async {
        // Arrange
        when(
          mockPermissionsRepository.checkNotificationPermission(
            context: null,
            showDialogIfDenied: anyNamed('showDialogIfDenied'),
          ),
        ).thenAnswer((_) async => true);

        when(mockLocalStorage.fcmToken).thenReturn('existing_token');

        // Act
        final result = await notificationsService.setupNotifications();

        // Assert
        expect(result.hasPermission, true);
        expect(result.hasFCMToken, true);
        expect(result.success, true);

        verify(
          mockPermissionsRepository.checkNotificationPermission(
            context: null,
            showDialogIfDenied: true,
          ),
        ).called(1);
        verify(mockLocalStorage.fcmToken).called(1);
        verifyNever(mockFCMService.createFCMToken());
      },
    );

    test(
      'should create new FCM token when permission granted but no existing token',
      () async {
        const newToken = 'new_fcm_token';

        when(
          mockPermissionsRepository.checkNotificationPermission(
            context: null,
            showDialogIfDenied: anyNamed('showDialogIfDenied'),
          ),
        ).thenAnswer((_) async => true);

        when(mockLocalStorage.fcmToken).thenReturn('');
        when(mockFCMService.createFCMToken()).thenAnswer((_) async => newToken);
        when(mockFCMService.sendFCMToServer(any)).thenAnswer((_) async {});

        final result = await notificationsService.setupNotifications();

        expect(result.hasPermission, true);
        expect(result.hasFCMToken, true);
        expect(result.success, true);

        verify(
          mockPermissionsRepository.checkNotificationPermission(
            context: null,
            showDialogIfDenied: true,
          ),
        ).called(1);
        verify(mockLocalStorage.fcmToken).called(1);
        verify(mockFCMService.createFCMToken()).called(1);
        verify(mockFCMService.sendFCMToServer(newToken)).called(1);
      },
    );

    test('should return failed result when FCM token creation fails', () async {
      when(
        mockPermissionsRepository.checkNotificationPermission(
          context: null,
          showDialogIfDenied: anyNamed('showDialogIfDenied'),
        ),
      ).thenAnswer((_) async => true);

      when(mockLocalStorage.fcmToken).thenReturn('');
      when(mockFCMService.createFCMToken()).thenAnswer((_) async => null);

      final result = await notificationsService.setupNotifications();

      expect(result.hasPermission, true);
      expect(result.hasFCMToken, false);
      expect(result.success, false);

      verify(mockFCMService.createFCMToken()).called(1);
      verifyNever(mockFCMService.sendFCMToServer(any));
    });

    test('should return failed result when FCM token is empty', () async {
      when(
        mockPermissionsRepository.checkNotificationPermission(
          context: null,
          showDialogIfDenied: anyNamed('showDialogIfDenied'),
        ),
      ).thenAnswer((_) async => true);

      when(mockLocalStorage.fcmToken).thenReturn('');
      when(mockFCMService.createFCMToken()).thenAnswer((_) async => '');

      final result = await notificationsService.setupNotifications();

      expect(result.hasPermission, true);
      expect(result.hasFCMToken, false);
      expect(result.success, false);

      verifyNever(mockFCMService.sendFCMToServer(any));
    });

    test(
      'should pass context and showDialogIfDenied parameters correctly',
      () async {
        final context = MockBuildContext();

        when(
          mockPermissionsRepository.checkNotificationPermission(
            context: context,
            showDialogIfDenied: anyNamed('showDialogIfDenied'),
          ),
        ).thenAnswer((_) async => false);

        await notificationsService.setupNotifications(
          context: context,
          showDialogIfDenied: false,
        );

        verify(
          mockPermissionsRepository.checkNotificationPermission(
            context: context,
            showDialogIfDenied: false,
          ),
        ).called(1);
      },
    );

    test(
      'should handle exceptions and return failed result with correct FCM token status',
      () async {
        when(mockLocalStorage.fcmToken).thenReturn('existing_token');

        when(
          mockPermissionsRepository.checkNotificationPermission(
            context: null,
            showDialogIfDenied: anyNamed('showDialogIfDenied'),
          ),
        ).thenThrow(Exception('Permission check failed'));

        // Act
        final result = await notificationsService.setupNotifications();

        // Assert
        expect(result.hasPermission, false);
        expect(result.hasFCMToken, true);
        expect(result.success, false);

        verify(mockLocalStorage.fcmToken).called(1);
        verify(
          mockPermissionsRepository.checkNotificationPermission(
            context: null,
            showDialogIfDenied: true,
          ),
        ).called(1);
      },
    );
  });

  group('hasValidSetup', () {
    test('should return true when has permission and FCM token', () async {
      when(
        mockPermissionsRepository.checkNotificationPermission(
          showDialogIfDenied: anyNamed('showDialogIfDenied'),
        ),
      ).thenAnswer((_) async => true);

      when(mockLocalStorage.fcmToken).thenReturn('valid_token');

      final result = await notificationsService.hasValidSetup();

      expect(result, true);

      verify(
        mockPermissionsRepository.checkNotificationPermission(
          showDialogIfDenied: false,
        ),
      ).called(1);
      verify(mockLocalStorage.fcmToken).called(1);
    });

    test('should return false when permission denied', () async {
      when(
        mockPermissionsRepository.checkNotificationPermission(
          showDialogIfDenied: anyNamed('showDialogIfDenied'),
        ),
      ).thenAnswer((_) async => false);

      when(mockLocalStorage.fcmToken).thenReturn('valid_token');

      final result = await notificationsService.hasValidSetup();

      expect(result, false);
    });

    test('should return false when no FCM token', () async {
      when(
        mockPermissionsRepository.checkNotificationPermission(
          showDialogIfDenied: anyNamed('showDialogIfDenied'),
        ),
      ).thenAnswer((_) async => true);

      when(mockLocalStorage.fcmToken).thenReturn('');

      final result = await notificationsService.hasValidSetup();

      expect(result, false);
    });

    test('should return false when neither permission nor FCM token', () async {
      when(
        mockPermissionsRepository.checkNotificationPermission(
          showDialogIfDenied: anyNamed('showDialogIfDenied'),
        ),
      ).thenAnswer((_) async => false);

      when(mockLocalStorage.fcmToken).thenReturn('');

      final result = await notificationsService.hasValidSetup();

      expect(result, false);
    });
  });

  group('setupNotificationsSilently', () {
    test(
      'should call setupNotifications with showDialogIfDenied false',
      () async {
        when(
          mockPermissionsRepository.checkNotificationPermission(
            context: null,
            showDialogIfDenied: anyNamed('showDialogIfDenied'),
          ),
        ).thenAnswer((_) async => true);

        when(mockLocalStorage.fcmToken).thenReturn('existing_token');

        final result = await notificationsService.setupNotificationsSilently();

        expect(result.success, true);

        verify(
          mockPermissionsRepository.checkNotificationPermission(
            context: null,
            showDialogIfDenied: false,
          ),
        ).called(1);
      },
    );
  });

  group('setupNotificationsInteractive', () {
    test(
      'should call setupNotifications with context and showDialogIfDenied true',
      () async {
        final context = MockBuildContext();

        when(
          mockPermissionsRepository.checkNotificationPermission(
            context: context,
            showDialogIfDenied: anyNamed('showDialogIfDenied'),
          ),
        ).thenAnswer((_) async => true);

        when(mockLocalStorage.fcmToken).thenReturn('existing_token');

        final result = await notificationsService.setupNotificationsInteractive(
          context,
        );

        expect(result.success, true);

        verify(
          mockPermissionsRepository.checkNotificationPermission(
            context: context,
            showDialogIfDenied: true,
          ),
        ).called(1);
      },
    );
  });
}

class MockBuildContext extends Mock implements BuildContext {}
