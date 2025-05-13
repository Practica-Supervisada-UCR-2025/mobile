import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/core/core.dart';
import 'dart:convert';

import 'package:mobile/src/auth/auth.dart';

class FCMTokenServiceImpl implements FCMTokenService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final LocalStorage _localStorage;

  //todo: Update this URL to server endpoint
  final String _tokenEndpoint = 'https://api.com/fcm-token';
  FCMTokenServiceImpl(this._localStorage);

  @override
  Future<String?> createFCMToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();

      if (token != null) {
        _localStorage.fcmToken = token;

        _configureTokenRefresh();
      }

      return token;
    } catch (e) {
      debugPrint('Error al obtener token FCM: $e');
      return null;
    }
  }

  @override
  Future<void> sendFCMToServer(String token) async {
    try {
      // todo: verify if is this token
      final accessToken = _localStorage.accessToken;
      print('Access token: $accessToken');
      print('FCM token: $token');

      if (accessToken.isEmpty) {
        throw Exception('Invalid access token');
      }

      final response = await http.post(
        Uri.parse(_tokenEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'fcmToken': token,
          'deviceType': defaultTargetPlatform.toString(),
          'userId': _localStorage.userId,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Error sending FCM: ${response.body}');
      }

      debugPrint('Token FCM successfully sent to server');
    } catch (e) {
      debugPrint('Error sending FCM token: $e');
      rethrow;
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

  @override
  Future<bool> requestNotificationPermission() async {
    try {
      NotificationSettings settings = await _firebaseMessaging
          .requestPermission(
            alert: true,
            badge: true,
            sound: true,
            provisional: false,
          );

      bool granted =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;

      //_localStorage.notificationPermissionGranted = granted;

      return granted;
    } catch (e) {
      debugPrint('Error al solicitar permisos: $e');
      return false;
    }
  }
}
