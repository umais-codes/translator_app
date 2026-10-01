import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:translator_app/core/ocr_language_support.dart';
import 'package:translator_app/core/translation_limits.dart';
import 'package:translator_app/data/models/translation_repository.dart';
import 'package:translator_app/data/repositories/translation_history_repository.dart';
import 'package:translator_app/data/services/ocr_service.dart';
import 'package:translator_app/data/services/scan_image_preparer.dart';
import 'package:translator_app/data/services/speech_preferences.dart';
import 'package:translator_app/viewmodel/lang_model.dart';
import 'package:app_settings/app_settings.dart';

enum CameraState {
  initial,
  initializing,
  cameraReady,
  capturing,
  recognizing,
  ocrCompleted,
  translating,
  translated,
  error,
  permissionDenied,
}

class CameraViewModel extends ChangeNotifier {
  final TranslationRepository _translationRepository;
  final TranslationHistoryRepository _historyRepository;
  final OcrService _ocrService;
  final ImagePicker _imagePicker = ImagePicker();
  final FlutterTts _flutterTts = FlutterTts();
  final ScanImagePreparer _imagePreparer = ScanImagePreparer();
  int _cameraGeneration = 0;
  ScanFrameInput? _lastFrame;

  CameraViewModel(
    this._translationRepository, {
    TranslationHistoryRepository? historyRepository,
    OcrService? ocrService,
  })  : _historyRepository = historyRepository ?? TranslationHistoryRepository(),
        _ocrService = ocrService ?? OcrService() {
    _sourceLanguage = LanguageModel.supportedLanguages[0]; // English
    _targetLanguage = LanguageModel.supportedLanguages[1]; // Spanish
    _initTts();
  }

  CameraState _state = CameraState.initial;
  CameraController? _cameraController;
  List<CameraDescription> _availableCameras = [];
  int _selectedCameraIndex = 0;
  FlashMode _flashMode = FlashMode.off;

  String? _capturedImagePath;
  String _detectedText = '';
  String _translatedText = '';
  String? _errorMessage;

  late LanguageModel _sourceLanguage;
  late LanguageModel _targetLanguage;

  // Getters
  CameraState get state => _state;
  CameraController? get cameraController => _cameraController;
  bool get isCameraInitialized =>
      _cameraController != null && _cameraController!.value.isInitialized;
  FlashMode get flashMode => _flashMode;
  bool get canSwitchCamera => _availableCameras.length > 1;

  String? get capturedImagePath => _capturedImagePath;
  String get detectedText => _detectedText;
  String get translatedText => _translatedText;
  String? get errorMessage => _errorMessage;

  LanguageModel get sourceLanguage => _sourceLanguage;
  LanguageModel get targetLanguage => _targetLanguage;
  List<LanguageModel> get languages => LanguageModel.supportedLanguages;

  bool get isBusy =>
      _state == CameraState.initializing ||
      _state == CameraState.capturing ||
      _state == CameraState.recognizing ||
      _state == CameraState.translating;

  void _initTts() {
    SpeechPreferences.apply(_flutterTts, languageCode: _targetLanguage.code);
  }

  Future<void> openSystemSettings() => AppSettings.openAppSettings();

  // --- Camera Lifecycle ---

  Future<void> initializeCamera() async {
    final generation = ++_cameraGeneration;
    _setCameraState(CameraState.initializing);
    _errorMessage = null;

    try {
      final cameras = await availableCameras();
      if (generation != _cameraGeneration) return;
      if (cameras.isEmpty) {
        _errorMessage = 'No camera found on this device.';
        _setCameraState(CameraState.error);
        return;
      }

      _availableCameras = cameras;
      if (_selectedCameraIndex >= cameras.length) {
        _selectedCameraIndex = 0;
      }
      await _setupCameraController(cameras[_selectedCameraIndex], generation);
      if (generation != _cameraGeneration) return;
      _setCameraState(CameraState.cameraReady);
    } on CameraException catch (e) {
      if (generation != _cameraGeneration) return;
      if (e.code == 'CameraAccessDenied' ||
          e.code == 'CameraAccessDeniedWithoutPrompt' ||
          e.code == 'CameraAccessRestricted') {
        _errorMessage =
            'Camera permission was denied. Enable camera access in system settings, or choose a photo from the gallery.';
        _setCameraState(CameraState.permissionDenied);
      } else {
        _errorMessage = 'Failed to initialize camera: ${e.description ?? e.code}';
        _setCameraState(CameraState.error);
      }
    } catch (e) {
      if (generation != _cameraGeneration) return;
      _errorMessage = 'An unexpected error occurred while starting the camera.';
      _setCameraState(CameraState.error);
    }
  }

