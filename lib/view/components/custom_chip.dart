import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:translator_app/apptheme/app_theme.dart';

enum CustomChipVariant {
  filled,
  outlined,
  tonal,
}

enum CustomChipSize {
  small,
  medium,
}

class CustomChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final IconData? icon;
  final VoidCallback? onTap;
  final String? badge;
  final CustomChipVariant variant;
  final CustomChipSize size;
  final Color? activeColor;
  final Color? activeTextColor;

  const CustomChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.icon,
    this.onTap,
    this.badge,
    this.variant = CustomChipVariant.filled,
    this.size = CustomChipSize.medium,
    this.activeColor,
    this.activeTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final primary = activeColor ?? AppColors.primary;
    final onPrimary = activeTextColor ?? AppColors.textWhite;

    final isSmall = size == CustomChipSize.small;
    final fontSize = isSmall
        ? (screenWidth * 0.03).clamp(11.0, 13.0)
        : (screenWidth * 0.035).clamp(13.0, 15.0);

    final iconSize = isSmall ? screenWidth * 0.038 : screenWidth * 0.045;
    final verticalPadding = isSmall ? 6.0 : 8.0;
    final horizontalPadding = isSmall ? screenWidth * 0.03 : screenWidth * 0.04;
    final borderRadius = BorderRadius.circular(screenWidth * 0.04);

    Color backgroundColor;
    Color textColor;
    Border? border;

    if (isSelected) {
      backgroundColor = primary;
      textColor = onPrimary;
      border = Border.all(color: primary, width: 1.2);
    } else {
      switch (variant) {
        case CustomChipVariant.filled:
          backgroundColor = AppColors.surface;
          textColor = AppColors.textPrimary;
          border = Border.all(color: AppColors.border, width: 1.0);
          break;
        case CustomChipVariant.outlined:
          backgroundColor = Colors.transparent;
          textColor = AppColors.textSecondary;
          border = Border.all(color: AppColors.border, width: 1.0);
          break;
        case CustomChipVariant.tonal:
          backgroundColor = primary.withValues(alpha: 0.08);
          textColor = primary;
          border = Border.all(color: primary.withValues(alpha: 0.25), width: 1.0);
          break;
      }
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: borderRadius,
            border: border,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.22),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: iconSize,
                  color: textColor,
                ),
                SizedBox(width: screenWidth * 0.015),
              ],
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: fontSize,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: textColor,
                ),
              ),
              if (badge != null) ...[
                SizedBox(width: screenWidth * 0.015),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? onPrimary.withValues(alpha: 0.25)
                        : primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badge!,
                    style: GoogleFonts.outfit(
                      fontSize: (fontSize * 0.85).clamp(9.0, 11.0),
                      fontWeight: FontWeight.bold,
                      color: isSelected ? onPrimary : primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
