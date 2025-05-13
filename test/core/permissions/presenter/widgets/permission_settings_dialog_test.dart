import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/core.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPermissionHandler extends Fake
    with MockPlatformInterfaceMixin
    implements PermissionHandlerPlatform {
  bool wasCalled = false;

  @override
  Future<bool> openAppSettings() async {
    wasCalled = true;
    return true;
  }
}

void main() {
  late MockPermissionHandler mockHandler;

  setUp(() {
    mockHandler = MockPermissionHandler();
    PermissionHandlerPlatform.instance = mockHandler;
  });

  group('Request Permission From Settings Dialog', () {
    testWidgets('PermissionSettingsDialog shows and "Cancel" closes it', (
      WidgetTester tester,
    ) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) {
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      PermissionSettingsDialog.show(context, 'Camera');
                    },
                    child: const Text('Show Dialog'),
                  ),
                ),
              );
            },
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Permission Denied'), findsOneWidget);
      expect(find.text('Go to Settings'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Permission Denied'), findsNothing);
    });

    testWidgets(
      'PermissionSettingsDialog "Go to Settings" calls openAppSettings',
      (WidgetTester tester) async {
        final router = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) {
                return Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        PermissionSettingsDialog.show(context, 'Microphone');
                      },
                      child: const Text('Show Dialog'),
                    ),
                  ),
                );
              },
            ),
          ],
        );

        await tester.pumpWidget(MaterialApp.router(routerConfig: router));

        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Go to Settings'));
        await tester.pumpAndSettle();

        expect(mockHandler.wasCalled, isTrue);
      },
    );
  });
}
