import 'package:flutter/material.dart';
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
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final horizontalPadding = screenWidth * 0.045;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: screenHeight * 0.02,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Smart Tools',
            style: GoogleFonts.outfit(
              fontSize: (screenWidth * 0.058).clamp(22.0, 26.0),
              fontWeight: FontWeight.bold,
              letterSpacing: -0.6,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            'AI-powered language suite',
            style: GoogleFonts.outfit(
              fontSize: (screenWidth * 0.035).clamp(13.0, 15.0),
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: screenHeight * 0.022),

          // 1. HERO BENTO CARD: Camera & OCR Live Translator
          _buildHeroCard(
            context,
            title: 'Camera & OCR Translator',
            subtitle:
                'Scan printed text from signs, menus, and documents with instant optical recognition.',
            icon: Icons.camera_alt_rounded,
            screenWidth: screenWidth,
            screenHeight: screenHeight,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CameraScreen(),
                ),
              );
            },
          ),

          SizedBox(height: screenHeight * 0.016),

          // 2. AI LANGUAGE STUDIO CARD
          _buildBottomCard(
            context,
            title: 'AI Language Intelligence',
            subtitle: 'Tone rephraser, grammar explainer & cultural nuance analysis',
            icon: Icons.auto_awesome_rounded,
            screenWidth: screenWidth,
            screenHeight: screenHeight,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AIToolsScreen(),
                ),
              );
            },
          ),

          SizedBox(height: screenHeight * 0.016),

          // 3. DOCUMENT TRANSLATOR WIDE CARD
          _buildBottomCard(
            context,
            title: 'File & Document Translator',
            subtitle: 'Translate TXT, JSON, and CSV documents in seconds',
            icon: Icons.auto_stories_rounded,
            screenWidth: screenWidth,
            screenHeight: screenHeight,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FileTranslationScreen(),
                ),
              );
            },
          ),

          SizedBox(height: screenHeight * 0.016),

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
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  onTap: () {
                    context.read<MainNavViewModel>().setIndex(2);
                  },
                ),
              ),
              SizedBox(width: screenWidth * 0.03),

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
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  onTap: () {
                    context.read<MainNavViewModel>().setIndex(1);
                  },
                ),
              ),
            ],
          ),

          SizedBox(height: screenHeight * 0.016),

          // 4. HISTORY & FAVORITES CARD
          _buildBottomCard(
            context,
            title: 'History & Starred Favorites',
            subtitle: 'Search, categorize, and review your past translations',
            icon: Icons.history_rounded,
            screenWidth: screenWidth,
            screenHeight: screenHeight,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TranslationHistoryScreen(),
                ),
              );
            },
          ),

          SizedBox(height: screenHeight * 0.016),

          // 5. BOTTOM WIDE CARD: System & Preferences
          _buildBottomCard(
            context,
            title: 'Settings & Preferences',
            subtitle: 'Color themes, speech speeds, and offline caching',
            icon: Icons.tune_rounded,
            screenWidth: screenWidth,
            screenHeight: screenHeight,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Settings()),
              );
            },
          ),

          SizedBox(height: screenHeight * 0.02),
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
    required double screenWidth,
    required double screenHeight,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.28),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.textWhite.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'AI DOCUMENT ENGINE',
                      style: GoogleFonts.outfit(
                        fontSize: (screenWidth * 0.026).clamp(10.0, 11.5),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: AppColors.textWhite,
                      ),
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.textWhite.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.textWhite,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: screenHeight * 0.016),

              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: (screenWidth * 0.046).clamp(17.0, 21.0),
                  fontWeight: FontWeight.bold,
                  color: AppColors.textWhite,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: screenHeight * 0.005),
              Text(
                subtitle,
                style: GoogleFonts.outfit(
                  fontSize: (screenWidth * 0.032).clamp(12.0, 13.5),
                  color: AppColors.textWhite.withValues(alpha: 0.9),
                  height: 1.35,
                ),
              ),

              SizedBox(height: screenHeight * 0.016),

              // File Types Pill Badges
              Row(
                children: ['TXT', 'JSON', 'CSV'].map((format) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.textWhite.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.textWhite.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Text(
                      format,
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textWhite,
                        letterSpacing: 0.5,
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
    required double screenWidth,
    required double screenHeight,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: (screenHeight * 0.21).clamp(170.0, 200.0),
          padding: EdgeInsets.all(screenWidth * 0.04),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 10,
                offset: Offset(0, 2),
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
                    width: screenWidth * 0.115,
                    height: screenWidth * 0.115,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(13),
                      boxShadow: [
                        BoxShadow(
                          color: gradientColors.last.withValues(alpha: 0.28),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        icon,
                        color: AppColors.textWhite,
                        size: screenWidth * 0.058,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_outward_rounded,
                    size: 17,
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
                      fontSize: (screenWidth * 0.037).clamp(14.0, 16.0),
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: (screenWidth * 0.029).clamp(11.0, 12.0),
                      color: AppColors.textSecondary,
                      height: 1.3,
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
    required double screenWidth,
    required double screenHeight,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.all(screenWidth * 0.042),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: screenWidth * 0.12,
                height: screenWidth * 0.12,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primaryAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryAccent.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: AppColors.textWhite,
                    size: screenWidth * 0.06,
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.035),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontSize: (screenWidth * 0.039).clamp(15.0, 16.5),
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.outfit(
                        fontSize: (screenWidth * 0.031).clamp(11.5, 13.0),
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
                size: screenWidth * 0.055,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
