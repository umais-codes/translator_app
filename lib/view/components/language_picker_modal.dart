import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
      backgroundColor: AppColors.transparent,
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

    final filteredLanguages = vm.filteredLanguages;

    return Container(
      height: 609.h,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20.r,
            offset: Offset(0, -5.h),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 19.w,
        vertical: 12.h,
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 18.sp,
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
          SizedBox(height: 10.h),

          // Search Field with Clear Button
          Container(
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              onChanged: vm.filter,
              style: GoogleFonts.outfit(
                color: AppColors.textPrimary,
                fontSize: 15.sp,
              ),
              decoration: InputDecoration(
                hintText: 'Search by language or country...',
                hintStyle: GoogleFonts.outfit(
                  color: AppColors.textMuted,
                  fontSize: 14.sp,
                ),
                prefixIcon: Icon(Icons.search_rounded, color: AppColors.primary),
                suffixIcon: vm.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear_rounded, size: 18.w, color: AppColors.textSecondary),
                        onPressed: vm.clearSearch,
                      )
                    : null,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                fillColor: AppColors.transparent,
                contentPadding: EdgeInsets.symmetric(vertical: 14.h),
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // Languages Count
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${filteredLanguages.length} Languages available',
              style: GoogleFonts.outfit(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          SizedBox(height: 8.h),

          // Language List
          Expanded(
            child: ListView.separated(
              itemCount: filteredLanguages.length,
              separatorBuilder: (context, index) => Divider(
                height: 1.h,
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
                  borderRadius: BorderRadius.circular(14.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 9.w,
                      vertical: 11.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.lightBlueBackground : AppColors.transparent,
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Row(
                      children: [
                        // Flag Avatar Circle
                        Container(
                          width: 38.w,
                          height: 38.w,
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
                              style: TextStyle(fontSize: 19.sp),
                            ),
                          ),
                        ),
                        SizedBox(width: 14.w),

                        // Language Name & Native Name
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lang.name,
                                style: GoogleFonts.outfit(
                                  fontSize: 15.sp,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                lang.nativeName,
                                style: GoogleFonts.outfit(
                                  fontSize: 12.sp,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Selection Checkmark
                        if (isSelected)
                          Container(
                            padding: EdgeInsets.all(4.r),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check_rounded,
                              size: 16.w,
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
