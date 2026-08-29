import 'package:flutter/material.dart';

class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Dynamic Primary & Brand Colors
  static Color primary = const Color(0xFF2563EB); // Modern Cobalt Blue
  static Color primaryDark = const Color(0xFF1D4ED8);
  static Color primaryLight = const Color(0xFF60A5FA);
  static Color primaryAccent = const Color(0xFF3B82F6);
  static Color accent = const Color(0xFF0EA5E9);
  static Color accentLight = const Color(0xFFBAE6FD);
  static Color lightBlueBackground = const Color(0xFFEFF6FF);
  static Color shadowPrimary = const Color(0x2E2563EB);

  // Background & Surface Colors
  static const Color scaffoldBackground = Color(0xFFF8FAFC);
  static const Color authBackground = Color(0xFFF0F6FF);
  static const Color surface = Colors.white;
  static const Color cardBackground = Colors.white;
  static const Color inputBackground = Color(0xFFF1F5F9);
  static const Color containerBackground = Color(0xFFF1F5F9);
  static const Color lightRedBackground = Color(0xFFFEF2F2);
  static const Color lightGreenBackground = Color(0xFFECFDF5);
  static const Color lightBlueCard = Color(0xFFE0F2FE);

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400
  static const Color textWhite = Colors.white;

  // Status & Feedback Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
  static const Color micActive = Color(0xFFFF4B4B);

  // Border & Shadow Colors
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFEEF2F6);
  static const Color divider = Color(0xFFE2E8F0);
  static const Color shadow = Color(0x0A0F172A);

  /// Dynamically updates the active palette across the entire application
  static void updatePalette(Color color) {
    primary = color;
    primaryDark = Color.lerp(color, Colors.black, 0.22) ?? color;
    primaryLight = Color.lerp(color, Colors.white, 0.35) ?? color;
    primaryAccent = Color.lerp(color, Colors.white, 0.15) ?? color;
    accent = Color.lerp(color, Colors.white, 0.2) ?? color;
    accentLight = Color.lerp(color, Colors.white, 0.7) ?? color;
    lightBlueBackground = Color.lerp(color, Colors.white, 0.92) ?? const Color(0xFFEFF6FF);
    shadowPrimary = color.withValues(alpha: 0.22);
  }
}
