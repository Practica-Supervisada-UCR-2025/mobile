// Mocks generated by Mockito 5.4.6 from annotations
// in mobile/test/core/services/fcm_service/data/api/fcm_service_impl_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i7;
import 'dart:typed_data' as _i10;

import 'package:firebase_core/firebase_core.dart' as _i3;
import 'package:firebase_messaging/firebase_messaging.dart' as _i9;
import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart'
    as _i4;
import 'package:http/http.dart' as _i2;
import 'package:mobile/core/services/api_service/domain/repository/api_service.dart'
    as _i8;
import 'package:mobile/core/storage/user_session.storage.dart' as _i5;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i6;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: must_be_immutable
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeResponse_0 extends _i1.SmartFake implements _i2.Response {
  _FakeResponse_0(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeFirebaseApp_1 extends _i1.SmartFake implements _i3.FirebaseApp {
  _FakeFirebaseApp_1(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeNotificationSettings_2 extends _i1.SmartFake
    implements _i4.NotificationSettings {
  _FakeNotificationSettings_2(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

/// A class which mocks [LocalStorage].
///
/// See the documentation for Mockito's code generation for more information.
class MockLocalStorage extends _i1.Mock implements _i5.LocalStorage {
  MockLocalStorage() {
    _i1.throwOnMissingStub(this);
  }

  @override
  String get accessToken =>
      (super.noSuchMethod(
            Invocation.getter(#accessToken),
            returnValue: _i6.dummyValue<String>(
              this,
              Invocation.getter(#accessToken),
            ),
          )
          as String);

  @override
  String get refreshToken =>
      (super.noSuchMethod(
            Invocation.getter(#refreshToken),
            returnValue: _i6.dummyValue<String>(
              this,
              Invocation.getter(#refreshToken),
            ),
          )
          as String);

  @override
  String get userId =>
      (super.noSuchMethod(
            Invocation.getter(#userId),
            returnValue: _i6.dummyValue<String>(
              this,
              Invocation.getter(#userId),
            ),
          )
          as String);

  @override
  String get username =>
      (super.noSuchMethod(
            Invocation.getter(#username),
            returnValue: _i6.dummyValue<String>(
              this,
              Invocation.getter(#username),
            ),
          )
          as String);

  @override
  String get userEmail =>
      (super.noSuchMethod(
            Invocation.getter(#userEmail),
            returnValue: _i6.dummyValue<String>(
              this,
              Invocation.getter(#userEmail),
            ),
          )
          as String);

  @override
  String get userProfilePicture =>
      (super.noSuchMethod(
            Invocation.getter(#userProfilePicture),
            returnValue: _i6.dummyValue<String>(
              this,
              Invocation.getter(#userProfilePicture),
            ),
          )
          as String);

  @override
  bool get isLoggedIn =>
      (super.noSuchMethod(Invocation.getter(#isLoggedIn), returnValue: false)
          as bool);

  @override
  String get fcmToken =>
      (super.noSuchMethod(
            Invocation.getter(#fcmToken),
            returnValue: _i6.dummyValue<String>(
              this,
              Invocation.getter(#fcmToken),
            ),
          )
          as String);

  @override
  set accessToken(String? token) => super.noSuchMethod(
    Invocation.setter(#accessToken, token),
    returnValueForMissingStub: null,
  );

  @override
  set refreshToken(String? token) => super.noSuchMethod(
    Invocation.setter(#refreshToken, token),
    returnValueForMissingStub: null,
  );

  @override
  set userId(String? id) => super.noSuchMethod(
    Invocation.setter(#userId, id),
    returnValueForMissingStub: null,
  );

  @override
  set username(String? username) => super.noSuchMethod(
    Invocation.setter(#username, username),
    returnValueForMissingStub: null,
  );

  @override
  set userEmail(String? email) => super.noSuchMethod(
    Invocation.setter(#userEmail, email),
    returnValueForMissingStub: null,
  );

  @override
  set userProfilePicture(String? picture) => super.noSuchMethod(
    Invocation.setter(#userProfilePicture, picture),
    returnValueForMissingStub: null,
  );

  @override
  set fcmToken(String? token) => super.noSuchMethod(
    Invocation.setter(#fcmToken, token),
    returnValueForMissingStub: null,
  );

  @override
  _i7.Future<void> clear() =>
      (super.noSuchMethod(
            Invocation.method(#clear, []),
            returnValue: _i7.Future<void>.value(),
            returnValueForMissingStub: _i7.Future<void>.value(),
          )
          as _i7.Future<void>);
}

/// A class which mocks [ApiService].
///
/// See the documentation for Mockito's code generation for more information.
class MockApiService extends _i1.Mock implements _i8.ApiService {
  MockApiService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i7.Future<_i2.Response> get(
    String? endpoint, {
    bool? authenticated = true,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #get,
              [endpoint],
              {#authenticated: authenticated},
            ),
            returnValue: _i7.Future<_i2.Response>.value(
              _FakeResponse_0(
                this,
                Invocation.method(
                  #get,
                  [endpoint],
                  {#authenticated: authenticated},
                ),
              ),
            ),
          )
          as _i7.Future<_i2.Response>);

  @override
  _i7.Future<_i2.Response> post(
    String? endpoint, {
    Map<String, dynamic>? body,
    bool? authenticated = true,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #post,
              [endpoint],
              {#body: body, #authenticated: authenticated},
            ),
            returnValue: _i7.Future<_i2.Response>.value(
              _FakeResponse_0(
                this,
                Invocation.method(
                  #post,
                  [endpoint],
                  {#body: body, #authenticated: authenticated},
                ),
              ),
            ),
          )
          as _i7.Future<_i2.Response>);

  @override
  _i7.Future<_i2.Response> patch(
    String? endpoint, {
    Map<String, dynamic>? body,
    bool? authenticated = true,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #patch,
              [endpoint],
              {#body: body, #authenticated: authenticated},
            ),
            returnValue: _i7.Future<_i2.Response>.value(
              _FakeResponse_0(
                this,
                Invocation.method(
                  #patch,
                  [endpoint],
                  {#body: body, #authenticated: authenticated},
                ),
              ),
            ),
          )
          as _i7.Future<_i2.Response>);

  @override
  _i7.Future<_i2.Response> delete(
    String? endpoint, {
    bool? authenticated = true,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #delete,
              [endpoint],
              {#authenticated: authenticated},
            ),
            returnValue: _i7.Future<_i2.Response>.value(
              _FakeResponse_0(
                this,
                Invocation.method(
                  #delete,
                  [endpoint],
                  {#authenticated: authenticated},
                ),
              ),
            ),
          )
          as _i7.Future<_i2.Response>);

  @override
  _i7.Future<_i2.Response> patchMultipart(
    String? endpoint,
    Map<String, String>? fields,
    List<_i2.MultipartFile>? files, {
    bool? authenticated = true,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #patchMultipart,
              [endpoint, fields, files],
              {#authenticated: authenticated},
            ),
            returnValue: _i7.Future<_i2.Response>.value(
              _FakeResponse_0(
                this,
                Invocation.method(
                  #patchMultipart,
                  [endpoint, fields, files],
                  {#authenticated: authenticated},
                ),
              ),
            ),
          )
          as _i7.Future<_i2.Response>);

  @override
  _i7.Future<_i2.Response> postMultipart(
    String? endpoint,
    Map<String, String>? fields,
    List<_i2.MultipartFile>? files, {
    bool? authenticated = true,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #postMultipart,
              [endpoint, fields, files],
              {#authenticated: authenticated},
            ),
            returnValue: _i7.Future<_i2.Response>.value(
              _FakeResponse_0(
                this,
                Invocation.method(
                  #postMultipart,
                  [endpoint, fields, files],
                  {#authenticated: authenticated},
                ),
              ),
            ),
          )
          as _i7.Future<_i2.Response>);
}

/// A class which mocks [FirebaseMessaging].
///
/// See the documentation for Mockito's code generation for more information.
class MockFirebaseMessaging extends _i1.Mock implements _i9.FirebaseMessaging {
  MockFirebaseMessaging() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.FirebaseApp get app =>
      (super.noSuchMethod(
            Invocation.getter(#app),
            returnValue: _FakeFirebaseApp_1(this, Invocation.getter(#app)),
          )
          as _i3.FirebaseApp);

  @override
  bool get isAutoInitEnabled =>
      (super.noSuchMethod(
            Invocation.getter(#isAutoInitEnabled),
            returnValue: false,
          )
          as bool);

  @override
  _i7.Stream<String> get onTokenRefresh =>
      (super.noSuchMethod(
            Invocation.getter(#onTokenRefresh),
            returnValue: _i7.Stream<String>.empty(),
          )
          as _i7.Stream<String>);

  @override
  set app(_i3.FirebaseApp? _app) => super.noSuchMethod(
    Invocation.setter(#app, _app),
    returnValueForMissingStub: null,
  );

  @override
  Map<dynamic, dynamic> get pluginConstants =>
      (super.noSuchMethod(
            Invocation.getter(#pluginConstants),
            returnValue: <dynamic, dynamic>{},
          )
          as Map<dynamic, dynamic>);

  @override
  _i7.Future<_i4.RemoteMessage?> getInitialMessage() =>
      (super.noSuchMethod(
            Invocation.method(#getInitialMessage, []),
            returnValue: _i7.Future<_i4.RemoteMessage?>.value(),
          )
          as _i7.Future<_i4.RemoteMessage?>);

  @override
  _i7.Future<void> deleteToken() =>
      (super.noSuchMethod(
            Invocation.method(#deleteToken, []),
            returnValue: _i7.Future<void>.value(),
            returnValueForMissingStub: _i7.Future<void>.value(),
          )
          as _i7.Future<void>);

  @override
  _i7.Future<String?> getAPNSToken() =>
      (super.noSuchMethod(
            Invocation.method(#getAPNSToken, []),
            returnValue: _i7.Future<String?>.value(),
          )
          as _i7.Future<String?>);

  @override
  _i7.Future<String?> getToken({String? vapidKey}) =>
      (super.noSuchMethod(
            Invocation.method(#getToken, [], {#vapidKey: vapidKey}),
            returnValue: _i7.Future<String?>.value(),
          )
          as _i7.Future<String?>);

  @override
  _i7.Future<bool> isSupported() =>
      (super.noSuchMethod(
            Invocation.method(#isSupported, []),
            returnValue: _i7.Future<bool>.value(false),
          )
          as _i7.Future<bool>);

  @override
  _i7.Future<_i4.NotificationSettings> getNotificationSettings() =>
      (super.noSuchMethod(
            Invocation.method(#getNotificationSettings, []),
            returnValue: _i7.Future<_i4.NotificationSettings>.value(
              _FakeNotificationSettings_2(
                this,
                Invocation.method(#getNotificationSettings, []),
              ),
            ),
          )
          as _i7.Future<_i4.NotificationSettings>);

  @override
  _i7.Future<_i4.NotificationSettings> requestPermission({
    bool? alert = true,
    bool? announcement = false,
    bool? badge = true,
    bool? carPlay = false,
    bool? criticalAlert = false,
    bool? provisional = false,
    bool? sound = true,
    bool? providesAppNotificationSettings = false,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#requestPermission, [], {
              #alert: alert,
              #announcement: announcement,
              #badge: badge,
              #carPlay: carPlay,
              #criticalAlert: criticalAlert,
              #provisional: provisional,
              #sound: sound,
              #providesAppNotificationSettings: providesAppNotificationSettings,
            }),
            returnValue: _i7.Future<_i4.NotificationSettings>.value(
              _FakeNotificationSettings_2(
                this,
                Invocation.method(#requestPermission, [], {
                  #alert: alert,
                  #announcement: announcement,
                  #badge: badge,
                  #carPlay: carPlay,
                  #criticalAlert: criticalAlert,
                  #provisional: provisional,
                  #sound: sound,
                  #providesAppNotificationSettings:
                      providesAppNotificationSettings,
                }),
              ),
            ),
          )
          as _i7.Future<_i4.NotificationSettings>);

  @override
  _i7.Future<void> sendMessage({
    String? to,
    Map<String, String>? data,
    String? collapseKey,
    String? messageId,
    String? messageType,
    int? ttl,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#sendMessage, [], {
              #to: to,
              #data: data,
              #collapseKey: collapseKey,
              #messageId: messageId,
              #messageType: messageType,
              #ttl: ttl,
            }),
            returnValue: _i7.Future<void>.value(),
            returnValueForMissingStub: _i7.Future<void>.value(),
          )
          as _i7.Future<void>);

  @override
  _i7.Future<void> setAutoInitEnabled(bool? enabled) =>
      (super.noSuchMethod(
            Invocation.method(#setAutoInitEnabled, [enabled]),
            returnValue: _i7.Future<void>.value(),
            returnValueForMissingStub: _i7.Future<void>.value(),
          )
          as _i7.Future<void>);

  @override
  _i7.Future<void> setDeliveryMetricsExportToBigQuery(bool? enabled) =>
      (super.noSuchMethod(
            Invocation.method(#setDeliveryMetricsExportToBigQuery, [enabled]),
            returnValue: _i7.Future<void>.value(),
            returnValueForMissingStub: _i7.Future<void>.value(),
          )
          as _i7.Future<void>);

  @override
  _i7.Future<void> setForegroundNotificationPresentationOptions({
    bool? alert = false,
    bool? badge = false,
    bool? sound = false,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #setForegroundNotificationPresentationOptions,
              [],
              {#alert: alert, #badge: badge, #sound: sound},
            ),
            returnValue: _i7.Future<void>.value(),
            returnValueForMissingStub: _i7.Future<void>.value(),
          )
          as _i7.Future<void>);

  @override
  _i7.Future<void> subscribeToTopic(String? topic) =>
      (super.noSuchMethod(
            Invocation.method(#subscribeToTopic, [topic]),
            returnValue: _i7.Future<void>.value(),
            returnValueForMissingStub: _i7.Future<void>.value(),
          )
          as _i7.Future<void>);

  @override
  _i7.Future<void> unsubscribeFromTopic(String? topic) =>
      (super.noSuchMethod(
            Invocation.method(#unsubscribeFromTopic, [topic]),
            returnValue: _i7.Future<void>.value(),
            returnValueForMissingStub: _i7.Future<void>.value(),
          )
          as _i7.Future<void>);
}

/// A class which mocks [Response].
///
/// See the documentation for Mockito's code generation for more information.
class MockHttpResponse extends _i1.Mock implements _i2.Response {
  MockHttpResponse() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i10.Uint8List get bodyBytes =>
      (super.noSuchMethod(
            Invocation.getter(#bodyBytes),
            returnValue: _i10.Uint8List(0),
          )
          as _i10.Uint8List);

  @override
  String get body =>
      (super.noSuchMethod(
            Invocation.getter(#body),
            returnValue: _i6.dummyValue<String>(this, Invocation.getter(#body)),
          )
          as String);

  @override
  int get statusCode =>
      (super.noSuchMethod(Invocation.getter(#statusCode), returnValue: 0)
          as int);

  @override
  Map<String, String> get headers =>
      (super.noSuchMethod(
            Invocation.getter(#headers),
            returnValue: <String, String>{},
          )
          as Map<String, String>);

  @override
  bool get isRedirect =>
      (super.noSuchMethod(Invocation.getter(#isRedirect), returnValue: false)
          as bool);

  @override
  bool get persistentConnection =>
      (super.noSuchMethod(
            Invocation.getter(#persistentConnection),
            returnValue: false,
          )
          as bool);
}
