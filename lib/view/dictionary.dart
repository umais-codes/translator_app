import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:translator_app/apptheme/app_theme.dart';
import 'package:translator_app/view/components/custom_app_bar.dart';
import 'package:translator_app/viewmodel/dictionary_viewmodel.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DictionaryViewModel>();
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final horizontalPadding = screenWidth * 0.05;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Dictionary',
        showBackButton: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Field
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: screenHeight * 0.02,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadow,
                      spreadRadius: 2,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      vm.searchWord(value.trim());
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Search for a word',
                    labelStyle: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: screenWidth * 0.038,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    fillColor: Colors.transparent,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: screenHeight * 0.018,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.search,
                        color: AppColors.primary,
                        size: screenWidth * 0.06,
                      ),
                      onPressed: () {
                        if (_searchController.text.isNotEmpty) {
                          vm.searchWord(_searchController.text.trim());
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),

            // Main Content Area
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: vm.isLoading
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                            SizedBox(height: screenHeight * 0.015),
                            Text(
                              'Searching...',
                              style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        )
                      : vm.errorMessage != null
                          ? Text(
                              vm.errorMessage!,
                              style: TextStyle(
                                color: AppColors.error,
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            )
                          : vm.definition != null
                              ? _buildWordDetails(vm, screenWidth, screenHeight)
                              : const SizedBox(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable Widget: Word Details
  Widget _buildWordDetails(
    DictionaryViewModel vm,
    double screenWidth,
    double screenHeight,
  ) {
    return SizedBox(
      width: double.infinity,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        padding: EdgeInsets.all(screenWidth * 0.05),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              spreadRadius: 2,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Word:', vm.word, screenWidth),
            _buildDetailRow('Phonetics:', vm.phonetics, screenWidth, isItalic: true),
            _buildDetailRow('Part of Speech:', vm.partOfSpeech, screenWidth),
            _buildDetailRow('Definition:', vm.definition, screenWidth),
            if (vm.example != null && vm.example!.isNotEmpty)
              _buildExampleSection(vm.example!, screenWidth, screenHeight),
            if (vm.synonyms != null && vm.synonyms!.isNotEmpty)
              _buildListSection('Synonyms:', vm.synonyms!, screenWidth),
            if (vm.antonyms != null && vm.antonyms!.isNotEmpty)
              _buildListSection('Antonyms:', vm.antonyms!, screenWidth),
          ],
        ),
      ),
    );
  }

  // Reusable Widget: Detail Row
  Widget _buildDetailRow(
    String label,
    String? value,
    double screenWidth, {
    bool isItalic = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: screenWidth * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: screenWidth * 0.042,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value ?? 'Not available',
            style: TextStyle(
              fontSize: screenWidth * 0.038,
              color: AppColors.textPrimary,
              fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ],
      ),
    );
  }

  // Reusable Widget: Example Section
  Widget _buildExampleSection(
    String example,
    double screenWidth,
    double screenHeight,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: screenWidth * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Example:',
            style: TextStyle(
              fontSize: screenWidth * 0.042,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(screenWidth * 0.03),
            decoration: BoxDecoration(
              color: AppColors.lightBlueBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              example,
              style: TextStyle(
                fontSize: screenWidth * 0.038,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Reusable Widget: List Section (for Synonyms and Antonyms)
  Widget _buildListSection(
    String label,
    List<String> items,
    double screenWidth,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: screenWidth * 0.03),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: screenWidth * 0.042,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: screenWidth * 0.02,
            runSpacing: screenWidth * 0.015,
            children: items
                .map(
                  (item) => Chip(
                    label: Text(
                      item,
                      style: TextStyle(
                        fontSize: screenWidth * 0.034,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    backgroundColor: AppColors.lightBlueBackground,
                    side: const BorderSide(color: AppColors.border),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
