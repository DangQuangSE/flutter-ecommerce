import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color primary = Color(0xFF1A73E8);
  static const Color primaryDark = Color(0xFF1557B0);
  static const Color primaryLight = Color(0xFF63A4FF);
  static const Color accent = Color(0xFFFF6D00);
  static const Color accentLight = Color(0xFFFF9E40);

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE0E0E0);

  static bool isDarkMode = false;

  static Color get textPrimary =>
      isDarkMode ? Colors.white : const Color(0xFF1A1A2E);
  static Color get textSecondary =>
      isDarkMode ? const Color(0xFFE2E8F0) : const Color(0xFF6B7280);
  static const Color textHint = Color(0xFFADB5BD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);
  static const Color info = Color(0xFF3498DB);

  // Customizer
  static const Color canvasLight = Color(0xFFF3F3F8);
  static const Color borderGray = Color(0xFFC1C6D7);
  static const Color canvasGradientStart = Color(0xFFFFFFFF);
  static const Color canvasGradientEnd = Color(0xFFE8E8EE);
  static const Color accentOrange = Color(0xFFFE9400);
  static const Color accentPink = Color(0xFFEC407A);
  static const Color accentYellow = Color(0xFFFFEB3B);
  static const Color accentBlue = Color(0xFF0058BC);
  static const Color accentRed = Color(0xFFBA1A1A);
  static const Color darkText = Color(0xFF1A1C1F);
  static const Color selectedBg = Color(0xFFEDEDF2);

  // Input / border
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color inputBgLight = Color(0xFFF8F9FC);
}
