abstract class FCMService {
  Future<String?> createFCMToken();
  Future<void> sendFCMToServer(String token);
}
