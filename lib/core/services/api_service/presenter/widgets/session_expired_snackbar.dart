import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';

class SessionExpiredSnackBar extends SnackBar {
  SessionExpiredSnackBar({super.key})
    : super(
        content: const Text(
          'Your session has expired. Please log in again.',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        ),
        backgroundColor: AppColors.warning,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 6,
      );
}
