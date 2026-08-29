import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:translator_app/apptheme/app_theme.dart';
import 'package:translator_app/data/models/translation_provider.dart';
import 'package:translator_app/data/models/translation_repository.dart';
import 'package:translator_app/data/repositories/ai_repository.dart';
import 'package:translator_app/data/repositories/translation_history_repository.dart';
import 'package:translator_app/view/splash_screen.dart';
import 'package:translator_app/viewmodel/ai_viewmodel.dart';
import 'package:translator_app/viewmodel/auth_viewmodel.dart';
import 'package:translator_app/viewmodel/camera_viewmodel.dart';
import 'package:translator_app/viewmodel/conversation_viewmodel.dart';
import 'package:translator_app/viewmodel/dictionary_viewmodel.dart';
import 'package:translator_app/viewmodel/file_translate_viewmodel.dart';
import 'package:translator_app/viewmodel/main_nav_viewmodel.dart';
import 'package:translator_app/viewmodel/settings_viewmodel.dart';
import 'package:translator_app/viewmodel/translation_history_viewmodel.dart';
import 'package:translator_app/viewmodel/translation_viewmodel.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final historyRepository = TranslationHistoryRepository();
  final translationRepository = TranslationRepository();
  final aiRepository = AIRepository();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MainNavViewModel()),
        ChangeNotifierProvider(create: (_) => TranslationProvider()),
        ChangeNotifierProvider(
          create: (_) => TranslationViewModel(
            translationRepository,
            historyRepository: historyRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => TranslationHistoryViewModel(historyRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => CameraViewModel(
            translationRepository,
            historyRepository: historyRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AIViewModel(aiRepository),
        ),
        ChangeNotifierProvider(create: (_) => ConversationViewModel()),
        ChangeNotifierProvider(create: (_) => DictionaryViewModel()),
        ChangeNotifierProvider(create: (_) => FileTranslateViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsVm = context.watch<SettingsViewModel>();

    return MaterialApp(
      title: 'Translator App',
      theme: AppTheme.getTheme(primaryColor: settingsVm.primaryColor),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
