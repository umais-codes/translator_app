import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:translator_app/apptheme/app_theme.dart';
import 'package:translator_app/core/router/app_routes.dart';
import 'package:translator_app/view/ai/ai_tools_screen.dart';
import 'package:translator_app/view/camera.dart';
import 'package:translator_app/view/conversation.dart';
import 'package:translator_app/view/dictionary.dart';
import 'package:translator_app/view/file_translate.dart';
import 'package:translator_app/view/history/translation_history_screen.dart';
import 'package:translator_app/view/home/home_translate_view.dart';
import 'package:translator_app/view/home/main_navigation_screen.dart';
import 'package:translator_app/view/more_fun.dart';
import 'package:translator_app/view/settings.dart';
import 'package:translator_app/view/settings/help_feedback_screen.dart';
import 'package:translator_app/view/settings/offline_settings_screen.dart';
import 'package:translator_app/view/settings/privacy_policy_screen.dart';
import 'package:translator_app/view/settings/theme_settings_screen.dart';
import 'package:translator_app/view/settings/tts_settings_screen.dart';
import 'package:translator_app/view/settings/voice_settings_screen.dart';
import 'package:translator_app/view/splash_screen.dart';

/// Single app router. Kept outside [build] so theme rebuilds do not reset the stack.
abstract final class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    errorBuilder: (context, state) => RouteErrorScreen(
      location: state.uri.toString(),
    ),
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainNavigationScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.translate,
                builder: (context, state) => const HomeTranslateView(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.conversation,
                builder: (context, state) => const Conversation(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.dictionary,
                builder: (context, state) => const DictionaryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.tools,
                builder: (context, state) => const MoreFunScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.history,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const TranslationHistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.camera,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const CameraScreen(),
      ),
      GoRoute(
        path: AppRoutes.ai,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const AIToolsScreen(),
      ),
      GoRoute(
        path: AppRoutes.files,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const FileTranslationScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const Settings(),
        routes: [
          GoRoute(
            path: 'tts',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => const TtsSettingsScreen(),
          ),
          GoRoute(
            path: 'voice',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => const VoiceSettingsScreen(),
          ),
          GoRoute(
            path: 'theme',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => const ThemeSettingsScreen(),
          ),
          GoRoute(
            path: 'offline',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => const OfflineSettingsScreen(),
          ),
          GoRoute(
            path: 'privacy',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => const PrivacyPolicyScreen(),
          ),
          GoRoute(
            path: 'help',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => const HelpFeedbackScreen(),
          ),
        ],
      ),
    ],
  );
}

class RouteErrorScreen extends StatelessWidget {
  const RouteErrorScreen({super.key, required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Page not found',
                  style: GoogleFonts.outfit(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  location,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 24.h),
                FilledButton(
                  onPressed: () => context.go(AppRoutes.translate),
                  child: const Text('Go to translator'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
