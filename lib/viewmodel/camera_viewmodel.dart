import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:translator_app/data/models/translation_repository.dart';
import 'package:translator_app/data/repositories/translation_history_repository.dart';
import 'package:translator_app/data/services/ocr_service.dart';
import 'package:translator_app/viewmodel/lang_model.dart';

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
    _flutterTts.setLanguage(_targetLanguage.code);
    _flutterTts.setSpeechRate(0.5);
    _flutterTts.setPitch(1.0);
  }

  // --- Camera Lifecycle ---

  Future<void> initializeCamera() async {
    if (_state == CameraState.initializing) return;

    _setCameraState(CameraState.initializing);
    _errorMessage = null;

    try {
      _availableCameras = await availableCameras();
      if (_availableCameras.isEmpty) {
        _errorMessage = 'No camera found on this device.';
        _setCameraState(CameraState.error);
        return;
      }

      await _setupCameraController(_availableCameras[_selectedCameraIndex]);
      _setCameraState(CameraState.cameraReady);
    } on CameraException catch (e) {
      if (e.code == 'CameraAccessDenied' ||
          e.code == 'CameraAccessDeniedWithoutPrompt' ||
          e.code == 'CameraAccessRestricted') {
        _errorMessage =
            'Camera permission was denied. Please enable camera access in system settings.';
        _setCameraState(CameraState.permissionDenied);
      } else {
        _errorMessage = 'Failed to initialize camera: ${e.description ?? e.code}';
        _setCameraState(CameraState.error);
      }
    } catch (e) {
      _errorMessage = 'An unexpected error occurred while starting the camera.';
      _setCameraState(CameraState.error);
    }
  }

  Future<void> pauseCamera() async {
    final controller = _cameraController;
    if (controller != null) {
      _cameraController = null;
      notifyListeners();
      try {
        await controller.dispose();
      } catch (_) {
        // Ignore errors during dispose
      }
    }
  }

  Future<void> resumeCamera() async {
    if (_state == CameraState.cameraReady ||
        _state == CameraState.initial ||
        _state == CameraState.initializing) {
      await initializeCamera();
    }
  }

  Future<void> _setupCameraController(CameraDescription description) async {
    final oldController = _cameraController;
    if (oldController != null) {
      _cameraController = null;
      try {
        await oldController.dispose();
      } catch (_) {}
    }

    final newController = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    _cameraController = newController;
    await newController.initialize();
    await newController.setFlashMode(_flashMode);
  }

  Future<void> toggleFlash() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

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
      // Ignore flash mode change errors on unsupported hardware
    }
  }

  Future<void> switchCamera() async {
    if (!canSwitchCamera || isBusy) return;

    _selectedCameraIndex = (_selectedCameraIndex + 1) % _availableCameras.length;
    _setCameraState(CameraState.initializing);

    try {
      await _setupCameraController(_availableCameras[_selectedCameraIndex]);
      _setCameraState(CameraState.cameraReady);
    } catch (e) {
      _errorMessage = 'Failed to switch camera.';
      _setCameraState(CameraState.error);
    }
  }

  // --- Capture & OCR Flow ---

  Future<void> captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized || isBusy) {
      return;
    }

    _setCameraState(CameraState.capturing);
    _errorMessage = null;

    try {
      final xFile = await _cameraController!.takePicture();
      _capturedImagePath = xFile.path;
      await processImageFile(xFile.path);
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
    await processImageFile(pickedPath);
  }

  Future<void> processImageFile(String imagePath) async {
    _setCameraState(CameraState.recognizing);
    _errorMessage = null;

    try {
      final text = await _ocrService.recognizeTextFromPath(imagePath);

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
        await _historyRepository.saveTranslation(
          sourceText: _detectedText,
          translatedText: result,
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
    }
  }

  void setTargetLanguage(LanguageModel lang) {
    if (_targetLanguage.code == lang.code) return;
    _targetLanguage = lang;
    _flutterTts.setLanguage(lang.code);
    notifyListeners();

    if (_detectedText.isNotEmpty) {
      translateDetectedText();
    }
  }

  void swapLanguages() {
    final temp = _sourceLanguage;
    _sourceLanguage = _targetLanguage;
    _targetLanguage = temp;
    _flutterTts.setLanguage(_targetLanguage.code);
    notifyListeners();

    if (_detectedText.isNotEmpty) {
      translateDetectedText();
    }
  }

  // --- Actions ---

  Future<void> retake() async {
    _capturedImagePath = null;
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
