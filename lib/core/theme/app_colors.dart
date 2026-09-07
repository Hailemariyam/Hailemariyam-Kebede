import 'package:flutter/material.dart';

/// M-PESA brand palette.
///
/// Primary brand colour — HEX #fe0000 · rgb(254, 0, 0) · Tailwind red-600.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFFFE0000);
  static const Color primaryDark = Color(0xFFC80000);
  static const Color primaryLight = Color(0xFFFF4D4D);

  static const Color scaffoldBackground = Color(0xFFF5F5F7);
  static const Color surface = Colors.white;

  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textOnPrimary = Colors.white;

  static const Color divider = Color(0xFFE6E6E9);
  static const Color success = Color(0xFF1FA463);
  static const Color error = primary;
}
