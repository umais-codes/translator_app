import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:translator_app/apptheme/app_theme.dart';
import 'package:translator_app/viewmodel/lang_model.dart';

class LanguagePickerViewModel extends ChangeNotifier {
  final List<LanguageModel> allLanguages;
  List<LanguageModel> _filteredLanguages;
  String _searchQuery = '';

  LanguagePickerViewModel(this.allLanguages) : _filteredLanguages = allLanguages;

  List<LanguageModel> get filteredLanguages => _filteredLanguages;
  String get searchQuery => _searchQuery;

  void filter(String query) {
    _searchQuery = query;
    if (query.trim().isEmpty) {
      _filteredLanguages = allLanguages;
    } else {
      final q = query.toLowerCase();
      _filteredLanguages = allLanguages
          .where((l) =>
              l.name.toLowerCase().contains(q) ||
              l.nativeName.toLowerCase().contains(q) ||
              l.code.toLowerCase().contains(q))
          .toList();
    }
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _filteredLanguages = allLanguages;
    notifyListeners();
  }
}

class LanguagePickerModal extends StatelessWidget {
  final String title;
  final List<LanguageModel> languages;
  final LanguageModel selectedLanguage;
  final ValueChanged<LanguageModel> onSelected;

  const LanguagePickerModal({
    super.key,
    required this.title,
    required this.languages,
    required this.selectedLanguage,
    required this.onSelected,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    List<LanguageModel>? languages,
    required LanguageModel selectedLanguage,
    required ValueChanged<LanguageModel> onSelected,
  }) {
    final list = languages ?? LanguageModel.supportedLanguages;
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ChangeNotifierProvider(
        create: (_) => LanguagePickerViewModel(list),
        child: LanguagePickerModal(
          title: title,
          languages: list,
          selectedLanguage: selectedLanguage,
          onSelected: onSelected,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LanguagePickerViewModel>();
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final filteredLanguages = vm.filteredLanguages;

    return Container(
      height: screenHeight * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: screenHeight * 0.015,
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.02),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: screenWidth * 0.048,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.012),

          // Search Field with Clear Button
          Container(
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              onChanged: vm.filter,
              style: GoogleFonts.outfit(
                color: AppColors.textPrimary,
                fontSize: screenWidth * 0.04,
              ),
              decoration: InputDecoration(
                hintText: 'Search by language or country...',
                hintStyle: GoogleFonts.outfit(
                  color: AppColors.textMuted,
                  fontSize: screenWidth * 0.038,
                ),
                prefixIcon: Icon(Icons.search_rounded, color: AppColors.primary),
                suffixIcon: vm.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18, color: AppColors.textSecondary),
                        onPressed: vm.clearSearch,
                      )
                    : null,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.015),

          // Languages Count
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${filteredLanguages.length} Languages available',
              style: GoogleFonts.outfit(
                fontSize: screenWidth * 0.032,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.01),

          // Language List
          Expanded(
            child: ListView.separated(
              itemCount: filteredLanguages.length,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                color: AppColors.borderLight,
              ),
              itemBuilder: (context, index) {
                final lang = filteredLanguages[index];
                final isSelected = lang.code == selectedLanguage.code;

                return InkWell(
                  onTap: () {
                    onSelected(lang);
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.025,
                      vertical: screenHeight * 0.014,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.lightBlueBackground : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        // Flag Avatar Circle
                        Container(
                          width: screenWidth * 0.1,
                          height: screenWidth * 0.1,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.surface : AppColors.inputBackground,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppColors.border,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              lang.flag,
                              style: TextStyle(fontSize: screenWidth * 0.05),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Language Name & Native Name
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lang.name,
                                style: GoogleFonts.outfit(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                lang.nativeName,
                                style: GoogleFonts.outfit(
                                  fontSize: screenWidth * 0.032,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Selection Checkmark
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              size: 16,
                              color: AppColors.textWhite,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
