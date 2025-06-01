import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile/core/core.dart';

class FCMServiceImpl implements FCMService {
  final LocalStorage _localStorage;
  final ApiService _apiService;

  FCMServiceImpl({
    required LocalStorage localStorage,
    required ApiService apiService,
  }) : _localStorage = localStorage,
       _apiService = apiService;

  @override
  Future<String?> createFCMToken() async {
    final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

    try {
      String? token = await firebaseMessaging.getToken();

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
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      _localStorage.fcmToken = newToken;

      if (_localStorage.isLoggedIn) {
        await sendFCMToServer(newToken);
      }
    });
  }
}
