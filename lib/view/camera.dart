import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:translator_app/apptheme/app_theme.dart';
import 'package:translator_app/data/models/translation_repository.dart';
import 'package:translator_app/view/components/custom_button.dart';
import 'package:translator_app/view/components/language_selector.dart';
import 'package:translator_app/viewmodel/camera_viewmodel.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  late CameraViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _viewModel = CameraViewModel(TranslationRepository());
    _viewModel.initializeCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _viewModel.cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (_viewModel.state == CameraState.cameraReady ||
          _viewModel.state == CameraState.initial) {
        _viewModel.initializeCamera();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CameraViewModel>.value(
      value: _viewModel,
      child: Consumer<CameraViewModel>(
        builder: (context, vm, _) {
          final mediaQuery = MediaQuery.of(context);
          final screenWidth = mediaQuery.size.width;
          final screenHeight = mediaQuery.size.height;

          return Scaffold(
            backgroundColor: AppColors.textPrimary,
            body: SafeArea(
              child: Stack(
                children: [
                  // 1. Base Layer: Camera Preview or Result Screen
                  if (_shouldShowResultView(vm.state))
                    _buildResultView(context, vm, screenWidth, screenHeight)
                  else if (vm.state == CameraState.permissionDenied)
                    _buildPermissionDeniedView(context, vm, screenWidth, screenHeight)
                  else if (vm.state == CameraState.error && vm.capturedImagePath == null)
                    _buildErrorView(context, vm, screenWidth, screenHeight)
                  else
                    _buildCameraPreview(context, vm, screenWidth, screenHeight),

                  // 2. Top Navigation Bar (Always available)
                  _buildTopBar(context, vm, screenWidth, screenHeight),

                  // 3. Busy Overlay (Capturing / Recognizing)
                  if (vm.state == CameraState.capturing ||
                      vm.state == CameraState.recognizing)
                    _buildProcessingOverlay(vm, screenWidth, screenHeight),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  bool _shouldShowResultView(CameraState state) {
    return state == CameraState.ocrCompleted ||
        state == CameraState.translating ||
        state == CameraState.translated ||
        (state == CameraState.error && _viewModel.capturedImagePath != null);
  }

  // --- TOP BAR ---
  Widget _buildTopBar(
    BuildContext context,
    CameraViewModel vm,
    double screenWidth,
    double screenHeight,
  ) {
    final iconButtonSize = screenWidth * 0.11;

    return Positioned(
      top: screenHeight * 0.012,
      left: screenWidth * 0.04,
      right: screenWidth * 0.04,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          Container(
            width: iconButtonSize,
            height: iconButtonSize,
            decoration: BoxDecoration(
              color: AppColors.textPrimary.withValues(alpha: 0.55),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: screenWidth * 0.048,
                color: AppColors.textWhite,
              ),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),

          // Center Screen Title
          Text(
            'Camera Translator',
            style: GoogleFonts.outfit(
              color: AppColors.textWhite,
              fontSize: (screenWidth * 0.045).clamp(16.0, 20.0),
              fontWeight: FontWeight.w600,
              shadows: [
                Shadow(
                  color: AppColors.textPrimary.withValues(alpha: 0.6),
                  blurRadius: 8,
                ),
              ],
            ),
          ),

          // Flash Button (Only in camera mode)
          if (!_shouldShowResultView(vm.state))
            Container(
              width: iconButtonSize,
              height: iconButtonSize,
              decoration: BoxDecoration(
                color: AppColors.textPrimary.withValues(alpha: 0.55),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  vm.flashMode == FlashMode.torch
                      ? Icons.flash_on_rounded
                      : vm.flashMode == FlashMode.auto
                          ? Icons.flash_auto_rounded
                          : Icons.flash_off_rounded,
                  size: screenWidth * 0.05,
                  color: vm.flashMode != FlashMode.off
                      ? AppColors.warning
                      : AppColors.textWhite,
                ),
                onPressed: vm.toggleFlash,
              ),
            )
          else
            SizedBox(width: iconButtonSize),
        ],
      ),
    );
  }

  // --- LIVE CAMERA PREVIEW WITH SCANNING FRAME ---
  Widget _buildCameraPreview(
    BuildContext context,
    CameraViewModel vm,
    double screenWidth,
    double screenHeight,
  ) {
    if (!vm.isCameraInitialized) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: screenHeight * 0.02),
            Text(
              'Starting camera...',
              style: GoogleFonts.outfit(
                color: AppColors.textWhite.withValues(alpha: 0.75),
                fontSize: screenWidth * 0.038,
              ),
            ),
          ],
        ),
      );
    }

    final controller = vm.cameraController!;
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
            width: screenWidth * 0.85,
            height: screenHeight * 0.45,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(screenWidth * 0.06),
              border: Border.all(
                color: AppColors.textWhite.withValues(alpha: 0.85),
                width: screenWidth * 0.005,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.015),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.032,
                      vertical: screenHeight * 0.006,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(screenWidth * 0.03),
                    ),
                    child: Text(
                      'Align text inside box',
                      style: GoogleFonts.outfit(
                        color: AppColors.textWhite,
                        fontSize: (screenWidth * 0.032).clamp(11.0, 13.0),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.001),
              ],
            ),
          ),
        ),

        // Bottom Controls Bar
        Positioned(
          bottom: screenHeight * 0.035,
          left: 0,
          right: 0,
          child: Column(
            children: [
              // Shutter & Gallery Controls
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Gallery Button
                    _buildCircularActionButton(
                      icon: Icons.photo_library_rounded,
                      tooltip: 'Select from Gallery',
                      screenWidth: screenWidth,
                      onTap: vm.pickImageFromGallery,
                    ),

                    // Shutter Capture Button
                    GestureDetector(
                      onTap: vm.isBusy ? null : vm.captureImage,
                      child: Container(
                        width: screenWidth * 0.19,
                        height: screenWidth * 0.19,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.textWhite,
                            width: screenWidth * 0.01,
                          ),
                          color: AppColors.textWhite.withValues(alpha: 0.2),
                        ),
                        padding: EdgeInsets.all(screenWidth * 0.012),
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.textWhite,
                          ),
                          child: Icon(
                            Icons.camera_alt_rounded,
                            color: AppColors.primary,
                            size: screenWidth * 0.08,
                          ),
                        ),
                      ),
                    ),

                    // Switch Camera Button
                    if (vm.canSwitchCamera)
                      _buildCircularActionButton(
                        icon: Icons.flip_camera_ios_rounded,
                        tooltip: 'Switch Camera',
                        screenWidth: screenWidth,
                        onTap: vm.switchCamera,
                      )
                    else
                      SizedBox(width: screenWidth * 0.13),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCircularActionButton({
    required IconData icon,
    required String tooltip,
    required double screenWidth,
    required VoidCallback onTap,
  }) {
    final buttonSize = screenWidth * 0.13;

    return Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        color: AppColors.textPrimary.withValues(alpha: 0.6),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.textWhite.withValues(alpha: 0.3)),
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.textWhite, size: screenWidth * 0.06),
        tooltip: tooltip,
        onPressed: onTap,
      ),
    );
  }

  // --- RESULT & TRANSLATION SHEET VIEW ---
  Widget _buildResultView(
    BuildContext context,
    CameraViewModel vm,
    double screenWidth,
    double screenHeight,
  ) {
    return Container(
      color: AppColors.scaffoldBackground,
      margin: EdgeInsets.only(top: screenHeight * 0.07),
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.045,
          vertical: screenHeight * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thumbnail preview + Retake row
            if (vm.capturedImagePath != null)
              Container(
                padding: EdgeInsets.all(screenWidth * 0.03),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(screenWidth * 0.04),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(screenWidth * 0.025),
                      child: Image.file(
                        File(vm.capturedImagePath!),
                        width: screenWidth * 0.14,
                        height: screenWidth * 0.14,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.035),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Image Scanned',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              fontSize: (screenWidth * 0.038).clamp(14.0, 16.0),
                            ),
                          ),
                          Text(
                            'OCR text recognition active',
                            style: GoogleFonts.outfit(
                              color: AppColors.textSecondary,
                              fontSize: (screenWidth * 0.03).clamp(11.0, 13.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                      ),
                      icon: Icon(Icons.refresh_rounded, size: screenWidth * 0.045),
                      label: Text(
                        'Retake',
                        style: GoogleFonts.outfit(
                          fontSize: (screenWidth * 0.035).clamp(12.0, 14.0),
                        ),
                      ),
                      onPressed: vm.retake,
                    ),
                  ],
                ),
              ),

            SizedBox(height: screenHeight * 0.018),

            // Language Selector Card
            LanguageSelectorCard(
              sourceLanguage: vm.sourceLanguage,
              targetLanguage: vm.targetLanguage,
              onSourceChanged: vm.setSourceLanguage,
              onTargetChanged: vm.setTargetLanguage,
              onSwap: vm.swapLanguages,
            ),

            SizedBox(height: screenHeight * 0.018),

            // Detected OCR Text Card
            _buildSectionCard(
              title: 'DETECTED TEXT (${vm.sourceLanguage.name.toUpperCase()})',
              content: vm.detectedText,
              icon: Icons.document_scanner_rounded,
              screenWidth: screenWidth,
              trailing: vm.detectedText.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.copy_rounded,
                        size: screenWidth * 0.048,
                        color: AppColors.primary,
                      ),
                      tooltip: 'Copy Detected Text',
                      onPressed: () => vm.copyDetectedText(context),
                    )
                  : null,
            ),

            SizedBox(height: screenHeight * 0.018),

            // Translated Result Card
            if (vm.state == CameraState.translating)
              Container(
                padding: EdgeInsets.all(screenWidth * 0.06),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(screenWidth * 0.05),
                  border: Border.all(color: AppColors.border),
                ),
                child: Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: AppColors.primary),
                      SizedBox(height: screenHeight * 0.015),
                      Text(
                        'Translating to ${vm.targetLanguage.name}...',
                        style: GoogleFonts.outfit(
                          color: AppColors.textSecondary,
                          fontSize: (screenWidth * 0.036).clamp(13.0, 15.0),
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
                screenWidth: screenWidth,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.volume_up_rounded,
                        size: screenWidth * 0.052,
                        color: AppColors.primary,
                      ),
                      tooltip: 'Listen',
                      onPressed: vm.speakTranslation,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.copy_rounded,
                        size: screenWidth * 0.048,
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
                padding: EdgeInsets.all(screenWidth * 0.045),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(screenWidth * 0.04),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.error,
                      size: screenWidth * 0.07,
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      vm.errorMessage!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        color: AppColors.error,
                        fontSize: (screenWidth * 0.034).clamp(12.0, 14.0),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    CustomButton(
                      text: 'Retake Photo',
                      leadingIcon: Icons.camera_alt_rounded,
                      onPressed: vm.retake,
                    ),
                  ],
                ),
              ),

            SizedBox(height: screenHeight * 0.025),

            // Bottom Scan Again Button
            CustomButton(
              text: 'Scan Another Image',
              variant: ButtonVariant.filled,
              leadingIcon: Icons.camera_alt_rounded,
              onPressed: vm.retake,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String content,
    required IconData icon,
    required double screenWidth,
    bool isHighlight = false,
    Widget? trailing,
  }) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.045),
      decoration: BoxDecoration(
        color: isHighlight
            ? AppColors.primary.withValues(alpha: 0.05)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(screenWidth * 0.05),
        border: Border.all(
          color: isHighlight
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.border,
          width: isHighlight ? 1.5 : 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
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
                  Icon(icon, size: screenWidth * 0.045, color: AppColors.primary),
                  SizedBox(width: screenWidth * 0.02),
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: (screenWidth * 0.032).clamp(11.0, 13.0),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.7,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              ?trailing,
            ],
          ),
          SizedBox(height: screenWidth * 0.02),
          SelectableText(
            content.isEmpty ? 'No text detected' : content,
            style: GoogleFonts.outfit(
              fontSize: (screenWidth * 0.042).clamp(14.0, 17.0),
              color: content.isEmpty ? AppColors.textMuted : AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // --- PROCESSING OVERLAY ---
  Widget _buildProcessingOverlay(
    CameraViewModel vm,
    double screenWidth,
    double screenHeight,
  ) {
    final message = vm.state == CameraState.capturing
        ? 'Capturing...'
        : 'Detecting text with OCR...';

    return Container(
      color: AppColors.textPrimary.withValues(alpha: 0.7),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.07,
            vertical: screenHeight * 0.03,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(screenWidth * 0.05),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: screenHeight * 0.02),
              Text(
                message,
                style: GoogleFonts.outfit(
                  color: AppColors.textPrimary,
                  fontSize: (screenWidth * 0.04).clamp(14.0, 16.0),
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
    double screenWidth,
    double screenHeight,
  ) {
    return Container(
      color: AppColors.scaffoldBackground,
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.06,
        vertical: screenHeight * 0.03,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(screenWidth * 0.05),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.no_photography_rounded,
                size: screenWidth * 0.14,
                color: AppColors.error,
              ),
            ),
            SizedBox(height: screenHeight * 0.025),
            Text(
              'Camera Permission Required',
              style: GoogleFonts.outfit(
                fontSize: (screenWidth * 0.05).clamp(18.0, 22.0),
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: screenHeight * 0.012),
            Text(
              'Please grant camera permissions to scan text directly from documents and signs.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: (screenWidth * 0.036).clamp(13.0, 15.0),
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            CustomButton(
              text: 'Try Again',
              leadingIcon: Icons.refresh_rounded,
              onPressed: vm.initializeCamera,
            ),
            SizedBox(height: screenHeight * 0.015),
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
    double screenWidth,
    double screenHeight,
  ) {
    return Container(
      color: AppColors.scaffoldBackground,
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.06,
        vertical: screenHeight * 0.03,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: screenWidth * 0.14,
              color: AppColors.warning,
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              vm.errorMessage ?? 'Camera error occurred',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: (screenWidth * 0.04).clamp(14.0, 16.0),
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            CustomButton(
              text: 'Retry Camera',
              leadingIcon: Icons.refresh_rounded,
              onPressed: vm.initializeCamera,
            ),
            SizedBox(height: screenHeight * 0.015),
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
