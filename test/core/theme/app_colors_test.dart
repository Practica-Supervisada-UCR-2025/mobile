import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_colors.dart';

void main() {
  group('AppColors', () {
    test('Color constants have correct values', () {
      expect(AppColors.primary, const Color(0xFF00AAEE));
      expect(AppColors.secondary, const Color(0xFF42BD60));
      expect(AppColors.background, const Color(0xFFF5F7FA));
      expect(AppColors.textPrimary, const Color(0xFF1A1A1A));
      expect(AppColors.textSecondary, const Color(0xFF6C7B8E));
      expect(AppColors.error, const Color(0xFFE53935));
      expect(AppColors.accent, const Color(0xFF9D7FEA));
      expect(AppColors.success, const Color(0xFF28A745));
      expect(AppColors.warning, const Color(0xFFFFC107));
      expect(AppColors.backgroundDark, const Color(0xFF121212));
      expect(AppColors.buttonBackground, const Color(0xFFD3DCE5));
      expect(AppColors.buttonBackgroundDark, const Color(0xFF33425C));
      expect(
        AppColors.getDisabledPostButtonColor(Brightness.light),
        const Color(0xFFC0D2F4),
      );
      expect(
        AppColors.getDisabledPostButtonColor(Brightness.dark),
        const Color(0xFF4A4A4A),
      );
    });

    test('getSurfaceColor returns correct color for Brightness.light', () {
      final surfaceColor = AppColors.getSurfaceColor(Brightness.light);
      expect(surfaceColor, Colors.white);
    });

    test('getSurfaceColor returns correct color for Brightness.dark', () {
      final surfaceColor = AppColors.getSurfaceColor(Brightness.dark);
      expect(surfaceColor, const Color(0xFF1E1E1E));
    });

    test(
      'getSecondarySurfaceColor returns correct color for Brightness.light',
      () {
        final secondarySurfaceColor = AppColors.getSecondarySurfaceColor(
          Brightness.light,
        );
        expect(secondarySurfaceColor, const Color(0xFFF0F2F5));
      },
    );

    test(
      'getSecondarySurfaceColor returns correct color for Brightness.dark',
      () {
        final secondarySurfaceColor = AppColors.getSecondarySurfaceColor(
          Brightness.dark,
        );
        expect(secondarySurfaceColor, const Color(0xFF2C2C2C));
      },
    );
  });
}
