import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:translator_app/apptheme/app_theme.dart';
import 'package:translator_app/view/camera.dart';
import 'package:translator_app/view/conversation.dart';
import 'package:translator_app/view/more_fun.dart';

class BottomActionBar1 extends StatelessWidget {
  const BottomActionBar1({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.018,
        horizontal: screenWidth * 0.04,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionButton(
            context,
            icon: Icons.group_rounded,
            label: 'Conversation',
            isActive: false,
            screenWidth: screenWidth,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Conversation()),
              );
            },
          ),
          _buildActionButton(
            context,
            icon: Icons.camera_alt_rounded,
            label: 'Camera',
            isActive: false,
            screenWidth: screenWidth,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CameraScreen()),
              );
            },
          ),
          _buildActionButton(
            context,
            icon: Icons.apps_rounded,
            label: 'More Fun',
            isActive: true,
            screenWidth: screenWidth,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MoreFunScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isActive,
    required double screenWidth,
    required VoidCallback onTap,
  }) {
    final buttonSize = screenWidth * 0.16;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(screenWidth * 0.08),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : AppColors.inputBackground,
              shape: BoxShape.circle,
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColors.shadowPrimary,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              color: isActive ? AppColors.textWhite : AppColors.textSecondary,
              size: screenWidth * 0.07,
            ),
          ),
          SizedBox(height: screenWidth * 0.02),
          Text(
            label,
            style: GoogleFonts.outfit(
              color: isActive ? AppColors.primary : AppColors.textSecondary,
              fontSize: (screenWidth * 0.032).clamp(11.0, 13.0),
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
