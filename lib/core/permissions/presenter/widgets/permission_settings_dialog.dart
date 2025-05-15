import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionSettingsDialog {
  static void show(BuildContext context, String resource) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permission Denied'),
          content: Text(
            'You have permanently denied permission to access the $resource. '
            'You can enable it in the app settings.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                context.pop();
              },
            ),
            TextButton(
              child: const Text('Go to Settings'),
              onPressed: () {
                context.pop();
                openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }
}
