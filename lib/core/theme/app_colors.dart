import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF236BEB);

  static const Color secondary = Color(0xFF42BD60);

  static const Color background = Color(0xFFF5F7FA);

  static const Color textPrimary = Color(0xFF1A1A1A);

  static const Color textSecondary = Color(0xFF6C7B8E);

  static const Color error = Color(0xFFE53935);

  static const Color accent = Color(0xFF9D7FEA);

  static const Color success = Color(0xFF28A745);

  static const Color warning = Color(0xFFFFC107);

  static const Color backgroundDark = Color(0xFF121212);

  static const Color buttonBackground = Color(0xFFD3DCE5);

  static const Color buttonBackgroundDark = Color(0xFF33425C);

  static Color getSurfaceColor(Brightness brightness) {
    return brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white;
  }

  static Color getSecondarySurfaceColor(Brightness brightness) {
    return brightness == Brightness.dark
        ? const Color(0xFF2C2C2C)
        : const Color(0xFFF0F2F5);
  }

  static Color getDisabledPostButtonColor(Brightness brightness) {
    return brightness == Brightness.dark
        ? const Color(0xFF4A4A4A)
        : const Color(0xFFC0D2F4);
  }
}