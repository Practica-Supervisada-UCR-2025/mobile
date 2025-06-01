import 'package:flutter/material.dart';

abstract class NotificationsService {
  Future<NotificationSetupResult> setupNotifications({
    BuildContext? context,
    bool showDialogIfDenied = true,
  });

  Future<bool> hasValidSetup();

  Future<NotificationSetupResult> setupNotificationsSilently();
  Future<NotificationSetupResult> setupNotificationsInteractive(
    BuildContext context,
  );
}

class NotificationSetupResult {
  final bool hasPermission;
  final bool hasFCMToken;
  final bool success;

  const NotificationSetupResult({
    required this.hasPermission,
    required this.hasFCMToken,
    required this.success,
  });

  bool get isComplete => hasPermission && hasFCMToken && success;
}