  Future<void> pauseCamera() => releaseCamera();

  Future<void> releaseCamera() async {
    _cameraGeneration++;
    final controller = _cameraController;
    _cameraController = null;
    if (_state == CameraState.initializing ||
        _state == CameraState.cameraReady ||
        _state == CameraState.capturing) {
      _state = CameraState.initial;
    }
    notifyListeners();
    if (controller != null) {
      try {
        await controller.dispose();
      } catch (_) {}
    }
  }

  Future<void> resumeCamera() async {
    if (_state == CameraState.initial || _state == CameraState.initializing) {
      await initializeCamera();
    }
  }

  Future<void> _setupCameraController(
    CameraDescription description,
    int generation,
  ) async {
    final oldController = _cameraController;
    _cameraController = null;
    if (oldController != null) {
      try {
        await oldController.dispose();
      } catch (_) {}
    }
    if (generation != _cameraGeneration) return;

    final newController = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await newController.initialize();
      await newController.setFlashMode(_flashMode);
    } catch (e) {
      await newController.dispose();
      rethrow;
    }

    if (generation != _cameraGeneration) {
      await newController.dispose();
      return;
    }
    _cameraController = newController;
  }

  Future<void> toggleFlash() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    final previous = _flashMode;
    try {
      if (_flashMode == FlashMode.off) {
        _flashMode = FlashMode.torch;
      } else if (_flashMode == FlashMode.torch) {
        _flashMode = FlashMode.auto;
      } else {
        _flashMode = FlashMode.off;
      }
      await _cameraController!.setFlashMode(_flashMode);
      notifyListeners();
    } catch (_) {
      _flashMode = previous;
      notifyListeners();
    }
  }

  Future<void> switchCamera() async {
    if (!canSwitchCamera || isBusy) return;

    final generation = ++_cameraGeneration;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _availableCameras.length;
    _setCameraState(CameraState.initializing);

    try {
      await _setupCameraController(
        _availableCameras[_selectedCameraIndex],
        generation,
      );
      if (generation != _cameraGeneration) return;
      _setCameraState(CameraState.cameraReady);
    } catch (e) {
      if (generation != _cameraGeneration) return;
      _errorMessage = 'Failed to switch camera.';
      _setCameraState(CameraState.error);
    }
  }

  // --- Capture & OCR Flow ---

  Future<void> captureImage({required Size viewSize}) async {
    if (_cameraController == null || !_cameraController!.value.isInitialized || isBusy) {
      return;
    }

    _setCameraState(CameraState.capturing);
    _errorMessage = null;

    try {
      final xFile = await _cameraController!.takePicture();
      final preview = _cameraController!.value.previewSize;
      _capturedImagePath = xFile.path;
      _lastFrame = ScanFrameInput(
        viewWidth: viewSize.width,
        viewHeight: viewSize.height,
        previewWidth: preview?.width ?? viewSize.width,
        previewHeight: preview?.height ?? viewSize.height,
      );
      await processImageFile(xFile.path, frame: _lastFrame);
    } on CameraException catch (e) {
      _errorMessage = 'Failed to capture image: ${e.description ?? e.code}';
      _setCameraState(CameraState.error);
    } catch (e) {
      _errorMessage = 'An error occurred while capturing the photo.';
      _setCameraState(CameraState.error);
    }
  }

  Future<void> pickImageFromGallery() async {
    if (isBusy) return;

    String? pickedPath;

    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 95,
      );
      if (pickedFile != null) {
        pickedPath = pickedFile.path;
      }
    } catch (_) {
      // Fallback to FilePicker on platforms where ImagePicker plugin is unavailable (e.g. Windows desktop)
      try {
        final file = await FilePicker.pickFile(
          type: FileType.image,
        );
        if (file != null && file.path != null) {
          pickedPath = file.path;
        }
      } catch (e) {
        _errorMessage = 'Could not access gallery image: ${e.toString()}';
        _setCameraState(CameraState.error);
        return;
      }
    }

    if (pickedPath == null) {
      // User cancelled picker - keep existing state
      return;
    }

    _capturedImagePath = pickedPath;
    _lastFrame = null;
    await processImageFile(pickedPath);
  }

  Future<void> processImageFile(
    String imagePath, {
    ScanFrameInput? frame,
  }) async {
    final support = OcrLanguageSupport.forCode(_sourceLanguage.code);
    if (!support.isSupported) {
      _capturedImagePath = imagePath;
      _detectedText = '';
      _translatedText = '';
      _errorMessage = support.unavailableMessage;
      _setCameraState(CameraState.error);
      return;
    }

    _setCameraState(CameraState.recognizing);
    _errorMessage = null;

    try {
      final preparedPath = await _imagePreparer.prepareForOcr(
        sourcePath: imagePath,
        frame: frame,
      );
      final text = await _ocrService.recognizeTextFromPath(
        preparedPath,
        script: support.kind,
      );

      if (text.trim().isEmpty) {
        _detectedText = '';
        _translatedText = '';
        _errorMessage =
            'No readable text was found in this image. Please ensure the text is clear, well-lit, and try again.';
        _setCameraState(CameraState.error);
        return;
      }

      _detectedText = text;
      _setCameraState(CameraState.ocrCompleted);

      // Auto-translate detected text into target language
      await translateDetectedText();
    } catch (e) {
      _errorMessage = 'Failed to recognize text from image. Please try again.';
      _setCameraState(CameraState.error);
    }
  }

  // --- Translation Flow ---

  Future<void> translateDetectedText() async {
    if (_detectedText.trim().isEmpty) return;

    _setCameraState(CameraState.translating);
    _errorMessage = null;

    try {
      final result = await _translationRepository.translate(
        _detectedText,
        from: _sourceLanguage.code,
        to: _targetLanguage.code,
      );

      _translatedText = result;
      _setCameraState(CameraState.translated);

      // Auto-save successful OCR translation to History
      if (result.isNotEmpty && !result.startsWith('Error:')) {
        final source = _limitHistoryText(_detectedText);
        final translated = _limitHistoryText(result);
        await _historyRepository.saveTranslation(
          sourceText: source,
          translatedText: translated,
          sourceLanguage: _sourceLanguage,
          targetLanguage: _targetLanguage,
          category: 'Camera / OCR',
        );
      }
    } catch (e) {
      _translatedText = '';
      _errorMessage =
          'Translation failed. Please check your internet connection or try again.';
      _setCameraState(CameraState.ocrCompleted);
    }
  }

  void setSourceLanguage(LanguageModel lang) {
    if (_sourceLanguage.code == lang.code) return;
    _sourceLanguage = lang;
    notifyListeners();

    if (_detectedText.isNotEmpty) {
      translateDetectedText();
    } else if (_capturedImagePath != null) {
      processImageFile(_capturedImagePath!, frame: _lastFrame);
    }
  }

  void setTargetLanguage(LanguageModel lang) {
    if (_targetLanguage.code == lang.code) return;
    _targetLanguage = lang;
    SpeechPreferences.apply(_flutterTts, languageCode: lang.code);
    notifyListeners();

    if (_detectedText.isNotEmpty) {
      translateDetectedText();
    }
  }

  void swapLanguages() {
    final temp = _sourceLanguage;
    _sourceLanguage = _targetLanguage;
    _targetLanguage = temp;
    SpeechPreferences.apply(_flutterTts, languageCode: _targetLanguage.code);
    notifyListeners();

    if (_detectedText.isNotEmpty) {
      translateDetectedText();
    } else if (_capturedImagePath != null) {
      processImageFile(_capturedImagePath!, frame: _lastFrame);
    }
  }

  String _limitHistoryText(String value) {
    final clean = value.trim();
    if (clean.length <= TranslationLimits.maxHistoryTextCharacters) return clean;
    return '${clean.substring(0, TranslationLimits.maxHistoryTextCharacters)}…';
  }

  // --- Actions ---

  Future<void> retake() async {
    _capturedImagePath = null;
    _lastFrame = null;
    _detectedText = '';
    _translatedText = '';
    _errorMessage = null;

    if (_cameraController != null && _cameraController!.value.isInitialized) {
      _setCameraState(CameraState.cameraReady);
    } else {
      await initializeCamera();
    }
  }

  Future<void> copyTranslatedText(BuildContext context) async {
    if (_translatedText.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: _translatedText));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Translation copied to clipboard'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> copyDetectedText(BuildContext context) async {
    if (_detectedText.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: _detectedText));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Detected text copied to clipboard'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> speakTranslation() async {
    if (_translatedText.isEmpty) return;
    await _flutterTts.stop();
    await SpeechPreferences.apply(
      _flutterTts,
      languageCode: _targetLanguage.code,
    );
    await _flutterTts.speak(_translatedText);
  }

  void _setCameraState(CameraState newState) {
    _state = newState;
    notifyListeners();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _ocrService.dispose();
    _flutterTts.stop();
    super.dispose();
  }
}
