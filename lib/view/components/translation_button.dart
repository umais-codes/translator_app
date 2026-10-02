import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:translator_app/apptheme/app_theme.dart';

class MicrophoneButton extends StatelessWidget {
  const MicrophoneButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70.w,
      height: 70.w,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowPrimary,
            spreadRadius: 2.r,
            blurRadius: 8.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(Icons.mic, color: AppColors.textWhite, size: 32.w),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Voice recognition activated')),
          );
        },
      ),
    );
  }
}
