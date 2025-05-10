abstract class FCMTokenService {
  Future<String?> createFCMToken();
  Future<bool> requestNotificationPermission();
  Future<void> sendFCMToServer(String token);
}
