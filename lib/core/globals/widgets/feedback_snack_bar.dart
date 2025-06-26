import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';

class FeedbackSnackBar {
  static void showSuccess(
    BuildContext context,
    String message, {
    IconData? icon,
  }) {
    _show(
      context,
      message,
      backgroundColor: AppColors.success,
      icon: icon ?? Icons.check_circle_outline,
    );
  }

  static void showError(
    BuildContext context,
    String message, {
    IconData? icon,
  }) {
    _show(
      context,
      message,
      backgroundColor: AppColors.error,
      icon: icon ?? Icons.error_outline,
    );
  }

  static void showWarning(
    BuildContext context,
    String message, {
    IconData? icon,
  }) {
    _show(
      context,
      message,
      backgroundColor: AppColors.warning,
      icon: icon ?? Icons.warning_amber_outlined,
    );
  }

  static void _show(
    BuildContext context,
    String message, {
    required Color backgroundColor,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
  }
}
