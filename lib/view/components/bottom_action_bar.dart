import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:translator_app/apptheme/app_theme.dart';
import 'package:translator_app/view/camera.dart';
import 'package:translator_app/view/conversation.dart';
import 'package:translator_app/view/more_fun.dart';

class BottomActionBar1 extends StatelessWidget {
  const BottomActionBar1({super.key});

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: (812 * 0.018).h,
        horizontal: (375 * 0.04).w,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionButton(
            context,
            icon: Icons.group_rounded,
            label: 'Conversation',
            isActive: false,
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
    required VoidCallback onTap,
  }) {
    final buttonSize = (375 * 0.16).w;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular((375 * 0.08).r),
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
                        blurRadius: 10.r,
                        offset: Offset(0, 4.h),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              color: isActive ? AppColors.textWhite : AppColors.textSecondary,
              size: (375 * 0.07).w,
            ),
          ),
          SizedBox(height: (375 * 0.02).w),
          Text(
            label,
            style: GoogleFonts.outfit(
              color: isActive ? AppColors.primary : AppColors.textSecondary,
              fontSize: (375 * 0.032).sp,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
