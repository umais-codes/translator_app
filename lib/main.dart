import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:translator_app/apptheme/app_theme.dart';
import 'package:translator_app/core/router/app_router.dart';
import 'package:translator_app/data/models/translation_repository.dart';
import 'package:translator_app/data/repositories/ai_repository.dart';
import 'package:translator_app/data/repositories/translation_history_repository.dart';
import 'package:translator_app/viewmodel/ai_viewmodel.dart';
import 'package:translator_app/viewmodel/camera_viewmodel.dart';
import 'package:translator_app/viewmodel/conversation_viewmodel.dart';
import 'package:translator_app/viewmodel/dictionary_viewmodel.dart';
import 'package:translator_app/viewmodel/file_translate_viewmodel.dart';
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
        ChangeNotifierProvider(
          create: (_) => ConversationViewModel(
            repository: translationRepository,
          ),
        ),
        ChangeNotifierProvider(create: (_) => DictionaryViewModel()),
        ChangeNotifierProvider(
          create: (_) => FileTranslateViewModel(
            repository: translationRepository,
          ),
        ),
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

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, _) {
        return MaterialApp.router(
          title: 'Translator App',
          theme: AppTheme.getTheme(primaryColor: settingsVm.primaryColor),
          debugShowCheckedModeBanner: false,
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
