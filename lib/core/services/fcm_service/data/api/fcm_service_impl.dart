import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile/core/core.dart';

class FCMServiceImpl implements FCMService {
  final LocalStorage _localStorage;
  final ApiService _apiService;
  final FirebaseMessaging _firebaseMessaging;

  FCMServiceImpl({
    required LocalStorage localStorage,
    required ApiService apiService,
    FirebaseMessaging? firebaseMessaging,
  }) : _localStorage = localStorage,
       _apiService = apiService,
       _firebaseMessaging = firebaseMessaging ?? FirebaseMessaging.instance;

  @override
  Future<String?> createFCMToken() async {
    try {
      NotificationSettings settings = await _firebaseMessaging
          .requestPermission(
            alert: true,
            badge: true,
            sound: true,
            announcement: false,
            carPlay: false,
            criticalAlert: false,
            provisional: false,
          );

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint('Notification permission denied');
        return null;
      }

      String? token = await _firebaseMessaging.getToken();

      if (token != null) {
        _configureTokenRefresh();
      }
      return token;
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  @override
  Future<void> sendFCMToServer(String token) async {
    try {
      final response = await _apiService.post(
        'push-notifications/register-fmc-token',
        body: {
          'fcmToken': token,
          'deviceType': 'android',
          'userId': _localStorage.userId,
        },
        authenticated: true,
      );

      if (response.statusCode != 201) {
        debugPrint('Failed to send FCM token to server: ${response.body}');
      } else {
        _localStorage.fcmToken = token;
      }
    } catch (e) {
      debugPrint('Error sending FCM token to server: $e');
    }
  }

  void _configureTokenRefresh() {
    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      _localStorage.fcmToken = newToken;

      if (_localStorage.isLoggedIn) {
        await sendFCMToServer(newToken);
      }
    });
  }
}
