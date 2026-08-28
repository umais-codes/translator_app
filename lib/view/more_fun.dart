import 'package:flutter/material.dart';
import 'package:translator_app/apptheme/app_theme.dart';
import 'package:translator_app/view/components/custom_app_bar.dart';
import 'package:translator_app/view/dictionary.dart';
import 'package:translator_app/view/file_translate.dart';
import 'package:translator_app/view/settings.dart';

class MoreFunScreen extends StatelessWidget {
  const MoreFunScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final horizontalPadding = screenWidth * 0.05;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'More Fun',
        showBackButton: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings,
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
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: screenHeight * 0.02,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildButton(
                context,
                color: AppColors.lightBlueCard,
                icon: Icons.description,
                title: 'File translate',
                subtitle: 'Ask anything from AI experts',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FileTranslationScreen(),
                    ),
                  );
                },
              ),
              SizedBox(height: screenHeight * 0.02),
              _buildButton(
                context,
                color: AppColors.lightGreenBackground,
                icon: Icons.book,
                title: 'Dictionary',
                subtitle: 'Ask anything from AI experts',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DictionaryScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required Color color,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: Container(
          width: double.infinity,
          height: screenHeight * 0.12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Icon(
                  icon,
                  size: screenWidth * 0.1,
                  color: AppColors.primary,
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: screenWidth * 0.048,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.005),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: screenWidth * 0.036,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Icon(
                  Icons.chevron_right,
                  size: screenWidth * 0.06,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
