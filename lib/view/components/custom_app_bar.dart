import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:translator_app/apptheme/app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? titleWidget;
  final bool showBackButton;
  final VoidCallback? onBackTap;
  final List<Widget>? actions;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color foregroundColor;
  final double elevation;
  final PreferredSizeWidget? bottom;
  final double height;

  const CustomAppBar({
    super.key,
    this.title = '',
    this.titleWidget,
    this.showBackButton = true,
    this.onBackTap,
    this.actions,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor = AppColors.textWhite,
    this.elevation = 0,
    this.bottom,
    this.height = kToolbarHeight,
  });

  @override
  Size get preferredSize => Size.fromHeight(
        height + (bottom?.preferredSize.height ?? 0.0),
      );

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final titleFontSize = mediaQuery.size.width * 0.048;

    return AppBar(
      elevation: elevation,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? AppColors.primary,
      foregroundColor: foregroundColor,
      automaticallyImplyLeading: false,
      leading: showBackButton && Navigator.canPop(context)
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              color: foregroundColor,
              onPressed: onBackTap ?? () => Navigator.pop(context),
            )
          : null,
      title: titleWidget ??
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              color: foregroundColor,
            ),
          ),
      actions: actions,
      bottom: bottom,
    );
  }
}
