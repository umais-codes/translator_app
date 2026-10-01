import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:translator_app/apptheme/app_theme.dart';
import 'package:translator_app/view/components/custom_app_bar.dart';
import 'package:translator_app/viewmodel/settings_viewmodel.dart';

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SettingsViewModel>();

    final horizontalPadding = (375 * 0.045).w;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'App Theme',
        showBackButton: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: (812 * 0.02).h,
          ),
          children: [
            // Mode Section
            Text(
              'Appearance Mode',
              style: GoogleFonts.outfit(
                fontSize: (375 * 0.04).sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: (812 * 0.01).h),

            Material(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20.r),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
                side: const BorderSide(color: AppColors.border),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  _buildThemeRadioTile(
                    'Light Mode',
                    Icons.light_mode_rounded,
                    'Bright interface with high contrast',
                    vm,
                  ),
                ],
              ),
            ),

            SizedBox(height: (812 * 0.03).h),

            // Color Palette Section
            Text(
              'Accent Color Palette',
              style: GoogleFonts.outfit(
                fontSize: (375 * 0.04).sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: (812 * 0.01).h),

            Material(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20.r),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
                side: const BorderSide(color: AppColors.border),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: AppColors.palettes.map((palette) {
                  final isSelected = vm.selectedPalette == palette.name;
                  return ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: (375 * 0.04).w,
                      vertical: 4.h,
                    ),
                    leading: Container(
                      width: (375 * 0.1).w,
                      height: (375 * 0.1).w,
                      decoration: BoxDecoration(
                        color: palette.color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: palette.color.withValues(alpha: 0.3),
                            blurRadius: 6.r,
                            offset: Offset(0, 2.h),
                          ),
                        ],
                      ),
                    ),
                    title: Text(
                      palette.name,
                      style: GoogleFonts.outfit(
                        fontSize: (375 * 0.038).sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      palette.description,
                      style: GoogleFonts.outfit(
                        fontSize: (375 * 0.03).sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle_rounded, color: AppColors.primary)
                        : null,
                    onTap: () {
                      vm.setPalette(palette.name, color: palette.color);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${palette.name} applied!'),
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
    SettingsViewModel vm, {
    bool enabled = true,
  }) {
    final isSelected = vm.selectedTheme == title;
    return ListTile(
      enabled: enabled,
      contentPadding: EdgeInsets.symmetric(
        horizontal: (375 * 0.04).w,
        vertical: 2.h,
      ),
      leading: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: enabled ? AppColors.lightBlueBackground : AppColors.inputBackground,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(
          icon,
          color: enabled ? AppColors.primary : AppColors.textMuted,
          size: 20.w,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: (375 * 0.038).sp,
          fontWeight: FontWeight.w600,
          color: enabled ? AppColors.textPrimary : AppColors.textMuted,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.outfit(
          fontSize: (375 * 0.03).sp,
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
