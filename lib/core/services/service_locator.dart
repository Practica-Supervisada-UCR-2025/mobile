import 'package:flutter/material.dart';
import 'package:mobile/src/auth/_children/_children.dart';

class ServiceLocator {
  static ServiceLocator _instance = ServiceLocator._internal();

  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  static void overrideInstance(ServiceLocator testInstance) {
    _instance = testInstance;
  }

  LogoutBloc? logoutBloc;
  GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;
}
