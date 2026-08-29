import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:translator_app/apptheme/app_theme.dart';
import 'package:translator_app/view/components/custom_app_bar.dart';
import 'package:translator_app/view/components/custom_bottom_nav.dart';
import 'package:translator_app/view/conversation.dart';
import 'package:translator_app/view/dictionary.dart';
import 'package:translator_app/view/home/home_translate_view.dart';
import 'package:translator_app/view/more_fun.dart';
import 'package:translator_app/view/settings.dart';
import 'package:translator_app/viewmodel/main_nav_viewmodel.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navVm = context.watch<MainNavViewModel>();
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    return Scaffold(
      appBar: CustomAppBar(
        title: _getTitle(navVm.currentIndex),
        showBackButton: false,
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: AppColors.textWhite,
              size: screenWidth * 0.06,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Settings()),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: navVm.currentIndex,
        children: const [
          HomeTranslateView(),
          Conversation(),
          DictionaryScreen(),
          MoreFunScreen(),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: navVm.currentIndex,
        onTap: navVm.setIndex,
      ),
    );
  }

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'Translator';
      case 1:
        return 'Conversation';
      case 2:
        return 'Dictionary';
      case 3:
        return 'Tools & Features';
      default:
        return 'Translator';
    }
  }
}
