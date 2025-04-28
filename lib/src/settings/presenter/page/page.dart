import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/src/settings/presenter/widgets/widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text(
          'Settings',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.textPrimary,
          ),
        ),
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(
          color: AppColors.textPrimary,
        ),
        shape: const Border(
          bottom: BorderSide(color: Colors.black12),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Spacer(flex: 2),
                const Center(
                  child: Text(
                    'Settings screen',
                    style: TextStyle(
                      fontSize: 20,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(flex: 3),
                const LogoutButton(),
              ],
            ),
          );
        },
      ),
    );
  }
}
