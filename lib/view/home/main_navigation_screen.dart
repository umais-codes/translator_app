import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:translator_app/apptheme/app_theme.dart';
import 'package:translator_app/core/router/app_routes.dart';
import 'package:translator_app/view/components/custom_app_bar.dart';
import 'package:translator_app/view/components/custom_bottom_nav.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _getTitle(navigationShell.currentIndex),
        showBackButton: false,
        actions: [
          IconButton(
            icon: Icon(
              Icons.history_rounded,
              color: AppColors.textWhite,
              size: 23.w,
            ),
            tooltip: 'History & Favorites',
            onPressed: () => context.push(AppRoutes.history),
          ),
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: AppColors.textWhite,
              size: 23.w,
            ),
            tooltip: 'Settings',
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: navigationShell,
      bottomNavigationBar: CustomBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(index),
      ),
    );
  }

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'Translator';
      case 1:
        return 'Conversation';
      case 2:
        return 'Dictionary';
      case 3:
        return 'Tools & Features';
      default:
        return 'Translator';
    }
  }
}
