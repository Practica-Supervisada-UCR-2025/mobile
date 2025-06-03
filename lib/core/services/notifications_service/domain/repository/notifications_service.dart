import 'package:flutter/material.dart';
import 'package:mobile/core/core.dart';

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
