import 'package:flutter/widgets.dart';
import 'package:mobile/core/core.dart';

class NotificationsServiceImpl implements NotificationsService {
  final PermissionsRepository _permissionsRepository;
  final FCMService _fcmService;
  final LocalStorage _localStorage;

  NotificationsServiceImpl({
    required PermissionsRepository permissionsRepository,
    required FCMService fcmService,
    required LocalStorage localStorage,
  }) : _permissionsRepository = permissionsRepository,
       _fcmService = fcmService,
       _localStorage = localStorage;

  @override
  Future<NotificationSetupResult> setupNotifications({
    BuildContext? context,
    bool showDialogIfDenied = true,
  }) async {
    try {
      final hasPermission = await _permissionsRepository
          .checkNotificationPermission(
            context: context,
            showDialogIfDenied: showDialogIfDenied,
          );

      if (!hasPermission) {
        return NotificationSetupResult(
          hasPermission: false,
          hasFCMToken: false,
          success: false,
        );
      }

      if (_localStorage.fcmToken.isNotEmpty) {
        return NotificationSetupResult(
          hasPermission: true,
          hasFCMToken: true,
          success: true,
        );
      }

      final fcmToken = await _fcmService.createFCMToken();

      if (fcmToken == null || fcmToken.isEmpty) {
        return NotificationSetupResult(
          hasPermission: true,
          hasFCMToken: false,
          success: false,
        );
      }

      await _fcmService.sendFCMToServer(fcmToken);

      return NotificationSetupResult(
        hasPermission: true,
        hasFCMToken: true,
        success: true,
      );
    } catch (e) {
      debugPrint('Error in notification setup: $e');
      return NotificationSetupResult(
        hasPermission: false,
        hasFCMToken: _localStorage.fcmToken.isNotEmpty,
        success: false,
      );
    }
  }

  @override
  Future<bool> hasValidSetup() async {
    final hasPermission = await _permissionsRepository
        .checkNotificationPermission(showDialogIfDenied: false);

    final hasFCMToken = _localStorage.fcmToken.isNotEmpty;

    return hasPermission && hasFCMToken;
  }

  @override
  Future<NotificationSetupResult> setupNotificationsSilently() async {
    return setupNotifications(showDialogIfDenied: false);
  }

  @override
  Future<NotificationSetupResult> setupNotificationsInteractive(
    BuildContext context,
  ) async {
    return setupNotifications(context: context, showDialogIfDenied: true);
  }
}
