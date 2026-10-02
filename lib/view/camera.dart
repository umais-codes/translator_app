import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:translator_app/apptheme/app_theme.dart';
import 'package:translator_app/view/components/custom_app_bar.dart';
import 'package:translator_app/view/components/custom_button.dart';
import 'package:translator_app/view/components/language_selector.dart';
import 'package:translator_app/viewmodel/camera_viewmodel.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  CameraViewModel? _cameraViewModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CameraViewModel>().initializeCamera();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cameraViewModel = context.read<CameraViewModel>();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _cameraViewModel?.pauseCamera();
    } else if (state == AppLifecycleState.resumed) {
      _cameraViewModel?.resumeCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Safely pause camera using stored reference
    _cameraViewModel?.pauseCamera();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CameraViewModel>();

    // Non-camera states use standard app theme scaffold and CustomAppBar
    if (_shouldShowResultView(vm.state, vm)) {
      return Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: const CustomAppBar(
          title: 'Camera Translation',
          showBackButton: true,
        ),
        body: _buildResultView(context, vm),
      );
    } else if (vm.state == CameraState.permissionDenied) {
      return Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: const CustomAppBar(
          title: 'Camera Permission',
          showBackButton: true,
        ),
        body: _buildPermissionDeniedView(context, vm),
      );
    } else if (vm.state == CameraState.error && vm.capturedImagePath == null) {
      return Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: const CustomAppBar(
          title: 'Camera Scanner',
          showBackButton: true,
        ),
        body: _buildErrorView(context, vm),
      );
    }

    // Live camera preview state with floating top bar and HUD overlay
    return Scaffold(
      backgroundColor: AppColors.textPrimary,
      body: SafeArea(
        child: Stack(
          children: [
            // Base Layer: Camera Preview
            _buildCameraPreview(context, vm),

            // Top Navigation Bar (Floating in live camera mode)
            _buildLiveCameraTopBar(context, vm),

            // Busy Overlay (Capturing / Recognizing)
            if (vm.state == CameraState.capturing ||
                vm.state == CameraState.recognizing)
              _buildProcessingOverlay(vm),
          ],
        ),
      ),
    );
  }

  bool _shouldShowResultView(CameraState state, CameraViewModel vm) {
    return state == CameraState.ocrCompleted ||
        state == CameraState.translating ||
        state == CameraState.translated ||
        (state == CameraState.error && vm.capturedImagePath != null);
  }

  // --- FLOATING TOP BAR FOR LIVE CAMERA ---
  Widget _buildLiveCameraTopBar(
    BuildContext context,
    CameraViewModel vm,
  ) {
    final iconButtonSize = 41.w;

    return Positioned(
      top: 12.h,
      left: 15.w,
      right: 15.w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          Container(
            width: iconButtonSize,
            height: iconButtonSize,
            decoration: BoxDecoration(
              color: AppColors.textPrimary.withValues(alpha: 0.65),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18.w,
                color: AppColors.textWhite,
              ),
              onPressed: () {
                if (context.canPop()) context.pop();
              },
            ),
          ),

          // Center Screen Title Pill
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 15.w,
              vertical: 7.h,
            ),
            decoration: BoxDecoration(
              color: AppColors.textPrimary.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(15.r),
            ),
            child: Text(
              'Camera Translator',
              style: GoogleFonts.outfit(
                color: AppColors.textWhite,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Flash Button
          Container(
            width: iconButtonSize,
            height: iconButtonSize,
            decoration: BoxDecoration(
              color: AppColors.textPrimary.withValues(alpha: 0.65),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                vm.flashMode == FlashMode.torch
                    ? Icons.flash_on_rounded
                    : vm.flashMode == FlashMode.auto
                        ? Icons.flash_auto_rounded
                        : Icons.flash_off_rounded,
                size: 19.w,
                color: vm.flashMode != FlashMode.off
                    ? AppColors.warning
                    : AppColors.textWhite,
              ),
              onPressed: vm.toggleFlash,
            ),
          ),
        ],
      ),
    );
  }

  // --- LIVE CAMERA PREVIEW WITH SCANNING FRAME ---
  Widget _buildCameraPreview(
    BuildContext context,
    CameraViewModel vm,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewSize = constraints.biggest;
        final controller = vm.cameraController;
    if (!vm.isCameraInitialized ||
        controller == null ||
        !controller.value.isInitialized ||
        controller.value.previewSize == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16.h),
            Text(
              'Starting camera...',
              style: GoogleFonts.outfit(
                color: AppColors.textWhite.withValues(alpha: 0.75),
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      );
    }

    final previewSize = controller.value.previewSize!;
    final previewAspectRatio = previewSize.height / previewSize.width;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera Feed
        Center(
          child: AspectRatio(
            aspectRatio: previewAspectRatio,
            child: CameraPreview(controller),
          ),
        ),

        // Scanning Target Frame
        Center(
          child: Container(
            width: 319.w,
            height: 365.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(23.r),
              border: Border.all(
                color: AppColors.textWhite.withValues(alpha: 0.85),
                width: 2.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 20.r,
                  spreadRadius: 2.r,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 12.h),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 5.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(11.r),
                    ),
                    child: Text(
                      'Align text inside box',
                      style: GoogleFonts.outfit(
                        color: AppColors.textWhite,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 1.h),
              ],
            ),
          ),
        ),

        // Bottom Controls Bar
        Positioned(
          bottom: 28.h,
          left: 0.w,
          right: 0.w,
          child: Column(
            children: [
              // Shutter & Gallery Controls
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 38.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Gallery Button
                    _buildCircularActionButton(
                      icon: Icons.photo_library_rounded,
                      tooltip: 'Select from Gallery',
                      onTap: vm.pickImageFromGallery,
                    ),

                    // Shutter Capture Button
                    GestureDetector(
                      onTap: vm.isBusy
                          ? null
                          : () => vm.captureImage(viewSize: viewSize),
                      child: Container(
                        width: 71.w,
                        height: 71.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.textWhite,
                            width: 4.w,
                          ),
                          color: AppColors.textWhite.withValues(alpha: 0.2),
                        ),
                        padding: EdgeInsets.all(5.w),
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.textWhite,
                          ),
                          child: Icon(
                            Icons.camera_alt_rounded,
                            color: AppColors.primary,
                            size: 30.w,
                          ),
                        ),
                      ),
                    ),

                    // Switch Camera Button
                    if (vm.canSwitchCamera)
                      _buildCircularActionButton(
                        icon: Icons.flip_camera_ios_rounded,
                        tooltip: 'Switch Camera',
                        onTap: vm.switchCamera,
                      )
                    else
                      SizedBox(width: 49.w),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
      },
    );
  }

  Widget _buildCircularActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    final buttonSize = 49.w;

    return Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        color: AppColors.textPrimary.withValues(alpha: 0.6),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.textWhite.withValues(alpha: 0.3)),
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.textWhite, size: 23.w),
        tooltip: tooltip,
        onPressed: onTap,
      ),
    );
  }

  // --- RESULT & TRANSLATION SHEET VIEW ---
  Widget _buildResultView(
    BuildContext context,
    CameraViewModel vm,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: 17.w,
        vertical: 16.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Thumbnail preview + Retake row
          if (vm.capturedImagePath != null)
            Container(
              padding: EdgeInsets.all(11.w),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(15.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(9.r),
                    child: Image.file(
                      File(vm.capturedImagePath!),
                      width: 53.w,
                      height: 53.w,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 13.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Image Scanned',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            fontSize: 14.sp,
                          ),
                        ),
                        Text(
                          'Text read from this photo',
                          style: GoogleFonts.outfit(
                            color: AppColors.textSecondary,
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                    icon: Icon(Icons.refresh_rounded, size: 17.w),
                    label: Text(
                      'Retake',
                      style: GoogleFonts.outfit(
                        fontSize: 13.sp,
                      ),
                    ),
                    onPressed: vm.retake,
                  ),
                ],
              ),
            ),

          SizedBox(height: 15.h),

          // Language Selector Card
          LanguageSelectorCard(
            sourceLanguage: vm.sourceLanguage,
            targetLanguage: vm.targetLanguage,
            onSourceChanged: vm.setSourceLanguage,
            onTargetChanged: vm.setTargetLanguage,
            onSwap: vm.swapLanguages,
          ),

          SizedBox(height: 15.h),

          // Detected OCR Text Card
          _buildSectionCard(
            title: 'DETECTED TEXT',
            content: vm.detectedText,
            icon: Icons.document_scanner_rounded,
            trailing: vm.detectedText.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.copy_rounded,
                      size: 18.w,
                      color: AppColors.primary,
                    ),
                    tooltip: 'Copy Detected Text',
                    onPressed: () => vm.copyDetectedText(context),
                  )
                : null,
          ),

          SizedBox(height: 15.h),

          // Translated Result Card
          if (vm.state == CameraState.translating)
            Container(
              padding: EdgeInsets.all(23.w),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(19.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: 12.h),
                    Text(
                      'Translating to ${vm.targetLanguage.name}...',
                      style: GoogleFonts.outfit(
                        color: AppColors.textSecondary,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (vm.translatedText.isNotEmpty)
            _buildSectionCard(
              title: 'TRANSLATION (${vm.targetLanguage.name.toUpperCase()})',
              content: vm.translatedText,
              icon: Icons.translate_rounded,
              isHighlight: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.volume_up_rounded,
                      size: 20.w,
                      color: AppColors.primary,
                    ),
                    tooltip: 'Listen',
                    onPressed: vm.speakTranslation,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.copy_rounded,
                      size: 18.w,
                      color: AppColors.primary,
                    ),
                    tooltip: 'Copy',
                    onPressed: () => vm.copyTranslatedText(context),
                  ),
                ],
              ),
            )
          else if (vm.errorMessage != null)
            Container(
              padding: EdgeInsets.all(17.w),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(15.r),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.error,
                    size: 26.w,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    vm.errorMessage!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: AppColors.error,
                      fontSize: 13.sp,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  CustomButton(
                    text: 'Retake Photo',
                    leadingIcon: Icons.camera_alt_rounded,
                    onPressed: vm.retake,
                  ),
                ],
              ),
            ),

          SizedBox(height: 20.h),

          // Bottom Scan Again Button
          CustomButton(
            text: 'Scan Another Image',
            variant: ButtonVariant.filled,
            leadingIcon: Icons.camera_alt_rounded,
            onPressed: vm.retake,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String content,
    required IconData icon,
    bool isHighlight = false,
    Widget? trailing,
  }) {
    return Container(
      padding: EdgeInsets.all(17.w),
      decoration: BoxDecoration(
        color: isHighlight
            ? AppColors.primary.withValues(alpha: 0.05)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(19.r),
        border: Border.all(
          color: isHighlight
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.border,
          width: isHighlight ? 2.w : 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 17.w, color: AppColors.primary),
                  SizedBox(width: 8.w),
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              ?trailing,
            ],
          ),
          SizedBox(height: 8.h),
          SelectableText(
            content.isEmpty ? 'No text detected' : content,
            style: GoogleFonts.outfit(
              fontSize: 16.sp,
              color: content.isEmpty ? AppColors.textMuted : AppColors.textPrimary,
              height: 1.h,
            ),
          ),
        ],
      ),
    );
  }

  // --- PROCESSING OVERLAY ---
  Widget _buildProcessingOverlay(
    CameraViewModel vm,
  ) {
    final message = vm.state == CameraState.capturing
        ? 'Capturing...'
        : 'Detecting text with OCR...';

    return Container(
      color: AppColors.textPrimary.withValues(alpha: 0.7),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 26.w,
            vertical: 24.h,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(19.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 16.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 16.h),
              Text(
                message,
                style: GoogleFonts.outfit(
                  color: AppColors.textPrimary,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- PERMISSION DENIED VIEW ---
  Widget _buildPermissionDeniedView(
    BuildContext context,
    CameraViewModel vm,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 23.w,
          vertical: 24.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(19.w),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.no_photography_rounded,
                size: 53.w,
                color: AppColors.error,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Camera Permission Required',
              style: GoogleFonts.outfit(
                fontSize: 19.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'Please grant camera permissions to scan text directly from documents and signs.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 24.h),
            CustomButton(
              text: 'Open Settings',
              leadingIcon: Icons.settings_rounded,
              onPressed: vm.openSystemSettings,
            ),
            SizedBox(height: 12.h),
            CustomButton(
              text: 'Try Again',
              variant: ButtonVariant.outlined,
              leadingIcon: Icons.refresh_rounded,
              onPressed: vm.initializeCamera,
            ),
            SizedBox(height: 12.h),
            CustomButton(
              text: 'Choose Image from Gallery',
              variant: ButtonVariant.outlined,
              leadingIcon: Icons.photo_library_rounded,
              onPressed: vm.pickImageFromGallery,
            ),
          ],
        ),
      ),
    );
  }

  // --- ERROR VIEW ---
  Widget _buildErrorView(
    BuildContext context,
    CameraViewModel vm,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 23.w,
          vertical: 24.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 53.w,
              color: AppColors.warning,
            ),
            SizedBox(height: 16.h),
            Text(
              vm.errorMessage ?? 'Camera error occurred',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 15.sp,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 24.h),
            CustomButton(
              text: 'Retry Camera',
              leadingIcon: Icons.refresh_rounded,
              onPressed: vm.initializeCamera,
            ),
            SizedBox(height: 12.h),
            CustomButton(
              text: 'Pick from Gallery',
              variant: ButtonVariant.outlined,
              leadingIcon: Icons.photo_library_rounded,
              onPressed: vm.pickImageFromGallery,
            ),
          ],
        ),
      ),
    );
  }
}
