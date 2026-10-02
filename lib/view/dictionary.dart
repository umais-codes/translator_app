import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:translator_app/apptheme/app_theme.dart';
import 'package:translator_app/data/models/dictionary_model.dart';
import 'package:translator_app/viewmodel/dictionary_viewmodel.dart';

class DictionaryScreen extends StatelessWidget {
  const DictionaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DictionaryViewModel>();

    final horizontalPadding = 17.w;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 12.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Search Bar
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 8.r,
                  offset: Offset(0, 2.h),
                ),
              ],
            ),
            child: TextField(
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  vm.searchWord(value.trim());
                }
              },
              style: GoogleFonts.outfit(
                color: AppColors.textPrimary,
                fontSize: 15.sp,
              ),
              decoration: InputDecoration(
                hintText: 'Search word (e.g. "Eloquent", "Inspire")...',
                hintStyle: GoogleFonts.outfit(
                  color: AppColors.textMuted,
                  fontSize: 14.sp,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: AppColors.primary,
                ),
                suffixIcon: vm.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear_rounded,
                          size: 18.w,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: vm.clear,
                      )
                    : null,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                fillColor: AppColors.transparent,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 15.w,
                  vertical: 13.h,
                ),
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // 2. State Handling: Loading, Error, Content, Empty
          if (vm.isLoading) ...[
            SizedBox(height: 81.h),
            Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ] else if (vm.errorMessage != null) ...[
            _buildErrorState(vm.errorMessage!),
          ] else if (vm.entry != null) ...[
            _buildDictionaryContent(
              context,
              vm.entry!,
              vm,
            ),
          ] else ...[
            _buildEmptyState(context, vm),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    DictionaryViewModel vm,
  ) {
    final suggestedWords = ['Resilient', 'Serendipity', 'Eloquent', 'Luminary', 'Ephemeral'];

    return Column(
      children: [
        SizedBox(height: 33.h),
        Container(
          width: 83.w,
          height: 83.w,
          decoration: BoxDecoration(
            color: AppColors.lightBlueBackground,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Icon(
            Icons.menu_book_rounded,
            size: 41.w,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          'Instant Smart Dictionary',
          style: GoogleFonts.outfit(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 7.h),
        Text(
          'Type any word above to explore comprehensive definitions, pronunciations, examples, and synonyms.',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: 13.sp,
            color: AppColors.textSecondary,
            height: 1.h,
          ),
        ),
        SizedBox(height: 24.h),

        // Quick Suggestions Tag Cloud
        Text(
          'POPULAR SEARCHES',
          style: GoogleFonts.outfit(
            fontSize: 11.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.sp,
            color: AppColors.textMuted,
          ),
        ),
        SizedBox(height: 10.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          alignment: WrapAlignment.center,
          children: suggestedWords.map((word) {
            return InkWell(
              onTap: () {
                vm.searchWord(word);
              },
              borderRadius: BorderRadius.circular(20.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  word,
                  style: GoogleFonts.outfit(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildErrorState(
    String message,
  ) {
    return Container(
      padding: EdgeInsets.all(23.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 45.w,
            color: AppColors.error,
          ),
          SizedBox(height: 12.h),
          Text(
            'Definition Not Found',
            style: GoogleFonts.outfit(
              fontSize: 17.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 7.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 13.sp,
              color: AppColors.textSecondary,
              height: 1.h,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDictionaryContent(
    BuildContext context,
    DictionaryEntry entry,
    DictionaryViewModel vm,
  ) {
    final partsOfSpeech = vm.partsOfSpeech;
    final filteredMeanings = vm.filteredMeanings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Word Header Card
        Container(
          padding: EdgeInsets.all(17.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 8.r,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.word,
                      style: GoogleFonts.outfit(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (entry.phonetic != null && entry.phonetic!.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text(
                        entry.phonetic!,
                        style: GoogleFonts.outfit(
                          fontSize: 14.sp,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.copy_rounded,
                  size: 20.w,
                  color: AppColors.textSecondary,
                ),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: entry.word));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Copied "${entry.word}" to clipboard!'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.volume_up_rounded,
                    color: AppColors.textWhite,
                    size: 22.w,
                  ),
                  onPressed: vm.speakWord,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 12.h),

        // Filter Pills for Parts of Speech
        if (partsOfSpeech.length > 1) ...[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', 'all', vm),
                ...partsOfSpeech.map(
                  (pos) => _buildFilterChip(pos, pos, vm),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
        ],

        // Detailed Meanings & Definitions
        ...filteredMeanings.map(
          (meaning) => _buildMeaningSection(meaning),
        ),

        // Global Synonyms & Antonyms Card
        if (entry.allSynonyms.isNotEmpty || entry.allAntonyms.isNotEmpty) ...[
          SizedBox(height: 8.h),
          _buildThesaurusCard(entry, vm),
        ],
      ],
    );
  }

  Widget _buildFilterChip(
    String label,
    String value,
    DictionaryViewModel vm,
  ) {
    final isSelected = vm.selectedPartOfSpeech == value;
    final borderRadius = 17.r;

    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: ChoiceChip(
        showCheckmark: false,
        label: Text(
          label.toUpperCase(),
          style: GoogleFonts.outfit(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.sp,
            color: isSelected ? AppColors.textWhite : AppColors.textPrimary,
          ),
        ),
        selected: isSelected,
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1.w,
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        elevation: isSelected ? 2.r : 0,
        shadowColor: AppColors.shadowPrimary,
        onSelected: (selected) {
          if (selected) {
            vm.setSelectedPartOfSpeech(value);
          }
        },
      ),
    );
  }

  Widget _buildMeaningSection(
    MeaningModel meaning,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 6.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.lightBlueBackground,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              meaning.partOfSpeech.toUpperCase(),
              style: GoogleFonts.outfit(
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.sp,
                color: AppColors.primary,
              ),
            ),
          ),
          Divider(height: 20.h, color: AppColors.borderLight),
          ...meaning.definitions.asMap().entries.map((entry) {
            final idx = entry.key + 1;
            final def = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20.w,
                    height: 20.w,
                    margin: EdgeInsets.only(top: 2.h, right: 10.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$idx',
                        style: GoogleFonts.outfit(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          def.definition,
                          style: GoogleFonts.outfit(
                            fontSize: 14.sp,
                            color: AppColors.textPrimary,
                            height: 1.h,
                          ),
                        ),
                        if (def.example != null && def.example!.isNotEmpty) ...[
                          SizedBox(height: 4.h),
                          Text(
                            '"${def.example!}"',
                            style: GoogleFonts.outfit(
                              fontSize: 12.sp,
                              fontStyle: FontStyle.italic,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildThesaurusCard(
    DictionaryEntry entry,
    DictionaryViewModel vm,
  ) {
    return Container(
      padding: EdgeInsets.all(17.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Synonyms & Antonyms',
            style: GoogleFonts.outfit(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 10.h),
          if (entry.allSynonyms.isNotEmpty) ...[
            Wrap(
              spacing: 6.w,
              runSpacing: 6.h,
              children: entry.allSynonyms.take(8).map((syn) {
                return InkWell(
                  onTap: () => vm.searchWord(syn),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.lightGreenBackground,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      syn,
                      style: GoogleFonts.outfit(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
