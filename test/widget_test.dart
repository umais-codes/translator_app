import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:translator_app/data/models/translation_provider.dart';
import 'package:translator_app/data/models/translation_repository.dart';
import 'package:translator_app/data/repositories/translation_history_repository.dart';
import 'package:translator_app/main.dart';
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
  testWidgets('App smoke test initializes MyApp', (WidgetTester tester) async {
    final historyRepo = TranslationHistoryRepository();
    final translationRepo = TranslationRepository();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MainNavViewModel()),
          ChangeNotifierProvider(create: (_) => TranslationProvider()),
          ChangeNotifierProvider(
            create: (_) => TranslationViewModel(
              translationRepo,
              historyRepository: historyRepo,
            ),
          ),
          ChangeNotifierProvider(
            create: (_) => TranslationHistoryViewModel(historyRepo),
          ),
          ChangeNotifierProvider(
            create: (_) => CameraViewModel(
              translationRepo,
              historyRepository: historyRepo,
            ),
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

    // Allow splash animations and timer (2800ms) to complete
    await tester.pump(const Duration(milliseconds: 3000));
    await tester.pumpAndSettle();

    expect(find.byType(MyApp), findsOneWidget);
  });
}

