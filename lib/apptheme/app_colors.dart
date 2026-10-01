import 'package:flutter/material.dart';

class AppPalette {
  final String name;
  final Color color;
  final String description;

  const AppPalette({
    required this.name,
    required this.color,
    required this.description,
  });
}

/// Single color source for the app. Screens should read these tokens
/// instead of declaring their own [Color] values.
class AppColors {
  AppColors._();

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);

  static const Color cobaltSapphire = Color(0xFF2563EB);
  static const Color oceanIndigo = Color(0xFF1D4ED8);
  static const Color azureTech = Color(0xFF0070F3);
  static const Color emeraldAccent = Color(0xFF10B981);

  static const List<AppPalette> palettes = [
    AppPalette(
      name: 'Cobalt Sapphire (Default)',
      color: cobaltSapphire,
      description: 'Modern, crisp, eye-friendly sapphire blue',
    ),
    AppPalette(
      name: 'Ocean Indigo',
      color: oceanIndigo,
      description: 'Deep royal navy blue with high contrast',
    ),
    AppPalette(
      name: 'Azure Tech Blue',
      color: azureTech,
      description: 'Vibrant azure tech aesthetic',
    ),
    AppPalette(
      name: 'Emerald Accent',
      color: emeraldAccent,
      description: 'Refreshing emerald feedback green',
    ),
  ];

  static Color colorForPalette(String name) {
    for (final palette in palettes) {
      if (palette.name == name) return palette.color;
    }
    return cobaltSapphire;
  }

  static Color primary = cobaltSapphire;
  static Color primaryDark = Color(0xFF1D4ED8);
  static Color primaryLight = Color(0xFF60A5FA);
  static Color primaryAccent = Color(0xFF3B82F6);
  static Color accent = Color(0xFF0EA5E9);
  static Color accentLight = Color(0xFFBAE6FD);
  static Color lightBlueBackground = Color(0xFFEFF6FF);
  static Color shadowPrimary = Color(0x2E2563EB);

  static const Color scaffoldBackground = Color(0xFFF8FAFC);
  static const Color authBackground = Color(0xFFF0F6FF);
  static const Color surface = white;
  static const Color cardBackground = white;
  static const Color inputBackground = Color(0xFFF1F5F9);
  static const Color containerBackground = Color(0xFFF1F5F9);
  static const Color lightRedBackground = Color(0xFFFEF2F2);
  static const Color lightGreenBackground = Color(0xFFECFDF5);
  static const Color lightBlueCard = Color(0xFFE0F2FE);

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textWhite = white;

  static const Color success = emeraldAccent;
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color favorite = Color(0xFFFFC107);
  static const Color info = Color(0xFF3B82F6);
  static const Color micActive = Color(0xFFFF4B4B);

  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFEEF2F6);
  static const Color divider = Color(0xFFE2E8F0);
  static const Color shadow = Color(0x0A0F172A);

  static void updatePalette(Color color) {
    primary = color;
    primaryDark = Color.lerp(color, black, 0.22) ?? color;
    primaryLight = Color.lerp(color, white, 0.35) ?? color;
    primaryAccent = Color.lerp(color, white, 0.15) ?? color;
    accent = Color.lerp(color, white, 0.2) ?? color;
    accentLight = Color.lerp(color, white, 0.7) ?? color;
    lightBlueBackground = Color.lerp(color, white, 0.92) ?? lightBlueBackground;
    shadowPrimary = color.withValues(alpha: 0.22);
  }
}
