import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:translator_app/apptheme/app_theme.dart';
import 'package:translator_app/data/models/translation_provider.dart';
import 'package:translator_app/data/models/translation_repository.dart';
import 'package:translator_app/view/file_translate.dart';
import 'package:translator_app/viewmodel/auth_viewmodel.dart';
import 'package:translator_app/viewmodel/conversation_viewmodel.dart';
import 'package:translator_app/viewmodel/dictionary_viewmodel.dart';
import 'package:translator_app/viewmodel/file_translate_viewmodel.dart';
import 'package:translator_app/viewmodel/translation_viewmodel.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TranslationProvider()),
        ChangeNotifierProvider(
          create: (_) => TranslationViewModel(TranslationRepository()),
        ),
        ChangeNotifierProvider(create: (_) => ConversationViewModel()),
        ChangeNotifierProvider(create: (_) => DictionaryViewModel()),
        ChangeNotifierProvider(create: (_) => FileTranslateViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Translator App',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const FileTranslationScreen(),
    );
  }
}
