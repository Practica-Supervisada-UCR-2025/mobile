import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/services/service_locator.dart';
import 'package:mockito/annotations.dart';
import 'package:mobile/src/auth/_children/_children.dart';

@GenerateMocks([LogoutBloc])
import 'service_locator_test.mocks.dart';

void main() {
  group('ServiceLocator Tests', () {
    late ServiceLocator serviceLocator;
    late MockLogoutBloc mockLogoutBloc;

    setUp(() {
      serviceLocator = ServiceLocator();
      mockLogoutBloc = MockLogoutBloc();
    });

    tearDown(() {
      serviceLocator.logoutBloc = null;
      serviceLocator.scaffoldMessengerKey = null;
    });

    test('should return the same instance (Singleton)', () {
      final instance1 = ServiceLocator();
      final instance2 = ServiceLocator();

      expect(instance1, equals(instance2));
      expect(identical(instance1, instance2), isTrue);
    });

    test('should allow setting and getting logoutBloc', () {
      serviceLocator.logoutBloc = mockLogoutBloc;

      expect(serviceLocator.logoutBloc, equals(mockLogoutBloc));
      expect(serviceLocator.logoutBloc, isA<LogoutBloc>());
    });

    test('should allow setting and getting scaffoldMessengerKey', () {
      final key = GlobalKey<ScaffoldMessengerState>();

      serviceLocator.scaffoldMessengerKey = key;

      expect(serviceLocator.scaffoldMessengerKey, equals(key));
      expect(
        serviceLocator.scaffoldMessengerKey,
        isA<GlobalKey<ScaffoldMessengerState>>(),
      );
    });

    test('should initialize with null values', () {
      final freshInstance = ServiceLocator();

      expect(freshInstance.logoutBloc, isNull);
      expect(freshInstance.scaffoldMessengerKey, isNull);
    });

    test('should allow instance override for testing', () {
      final originalInstance = ServiceLocator();
      originalInstance.logoutBloc = mockLogoutBloc;

      final testInstance = ServiceLocator();

      ServiceLocator.overrideInstance(testInstance);
      final currentInstance = ServiceLocator();

      expect(currentInstance, equals(testInstance));
      expect(identical(currentInstance, testInstance), isTrue);
    });

    test('should preserve state after override', () {
      final testInstance = ServiceLocator();
      final testKey = GlobalKey<ScaffoldMessengerState>();
      testInstance.logoutBloc = mockLogoutBloc;
      testInstance.scaffoldMessengerKey = testKey;

      ServiceLocator.overrideInstance(testInstance);
      final instance1 = ServiceLocator();
      final instance2 = ServiceLocator();

      expect(instance1.logoutBloc, equals(mockLogoutBloc));
      expect(instance1.scaffoldMessengerKey, equals(testKey));
      expect(instance2.logoutBloc, equals(mockLogoutBloc));
      expect(instance2.scaffoldMessengerKey, equals(testKey));
      expect(identical(instance1, instance2), isTrue);
    });
  });
}
