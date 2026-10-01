import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:translator_app/apptheme/app_theme.dart';
import 'package:translator_app/view/ai/ai_tools_screen.dart';
import 'package:translator_app/view/camera.dart';
import 'package:translator_app/view/file_translate.dart';
import 'package:translator_app/view/history/translation_history_screen.dart';
import 'package:translator_app/view/settings.dart';
import 'package:translator_app/viewmodel/main_nav_viewmodel.dart';

class MoreFunScreen extends StatelessWidget {
  const MoreFunScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final horizontalPadding = (375 * 0.045).w;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: (812 * 0.02).h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Smart Tools',
            style: GoogleFonts.outfit(
              fontSize: (375 * 0.058).sp,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.6.sp,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            'AI-powered language suite',
            style: GoogleFonts.outfit(
              fontSize: (375 * 0.035).sp,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: (812 * 0.022).h),

          // 1. HERO BENTO CARD: Camera & OCR Live Translator
          _buildHeroCard(
            context,
            title: 'Camera & OCR Translator',
            subtitle:
                'Scan printed text from signs, menus, and documents with instant optical recognition.',
            icon: Icons.camera_alt_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CameraScreen(),
                ),
              );
            },
          ),

          SizedBox(height: (812 * 0.016).h),

          // 2. AI LANGUAGE STUDIO CARD
          _buildBottomCard(
            context,
            title: 'AI Language Intelligence',
            subtitle: 'Tone rephraser, grammar explainer & cultural nuance analysis',
            icon: Icons.auto_awesome_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AIToolsScreen(),
                ),
              );
            },
          ),

          SizedBox(height: (812 * 0.016).h),

          // 3. DOCUMENT TRANSLATOR WIDE CARD
          _buildBottomCard(
            context,
            title: 'File & Document Translator',
            subtitle: 'Translate TXT, JSON, and CSV documents in seconds',
            icon: Icons.auto_stories_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FileTranslationScreen(),
                ),
              );
            },
          ),

          SizedBox(height: (812 * 0.016).h),

          // 3. TWO-COLUMN BENTO GRID: Dictionary & Voice Conversation
          Row(
            children: [
              // Left Bento Tile: Dictionary
              Expanded(
                child: _buildBentoTile(
                  context,
                  title: 'Dictionary & Thesaurus',
                  subtitle: 'Explore 100k+ word meanings & phonetics',
                  icon: Icons.menu_book_rounded,
                  badge: 'VOCABULARY',
                  gradientColors: [
                    AppColors.success,
                    Color.lerp(AppColors.success, AppColors.textWhite, 0.25) ??
                        AppColors.success,
                  ],

                  onTap: () {
                    context.read<MainNavViewModel>().setIndex(2);
                  },
                ),
              ),
              SizedBox(width: (375 * 0.03).w),

              // Right Bento Tile: Voice Conversation
              Expanded(
                child: _buildBentoTile(
                  context,
                  title: 'Voice Conversation',
                  subtitle: 'Real-time two-way dialogue translation',
                  icon: Icons.record_voice_over_rounded,
                  badge: 'TWO-WAY LIVE',
                  gradientColors: [
                    AppColors.warning,
                    Color.lerp(AppColors.warning, AppColors.textWhite, 0.25) ??
                        AppColors.warning,
                  ],

                  onTap: () {
                    context.read<MainNavViewModel>().setIndex(1);
                  },
                ),
              ),
            ],
          ),

          SizedBox(height: (812 * 0.016).h),

          // 4. HISTORY & FAVORITES CARD
          _buildBottomCard(
            context,
            title: 'History & Starred Favorites',
            subtitle: 'Search, categorize, and review your past translations',
            icon: Icons.history_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TranslationHistoryScreen(),
                ),
              );
            },
          ),

          SizedBox(height: (812 * 0.016).h),

          // 5. BOTTOM WIDE CARD: System & Preferences
          _buildBottomCard(
            context,
            title: 'Settings & Preferences',
            subtitle: 'Color themes, speech speeds, and offline caching',
            icon: Icons.tune_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Settings()),
              );
            },
          ),

          SizedBox(height: (812 * 0.02).h),
        ],
      ),
    );
  }

  // --- 1. HERO BENTO CARD ---
  Widget _buildHeroCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22.r),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.28),
                blurRadius: 14.r,
                offset: Offset(0, 5.h),
              ),
            ],
          ),
          padding: EdgeInsets.all((375 * 0.05).w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.textWhite.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      'AI DOCUMENT ENGINE',
                      style: GoogleFonts.outfit(
                        fontSize: (375 * 0.026).sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8.sp,
                        color: AppColors.textWhite,
                      ),
                    ),
                  ),
                  Container(
                    width: 32.w,
                    height: 32.h,
                    decoration: BoxDecoration(
                      color: AppColors.textWhite.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.textWhite,
                        size: 16.w,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: (812 * 0.016).h),

              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: (375 * 0.046).sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textWhite,
                  letterSpacing: -0.3.sp,
                ),
              ),
              SizedBox(height: (812 * 0.005).h),
              Text(
                subtitle,
                style: GoogleFonts.outfit(
                  fontSize: (375 * 0.032).sp,
                  color: AppColors.textWhite.withValues(alpha: 0.9),
                  height: 1.35.h,
                ),
              ),

              SizedBox(height: (812 * 0.016).h),

              // File Types Pill Badges
              Row(
                children: ['TXT', 'JSON', 'CSV'].map((format) {
                  return Container(
                    margin: EdgeInsets.only(right: 8.w),
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.textWhite.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: AppColors.textWhite.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Text(
                      format,
                      style: GoogleFonts.outfit(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textWhite,
                        letterSpacing: 0.5.sp,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 2. MEDIUM BENTO GRID TILE ---
  Widget _buildBentoTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String badge,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          height: (812 * 0.21).h,
          padding: EdgeInsets.all((375 * 0.04).w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 10.r,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon Badge with ambient glow
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: (375 * 0.115).w,
                    height: (375 * 0.115).w,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(13.r),
                      boxShadow: [
                        BoxShadow(
                          color: gradientColors.last.withValues(alpha: 0.28),
                          blurRadius: 8.r,
                          offset: Offset(0, 2.h),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        icon,
                        color: AppColors.textWhite,
                        size: (375 * 0.058).w,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_outward_rounded,
                    size: 17.w,
                    color: AppColors.textMuted,
                  ),
                ],
              ),

              // Title and Subtitle
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: (375 * 0.037).sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.2.h,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: (375 * 0.029).sp,
                      color: AppColors.textSecondary,
                      height: 1.3.h,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 3. BOTTOM WIDE CARD ---
  Widget _buildBottomCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          padding: EdgeInsets.all((375 * 0.042).w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 10.r,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: (375 * 0.12).w,
                height: (375 * 0.12).w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primaryAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryAccent.withValues(alpha: 0.25),
                      blurRadius: 8.r,
                      offset: Offset(0, 2.h),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: AppColors.textWhite,
                    size: (375 * 0.06).w,
                  ),
                ),
              ),
              SizedBox(width: (375 * 0.035).w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontSize: (375 * 0.039).sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: GoogleFonts.outfit(
                        fontSize: (375 * 0.031).sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
                size: (375 * 0.055).w,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
