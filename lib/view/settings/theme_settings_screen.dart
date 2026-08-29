import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:translator_app/apptheme/app_theme.dart';
import 'package:translator_app/view/components/custom_app_bar.dart';
import 'package:translator_app/viewmodel/settings_viewmodel.dart';

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  static const List<Map<String, dynamic>> _palettes = [
    {
      'name': 'Cobalt Sapphire (Default)',
      'color': Color(0xFF2563EB),
      'desc': 'Modern, crisp, eye-friendly sapphire blue',
    },
    {
      'name': 'Ocean Indigo',
      'color': Color(0xFF1D4ED8),
      'desc': 'Deep royal navy blue with high contrast',
    },
    {
      'name': 'Azure Tech Blue',
      'color': Color(0xFF0070F3),
      'desc': 'Vibrant azure tech aesthetic',
    },
    {
      'name': 'Emerald Accent',
      'color': Color(0xFF10B981),
      'desc': 'Refreshing emerald feedback green',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SettingsViewModel>();
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final horizontalPadding = screenWidth * 0.045;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'App Theme',
        showBackButton: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: screenHeight * 0.02,
          ),
          children: [
            // Mode Section
            Text(
              'Appearance Mode',
              style: GoogleFonts.outfit(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),

            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _buildThemeRadioTile(
                    'Light Mode',
                    Icons.light_mode_rounded,
                    'Crisp bright interface with high contrast',
                    vm,
                    screenWidth,
                  ),
                  const Divider(height: 1, color: AppColors.borderLight),
                  _buildThemeRadioTile(
                    'Dark Mode',
                    Icons.dark_mode_rounded,
                    'Easier on the eyes in low light (Coming Soon)',
                    vm,
                    screenWidth,
                    enabled: false,
                  ),
                  const Divider(height: 1, color: AppColors.borderLight),
                  _buildThemeRadioTile(
                    'System Default',
                    Icons.brightness_auto_rounded,
                    'Follow device system settings',
                    vm,
                    screenWidth,
                  ),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.03),

            // Color Palette Section
            Text(
              'Accent Color Palette',
              style: GoogleFonts.outfit(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),

            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: _palettes.map((p) {
                  final isSelected = vm.selectedPalette == p['name'];
                  return ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: 4,
                    ),
                    leading: Container(
                      width: screenWidth * 0.1,
                      height: screenWidth * 0.1,
                      decoration: BoxDecoration(
                        color: p['color'] as Color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (p['color'] as Color).withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    title: Text(
                      p['name'] as String,
                      style: GoogleFonts.outfit(
                        fontSize: screenWidth * 0.038,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      p['desc'] as String,
                      style: GoogleFonts.outfit(
                        fontSize: screenWidth * 0.03,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle_rounded, color: AppColors.primary)
                        : null,
                    onTap: () {
                      vm.setPalette(p['name'] as String, color: p['color'] as Color);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${p['name']} applied!'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeRadioTile(
    String title,
    IconData icon,
    String subtitle,
    SettingsViewModel vm,
    double screenWidth, {
    bool enabled = true,
  }) {
    final isSelected = vm.selectedTheme == title;
    return ListTile(
      enabled: enabled,
      contentPadding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: 2,
      ),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: enabled ? AppColors.lightBlueBackground : AppColors.inputBackground,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: enabled ? AppColors.primary : AppColors.textMuted,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: screenWidth * 0.038,
          fontWeight: FontWeight.w600,
          color: enabled ? AppColors.textPrimary : AppColors.textMuted,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.outfit(
          fontSize: screenWidth * 0.03,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.radio_button_checked, color: AppColors.primary)
          : const Icon(Icons.radio_button_off, color: AppColors.border),
      onTap: enabled ? () => vm.setTheme(title) : null,
    );
  }
}
