import 'package:flutter/material.dart';
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
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    // Responsive scaling based on MediaQuery
    final effectiveHeight = height ?? (screenHeight * 0.062).clamp(48.0, 60.0);
    final effectiveFontSize = fontSize ?? (screenWidth * 0.039).clamp(14.0, 17.0);
    final effectiveBorderRadius = borderRadius ?? (screenWidth * 0.038).clamp(12.0, 18.0);
    final effectiveIconSize = (screenWidth * 0.05).clamp(18.0, 24.0);
    final effectivePadding = padding ??
        EdgeInsets.symmetric(
          horizontal: (screenWidth * 0.04).clamp(12.0, 20.0),
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
        bg = backgroundColor ?? Colors.transparent;
        fg = textColor ?? (effectiveDisabled ? AppColors.textMuted : AppColors.primary);
        borderSide = BorderSide(
          color: borderColor ?? (effectiveDisabled ? AppColors.border : AppColors.primary),
          width: 1.5,
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
        borderSide = const BorderSide(color: AppColors.border, width: 1);
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
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          ),
          SizedBox(width: screenWidth * 0.025),
        ] else if (leadingIcon != null) ...[
          Icon(leadingIcon, size: effectiveIconSize, color: fg),
          SizedBox(width: screenWidth * 0.02),
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
              letterSpacing: 0.2,
            ),
          ),
        ),
        if (!isLoading && trailingIcon != null) ...[
          SizedBox(width: screenWidth * 0.02),
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
