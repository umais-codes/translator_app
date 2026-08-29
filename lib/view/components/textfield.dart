import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:translator_app/apptheme/app_theme.dart';

class CustomTextField extends StatelessWidget {
  final String? label;
  final String hintText;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final IconData? prefixIcon;
  final Widget? prefixWidget;
  final IconData? suffixIcon;
  final Widget? suffixWidget;
  final VoidCallback? onSuffixTap;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final bool showClearButton;
  final bool readOnly;
  final bool enabled;
  final int maxLines;
  final int minLines;
  final FocusNode? focusNode;
  final EdgeInsetsGeometry? contentPadding;

  const CustomTextField({
    super.key,
    this.label,
    required this.hintText,
    required this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.prefixIcon,
    this.prefixWidget,
    this.suffixIcon,
    this.suffixWidget,
    this.onSuffixTap,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.showClearButton = false,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines = 1,
    this.focusNode,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    final labelFontSize = (screenWidth * 0.036).clamp(13.0, 15.0);
    final inputFontSize = (screenWidth * 0.038).clamp(14.0, 16.0);
    final hintFontSize = (screenWidth * 0.036).clamp(13.0, 15.0);
    final borderRadius = (screenWidth * 0.036).clamp(12.0, 16.0);
    final iconSize = (screenWidth * 0.05).clamp(18.0, 22.0);

    final responsivePadding = contentPadding ??
        EdgeInsets.symmetric(
          vertical: (screenHeight * 0.016).clamp(12.0, 18.0),
          horizontal: (screenWidth * 0.04).clamp(14.0, 18.0),
        );

    final obscureNotifier = ValueNotifier<bool>(obscureText);

    return ValueListenableBuilder<bool>(
      valueListenable: obscureNotifier,
      builder: (context, isObscured, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label != null && label!.isNotEmpty) ...[
              Text(
                label!,
                style: GoogleFonts.outfit(
                  fontSize: labelFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: screenHeight * 0.008),
            ],
            TextFormField(
              controller: controller,
              focusNode: focusNode,
              obscureText: isObscured,
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              validator: validator,
              onChanged: onChanged,
              onFieldSubmitted: onFieldSubmitted,
              readOnly: readOnly,
              enabled: enabled,
              maxLines: isObscured ? 1 : maxLines,
              minLines: minLines,
              style: GoogleFonts.outfit(
                fontSize: inputFontSize,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: GoogleFonts.outfit(
                  color: AppColors.textMuted,
                  fontSize: hintFontSize,
                ),
                filled: true,
                fillColor: enabled ? AppColors.surface : AppColors.inputBackground,
                contentPadding: responsivePadding,
                prefixIcon: prefixWidget ??
                    (prefixIcon != null
                        ? Icon(prefixIcon, color: AppColors.primary, size: iconSize)
                        : null),
                suffixIcon: _buildSuffix(obscureNotifier, isObscured, iconSize),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: const BorderSide(
                    color: AppColors.error,
                    width: 1.5,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: const BorderSide(
                    color: AppColors.error,
                    width: 2,
                  ),
                ),
                errorStyle: GoogleFonts.outfit(
                  color: AppColors.error,
                  fontSize: (screenWidth * 0.03).clamp(11.0, 13.0),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget? _buildSuffix(
    ValueNotifier<bool> obscureNotifier,
    bool isObscured,
    double iconSize,
  ) {
    if (obscureText) {
      return IconButton(
        icon: Icon(
          isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: AppColors.textSecondary,
          size: iconSize,
        ),
        onPressed: () {
          obscureNotifier.value = !obscureNotifier.value;
        },
      );
    }

    if (showClearButton && controller.text.isNotEmpty) {
      return IconButton(
        icon: Icon(Icons.clear_rounded, color: AppColors.textSecondary, size: iconSize * 0.9),
        onPressed: () {
          controller.clear();
          if (onChanged != null) {
            onChanged!('');
          }
        },
      );
    }

    if (suffixWidget != null) {
      return suffixWidget;
    }

    if (suffixIcon != null) {
      return GestureDetector(
        onTap: onSuffixTap,
        child: Icon(suffixIcon, color: AppColors.primary, size: iconSize),
      );
    }

    return null;
  }
}
