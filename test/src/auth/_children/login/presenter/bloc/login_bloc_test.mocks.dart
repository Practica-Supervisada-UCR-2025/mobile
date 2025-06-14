// Mocks generated by Mockito 5.4.6 from annotations
// in mobile/test/src/auth/_children/login/presenter/bloc/login_bloc_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;

import 'package:flutter/material.dart' as _i6;
import 'package:mobile/core/core.dart' as _i3;
import 'package:mobile/src/auth/auth.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i5;

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

class _FakeAuthUserInfo_0 extends _i1.SmartFake implements _i2.AuthUserInfo {
  _FakeAuthUserInfo_0(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeAuthTokens_1 extends _i1.SmartFake implements _i2.AuthTokens {
  _FakeAuthTokens_1(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeNotificationSetupResult_2 extends _i1.SmartFake
    implements _i3.NotificationSetupResult {
  _FakeNotificationSetupResult_2(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

/// A class which mocks [LoginRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockLoginRepository extends _i1.Mock implements _i2.LoginRepository {
  MockLoginRepository() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Future<_i2.AuthUserInfo> login(String? username, String? password) =>
      (super.noSuchMethod(
            Invocation.method(#login, [username, password]),
            returnValue: _i4.Future<_i2.AuthUserInfo>.value(
              _FakeAuthUserInfo_0(
                this,
                Invocation.method(#login, [username, password]),
              ),
            ),
          )
          as _i4.Future<_i2.AuthUserInfo>);
}

/// A class which mocks [LocalStorage].
///
/// See the documentation for Mockito's code generation for more information.
class MockLocalStorage extends _i1.Mock implements _i3.LocalStorage {
  MockLocalStorage() {
    _i1.throwOnMissingStub(this);
  }

  @override
  String get accessToken =>
      (super.noSuchMethod(
            Invocation.getter(#accessToken),
            returnValue: _i5.dummyValue<String>(
              this,
              Invocation.getter(#accessToken),
            ),
          )
          as String);

  @override
  String get refreshToken =>
      (super.noSuchMethod(
            Invocation.getter(#refreshToken),
            returnValue: _i5.dummyValue<String>(
              this,
              Invocation.getter(#refreshToken),
            ),
          )
          as String);

  @override
  String get userId =>
      (super.noSuchMethod(
            Invocation.getter(#userId),
            returnValue: _i5.dummyValue<String>(
              this,
              Invocation.getter(#userId),
            ),
          )
          as String);

  @override
  String get username =>
      (super.noSuchMethod(
            Invocation.getter(#username),
            returnValue: _i5.dummyValue<String>(
              this,
              Invocation.getter(#username),
            ),
          )
          as String);

  @override
  String get userEmail =>
      (super.noSuchMethod(
            Invocation.getter(#userEmail),
            returnValue: _i5.dummyValue<String>(
              this,
              Invocation.getter(#userEmail),
            ),
          )
          as String);

  @override
  String get userProfilePicture =>
      (super.noSuchMethod(
            Invocation.getter(#userProfilePicture),
            returnValue: _i5.dummyValue<String>(
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
            returnValue: _i5.dummyValue<String>(
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
  _i4.Future<void> clear() =>
      (super.noSuchMethod(
            Invocation.method(#clear, []),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);
}

/// A class which mocks [TokensRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockTokensRepository extends _i1.Mock implements _i2.TokensRepository {
  MockTokensRepository() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Future<_i2.AuthTokens> getTokens(String? authProviderToken) =>
      (super.noSuchMethod(
            Invocation.method(#getTokens, [authProviderToken]),
            returnValue: _i4.Future<_i2.AuthTokens>.value(
              _FakeAuthTokens_1(
                this,
                Invocation.method(#getTokens, [authProviderToken]),
              ),
            ),
          )
          as _i4.Future<_i2.AuthTokens>);
}

/// A class which mocks [NotificationsService].
///
/// See the documentation for Mockito's code generation for more information.
class MockNotificationsService extends _i1.Mock
    implements _i3.NotificationsService {
  MockNotificationsService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Future<_i3.NotificationSetupResult> setupNotifications({
    _i6.BuildContext? context,
    bool? showDialogIfDenied = true,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#setupNotifications, [], {
              #context: context,
              #showDialogIfDenied: showDialogIfDenied,
            }),
            returnValue: _i4.Future<_i3.NotificationSetupResult>.value(
              _FakeNotificationSetupResult_2(
                this,
                Invocation.method(#setupNotifications, [], {
                  #context: context,
                  #showDialogIfDenied: showDialogIfDenied,
                }),
              ),
            ),
          )
          as _i4.Future<_i3.NotificationSetupResult>);

  @override
  _i4.Future<bool> hasValidSetup() =>
      (super.noSuchMethod(
            Invocation.method(#hasValidSetup, []),
            returnValue: _i4.Future<bool>.value(false),
          )
          as _i4.Future<bool>);

  @override
  _i4.Future<_i3.NotificationSetupResult> setupNotificationsSilently() =>
      (super.noSuchMethod(
            Invocation.method(#setupNotificationsSilently, []),
            returnValue: _i4.Future<_i3.NotificationSetupResult>.value(
              _FakeNotificationSetupResult_2(
                this,
                Invocation.method(#setupNotificationsSilently, []),
              ),
            ),
          )
          as _i4.Future<_i3.NotificationSetupResult>);

  @override
  _i4.Future<_i3.NotificationSetupResult> setupNotificationsInteractive(
    _i6.BuildContext? context,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#setupNotificationsInteractive, [context]),
            returnValue: _i4.Future<_i3.NotificationSetupResult>.value(
              _FakeNotificationSetupResult_2(
                this,
                Invocation.method(#setupNotificationsInteractive, [context]),
              ),
            ),
          )
          as _i4.Future<_i3.NotificationSetupResult>);
}
