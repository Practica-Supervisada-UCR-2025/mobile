import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF2C6BED);

  static const Color secondary = Color(0xFF4CD964);

  static const Color background = Color(0xFFF5F7FA);

  static const Color textPrimary = Color(0xFF0F1A2A);

  static const Color textSecondary = Color(0xFF7A8CA5);

  static const Color error = Color.fromARGB(255, 219, 56, 80);

  static const Color accent = Color(0xFF9D7FEA);

  static const Color success = Color(0xFF20D5B4);

  static const Color warning = Color(0xFFFFB340);

  static const Color backgroundDark = Color(0xFF1E2533);

  static const Color buttonBackground = Color(0xFFB1C1D8);

  static const Color buttonBackgroundDark = Color(0xFF445473);

  static const Color textFieldFillLight = Color.fromARGB(255, 238, 238, 238); 

  static const Color textFieldFillDark = Color.fromARGB(255, 28, 33, 43);

  static Color getSurfaceColor(Brightness brightness) {
    return brightness == Brightness.dark ? Color(0xFF2D3446) : Colors.white;
  }

  static Color getSecondarySurfaceColor(Brightness brightness) {
    return brightness == Brightness.dark
        ? Color(0xFF353C4F)
        : Color(0xFFF0F2F5);
  }

  static Color getDisabledPostButtonColor(Brightness brightness) {
  return brightness == Brightness.dark
      ? const Color(0xFF3A5383)
      : const Color.fromARGB(255, 168, 194, 252);
}
}
