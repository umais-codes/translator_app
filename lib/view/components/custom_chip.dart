import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  final bool isExpanded;

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
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {

    final primary = activeColor ?? AppColors.primary;
    final onPrimary = activeTextColor ?? AppColors.textWhite;

    final isSmall = size == CustomChipSize.small;
    final fontSize = isSmall ? 11.sp : 13.sp;
    final iconSize = isSmall ? 14.w : 17.w;
    final verticalPadding = isSmall ? 6.h : 8.h;
    final horizontalPadding = isSmall ? 11.w : 15.w;
    final borderRadius = BorderRadius.circular(15.r);

    Color backgroundColor;
    Color textColor;
    Border? border;

    if (isSelected) {
      backgroundColor = primary;
      textColor = onPrimary;
      border = Border.all(color: primary, width: 1.w);
    } else {
      switch (variant) {
        case CustomChipVariant.filled:
          backgroundColor = AppColors.surface;
          textColor = AppColors.textPrimary;
          border = Border.all(color: AppColors.border, width: 1.w);
          break;
        case CustomChipVariant.outlined:
          backgroundColor = AppColors.transparent;
          textColor = AppColors.textSecondary;
          border = Border.all(color: AppColors.border, width: 1.w);
          break;
        case CustomChipVariant.tonal:
          backgroundColor = primary.withValues(alpha: 0.08);
          textColor = primary;
          border = Border.all(color: primary.withValues(alpha: 0.25), width: 1.w);
          break;
      }
    }

    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          alignment: isExpanded ? Alignment.center : null,
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
                      blurRadius: 6.r,
                      offset: Offset(0, 2.h),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: iconSize,
                  color: textColor,
                ),
                SizedBox(width: 6.w),
              ],
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: fontSize,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: textColor,
                ),
              ),
              if (badge != null) ...[
                SizedBox(width: 6.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? onPrimary.withValues(alpha: 0.25)
                        : primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    badge!,
                    style: GoogleFonts.outfit(
                      fontSize: (fontSize * 0.85).clamp(9.sp, 11.sp),
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
