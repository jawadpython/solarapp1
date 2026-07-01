import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF3A80BA);
  static const Color primaryDark = Color(0xFF28A3A3);
  static const Color primaryLight = Color(0xFFE63B3B);

  static const Color background = Color(0xFFFAFAFA);
  /// True black background for dark mode - comfortable for eyes.
  static const Color backgroundDark = Color(0xFF0D0D0D);

  static const Color surface = Color(0xFFFFFFFF);
  /// Card/surface color in dark mode (slightly lighter than background).
  static const Color surfaceDark = Color(0xFF1C1C1E);
  /// Elevated surfaces (dialogs, menus) in dark mode.
  static const Color surfaceDarkElevated = Color(0xFF2C2C2E);

  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB3B3B3);

  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);

  /// Success green readable on dark backgrounds (dark mode).
  static const Color successOnDark = Color(0xFF81C784);
  /// Info blue readable on dark backgrounds (dark mode).
  static const Color infoOnDark = Color(0xFF64B5F6);
  /// Warning orange readable on dark backgrounds (dark mode).
  static const Color warningOnDark = Color(0xFFFFB74D);
}

