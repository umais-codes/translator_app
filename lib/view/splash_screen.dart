import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:translator_app/apptheme/app_theme.dart';
import 'package:translator_app/core/router/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    Timer(const Duration(milliseconds: 2800), () {
      if (mounted) {
        context.go(AppRoutes.translate);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final logoSize = 143.w;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Subtle Ambient Top Gradient Blob
          Positioned(
            top: -81.h,
            left: -75.w,
            child: Container(
              width: 338.w,
              height: 338.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.lightBlueBackground.withValues(alpha: 0.6),
              ),
            ),
          ),

          // Main Center Content
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Premium App Logo Card
                    Container(
                      width: logoSize,
                      height: logoSize,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            blurRadius: 30.r,
                            offset: Offset(0, 10.h),
                            spreadRadius: 2.r,
                          ),
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 10.r,
                            offset: Offset(0, 2.h),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30.r),
                        child: Image.asset(
                          'assets/images/app_logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    SizedBox(height: 28.h),

                    // App Title
                    Text(
                      'Translator',
                      style: GoogleFonts.outfit(
                        fontSize: 30.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1.sp,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    SizedBox(height: 7.h),

                    // Tagline
                    Text(
                      'AI-Powered Global Communication',
                      style: GoogleFonts.outfit(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Loading & Version Info
          Positioned(
            bottom: 49.h,
            left: 0.w,
            right: 0.w,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 3.w,
                      color: AppColors.primary,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Version 1.0.0 • On-Device & Cloud AI',
                    style: GoogleFonts.outfit(
                      fontSize: 11.sp,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
