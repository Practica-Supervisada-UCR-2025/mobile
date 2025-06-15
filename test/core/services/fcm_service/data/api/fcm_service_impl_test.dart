import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/core/core.dart';

@GenerateMocks(
  [LocalStorage, ApiService, FirebaseMessaging],
  customMocks: [MockSpec<http.Response>(as: #MockHttpResponse)],
)
import 'fcm_service_impl_test.mocks.dart';

void main() {
  group('FCMServiceImpl', () {
    late FCMServiceImpl fcmService;
    late MockLocalStorage mockLocalStorage;
    late MockApiService mockApiService;
    late MockFirebaseMessaging mockFirebaseMessaging;

    setUp(() {
      mockLocalStorage = MockLocalStorage();
      mockApiService = MockApiService();
      mockFirebaseMessaging = MockFirebaseMessaging();

      fcmService = FCMServiceImpl(
        localStorage: mockLocalStorage,
        apiService: mockApiService,
        firebaseMessaging: mockFirebaseMessaging,
      );

      debugPrint = (message, {wrapWidth}) {};
    });

    tearDown(() {
      debugPrint = debugPrintThrottled;
    });

    group('createFCMToken', () {
      test('should return token when Firebase returns valid token', () async {
        const expectedToken = 'firebase_token_123';

        when(
          mockFirebaseMessaging.getToken(),
        ).thenAnswer((_) async => expectedToken);

        // Simulate onTokenRefresh stream
        final mockTokenStream = StreamController<String>.broadcast();
        when(
          mockFirebaseMessaging.onTokenRefresh,
        ).thenAnswer((_) => mockTokenStream.stream);

        final result = await fcmService.createFCMToken();

        expect(result, equals(expectedToken));
        verify(mockFirebaseMessaging.getToken()).called(1);

        // Cleanup the stream controller
        mockTokenStream.close();
      });

      test('should return null when Firebase returns null token', () async {
        when(mockFirebaseMessaging.getToken()).thenAnswer((_) async => null);

        final result = await fcmService.createFCMToken();

        expect(result, isNull);
        verify(mockFirebaseMessaging.getToken()).called(1);
      });

      test(
        'should return null and handle exception when Firebase throws error',
        () async {
          when(
            mockFirebaseMessaging.getToken(),
          ).thenThrow(Exception('Firebase error'));

          final result = await fcmService.createFCMToken();

          expect(result, isNull);
          verify(mockFirebaseMessaging.getToken()).called(1);
        },
      );
    });

    group('sendFCMToServer', () {
      test(
        'should send FCM token to server successfully with status code 201',
        () async {
          const token = 'test_token_123';
          const userId = 'user_123';
          final mockResponse = MockHttpResponse();

          when(mockLocalStorage.userId).thenReturn(userId);
          when(
            mockApiService.post(
              'push-notifications/register-fmc-token',
              body: {
                'fcmToken': token,
                'deviceType': 'android',
                'userId': userId,
              },
              authenticated: true,
            ),
          ).thenAnswer((_) async => mockResponse);
          when(mockResponse.statusCode).thenReturn(201);

          await fcmService.sendFCMToServer(token);

          verify(
            mockApiService.post(
              'push-notifications/register-fmc-token',
              body: {
                'fcmToken': token,
                'deviceType': 'android',
                'userId': userId,
              },
              authenticated: true,
            ),
          ).called(1);
          verify(mockLocalStorage.fcmToken = token).called(1);
        },
      );

      test('should handle non-201 status code response', () async {
        const token = 'test_token_123';
        const userId = 'user_123';
        final mockResponse = MockHttpResponse();

        when(mockLocalStorage.userId).thenReturn(userId);
        when(
          mockApiService.post(
            'push-notifications/register-fmc-token',
            body: {
              'fcmToken': token,
              'deviceType': 'android',
              'userId': userId,
            },
            authenticated: true,
          ),
        ).thenAnswer((_) async => mockResponse);
        when(mockResponse.statusCode).thenReturn(400);
        when(mockResponse.body).thenReturn('Bad Request');

        await fcmService.sendFCMToServer(token);

        verify(
          mockApiService.post(
            'push-notifications/register-fmc-token',
            body: {
              'fcmToken': token,
              'deviceType': 'android',
              'userId': userId,
            },
            authenticated: true,
          ),
        ).called(1);
        verifyNever(mockLocalStorage.fcmToken = token);
      });

      test('should handle exception when sending token to server', () async {
        const token = 'test_token_123';
        const userId = 'user_123';

        when(mockLocalStorage.userId).thenReturn(userId);
        when(
          mockApiService.post(
            'push-notifications/register-fmc-token',
            body: {
              'fcmToken': token,
              'deviceType': 'android',
              'userId': userId,
            },
            authenticated: true,
          ),
        ).thenThrow(Exception('Network error'));

        await fcmService.sendFCMToServer(token);

        verify(
          mockApiService.post(
            'push-notifications/register-fmc-token',
            body: {
              'fcmToken': token,
              'deviceType': 'android',
              'userId': userId,
            },
            authenticated: true,
          ),
        ).called(1);
      });
    });

    group('token refresh behavior', () {
      test(
        'should update local storage and send to server when token refreshes and user is logged in',
        () async {
          const initialToken = 'initial_token';
          const newToken = 'refreshed_token';
          const userId = 'user_123';

          final mockTokenStream = StreamController<String>.broadcast();
          final mockResponse = MockHttpResponse();

          when(
            mockFirebaseMessaging.getToken(),
          ).thenAnswer((_) async => initialToken);
          when(
            mockFirebaseMessaging.onTokenRefresh,
          ).thenAnswer((_) => mockTokenStream.stream);
          when(mockLocalStorage.isLoggedIn).thenReturn(true);
          when(mockLocalStorage.userId).thenReturn(userId);
          when(
            mockApiService.post(
              'push-notifications/register-fmc-token',
              body: {
                'fcmToken': newToken,
                'deviceType': 'android',
                'userId': userId,
              },
              authenticated: true,
            ),
          ).thenAnswer((_) async => mockResponse);
          when(mockResponse.statusCode).thenReturn(201);

          // Create token to trigger token refresh configuration
          await fcmService.createFCMToken();

          // Simulate token refresh
          mockTokenStream.add(newToken);

          // Wait for async operations
          await Future.delayed(Duration(milliseconds: 10));

          // Verify token was stored locally
          verify(mockLocalStorage.fcmToken = newToken).called(2);

          // Verify token was sent to server
          verify(
            mockApiService.post(
              'push-notifications/register-fmc-token',
              body: {
                'fcmToken': newToken,
                'deviceType': 'android',
                'userId': userId,
              },
              authenticated: true,
            ),
          ).called(1);

          mockTokenStream.close();
        },
      );

      test(
        'should only update local storage when token refreshes and user is not logged in',
        () async {
          const initialToken = 'initial_token';
          const newToken = 'refreshed_token';

          final mockTokenStream = StreamController<String>.broadcast();

          when(
            mockFirebaseMessaging.getToken(),
          ).thenAnswer((_) async => initialToken);
          when(
            mockFirebaseMessaging.onTokenRefresh,
          ).thenAnswer((_) => mockTokenStream.stream);
          when(mockLocalStorage.isLoggedIn).thenReturn(false);

          await fcmService.createFCMToken();
          mockTokenStream.add(newToken);
          await Future.delayed(Duration(milliseconds: 10));

          verify(mockLocalStorage.fcmToken = newToken).called(1);
          verifyNever(
            mockApiService.post(
              any,
              body: anyNamed('body'),
              authenticated: anyNamed('authenticated'),
            ),
          );

          mockTokenStream.close();
        },
      );
    });
  });
}
