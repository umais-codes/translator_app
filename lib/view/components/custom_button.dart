import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:translator_app/apptheme/app_theme.dart';

enum ButtonVariant {
  filled,
  outlined,
  soft,
  tonal,
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool isLoading;
  final bool isDisabled;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final double? width;
  final double? height;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? fontSize;
  final FontWeight fontWeight;
  final EdgeInsetsGeometry? padding;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = ButtonVariant.filled,
    this.isLoading = false,
    this.isDisabled = false,
    this.leadingIcon,
    this.trailingIcon,
    this.width,
    this.height,
    this.borderRadius,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.fontSize,
    this.fontWeight = FontWeight.w600,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {

    // Responsive scaling based on MediaQuery
    final effectiveHeight = height ?? (812 * 0.062).h;
    final effectiveFontSize = fontSize ?? (375 * 0.039).sp;
    final effectiveBorderRadius = borderRadius ?? (375 * 0.038).r;
    final effectiveIconSize = (375 * 0.05).w;
    final effectivePadding = padding ??
        EdgeInsets.symmetric(
          horizontal: (375 * 0.04).w,
        );

    final effectiveDisabled = isDisabled || isLoading || onPressed == null;

    Color bg;
    Color fg;
    BorderSide borderSide = BorderSide.none;

    switch (variant) {
      case ButtonVariant.filled:
        bg = backgroundColor ?? (effectiveDisabled ? AppColors.border : AppColors.primary);
        fg = textColor ?? AppColors.textWhite;
        break;
      case ButtonVariant.outlined:
        bg = backgroundColor ?? AppColors.transparent;
        fg = textColor ?? (effectiveDisabled ? AppColors.textMuted : AppColors.primary);
        borderSide = BorderSide(
          color: borderColor ?? (effectiveDisabled ? AppColors.border : AppColors.primary),
          width: 1.5.w,
        );
        break;
      case ButtonVariant.soft:
        bg = backgroundColor ??
            (effectiveDisabled ? AppColors.inputBackground : AppColors.lightBlueBackground);
        fg = textColor ?? (effectiveDisabled ? AppColors.textMuted : AppColors.primary);
        break;
      case ButtonVariant.tonal:
        bg = backgroundColor ??
            (effectiveDisabled ? AppColors.inputBackground : AppColors.surface);
        fg = textColor ?? (effectiveDisabled ? AppColors.textMuted : AppColors.textPrimary);
        borderSide = BorderSide(color: AppColors.border, width: 1.w);
        break;
    }

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: effectiveIconSize,
            height: effectiveIconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2.2.w,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          ),
          SizedBox(width: (375 * 0.025).w),
        ] else if (leadingIcon != null) ...[
          Icon(leadingIcon, size: effectiveIconSize, color: fg),
          SizedBox(width: (375 * 0.02).w),
        ],
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: GoogleFonts.outfit(
              fontSize: effectiveFontSize,
              fontWeight: fontWeight,
              color: fg,
              letterSpacing: 0.2.sp,
            ),
          ),
        ),
        if (!isLoading && trailingIcon != null) ...[
          SizedBox(width: (375 * 0.02).w),
          Icon(trailingIcon, size: effectiveIconSize, color: fg),
        ],
      ],
    );

    return SizedBox(
      width: width ?? double.infinity,
      height: effectiveHeight,
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(effectiveBorderRadius),
          side: borderSide,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: effectiveDisabled ? null : onPressed,
          child: Padding(
            padding: effectivePadding,
            child: Center(child: content),
          ),
        ),
      ),
    );
  }
}
