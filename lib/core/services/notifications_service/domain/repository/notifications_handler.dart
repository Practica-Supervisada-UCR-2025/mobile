import 'package:firebase_messaging/firebase_messaging.dart';

abstract class NotificationHandler {
  Future<void> initialize();
  Future<void> showLocalNotification(RemoteMessage message);
  void onNotificationTapped(String? payload);
  void onMessageOpenedApp(RemoteMessage message);
}
