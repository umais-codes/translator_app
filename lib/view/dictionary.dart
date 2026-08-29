import 'package:flutter/material.dart';
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
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final horizontalPadding = screenWidth * 0.045;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: screenHeight * 0.015,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Search Bar
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 8,
                  offset: Offset(0, 2),
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
                fontSize: screenWidth * 0.04,
              ),
              decoration: InputDecoration(
                hintText: 'Search word (e.g. "Eloquent", "Inspire")...',
                hintStyle: GoogleFonts.outfit(
                  color: AppColors.textMuted,
                  fontSize: screenWidth * 0.038,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: AppColors.primary,
                ),
                suffixIcon: vm.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear_rounded,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: vm.clear,
                      )
                    : null,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                fillColor: Colors.transparent,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.016,
                ),
              ),
            ),
          ),

          SizedBox(height: screenHeight * 0.02),

          // 2. State Handling: Loading, Error, Content, Empty
          if (vm.isLoading) ...[
            SizedBox(height: screenHeight * 0.1),
            Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ] else if (vm.errorMessage != null) ...[
            _buildErrorState(vm.errorMessage!, screenWidth, screenHeight),
          ] else if (vm.entry != null) ...[
            _buildDictionaryContent(
              context,
              vm.entry!,
              vm,
              screenWidth,
              screenHeight,
            ),
          ] else ...[
            _buildEmptyState(context, vm, screenWidth, screenHeight),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    DictionaryViewModel vm,
    double screenWidth,
    double screenHeight,
  ) {
    final suggestedWords = ['Resilient', 'Serendipity', 'Eloquent', 'Luminary', 'Ephemeral'];

    return Column(
      children: [
        SizedBox(height: screenHeight * 0.04),
        Container(
          width: screenWidth * 0.22,
          height: screenWidth * 0.22,
          decoration: BoxDecoration(
            color: AppColors.lightBlueBackground,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(
            Icons.menu_book_rounded,
            size: screenWidth * 0.11,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
        Text(
          'Instant Smart Dictionary',
          style: GoogleFonts.outfit(
            fontSize: screenWidth * 0.048,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: screenHeight * 0.008),
        Text(
          'Type any word above to explore comprehensive definitions, pronunciations, examples, and synonyms.',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: screenWidth * 0.035,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        SizedBox(height: screenHeight * 0.03),

        // Quick Suggestions Tag Cloud
        Text(
          'POPULAR SEARCHES',
          style: GoogleFonts.outfit(
            fontSize: screenWidth * 0.03,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: AppColors.textMuted,
          ),
        ),
        SizedBox(height: screenHeight * 0.012),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: suggestedWords.map((word) {
            return InkWell(
              onTap: () {
                vm.searchWord(word);
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  word,
                  style: GoogleFonts.outfit(
                    fontSize: screenWidth * 0.033,
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
    double screenWidth,
    double screenHeight,
  ) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.06),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: screenWidth * 0.12,
            color: AppColors.error,
          ),
          SizedBox(height: screenHeight * 0.015),
          Text(
            'Definition Not Found',
            style: GoogleFonts.outfit(
              fontSize: screenWidth * 0.044,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: screenHeight * 0.008),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: screenWidth * 0.034,
              color: AppColors.textSecondary,
              height: 1.4,
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
    double screenWidth,
    double screenHeight,
  ) {
    final partsOfSpeech = vm.partsOfSpeech;
    final filteredMeanings = vm.filteredMeanings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Word Header Card
        Container(
          padding: EdgeInsets.all(screenWidth * 0.045),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 8,
                offset: Offset(0, 2),
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
                        fontSize: screenWidth * 0.065,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (entry.phonetic != null && entry.phonetic!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        entry.phonetic!,
                        style: GoogleFonts.outfit(
                          fontSize: screenWidth * 0.038,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.copy_rounded,
                  size: 20,
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
                  icon: const Icon(
                    Icons.volume_up_rounded,
                    color: AppColors.textWhite,
                    size: 22,
                  ),
                  onPressed: vm.speakWord,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: screenHeight * 0.015),

        // Filter Pills for Parts of Speech
        if (partsOfSpeech.length > 1) ...[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', 'all', vm, screenWidth),
                ...partsOfSpeech.map(
                  (pos) => _buildFilterChip(pos, pos, vm, screenWidth),
                ),
              ],
            ),
          ),
          SizedBox(height: screenHeight * 0.015),
        ],

        // Detailed Meanings & Definitions
        ...filteredMeanings.map(
          (meaning) => _buildMeaningSection(meaning, screenWidth, screenHeight),
        ),

        // Global Synonyms & Antonyms Card
        if (entry.allSynonyms.isNotEmpty || entry.allAntonyms.isNotEmpty) ...[
          SizedBox(height: screenHeight * 0.01),
          _buildThesaurusCard(entry, vm, screenWidth, screenHeight),
        ],
      ],
    );
  }

  Widget _buildFilterChip(
    String label,
    String value,
    DictionaryViewModel vm,
    double screenWidth,
  ) {
    final isSelected = vm.selectedPartOfSpeech == value;
    final borderRadius = (screenWidth * 0.045).clamp(16.0, 22.0);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        showCheckmark: false,
        label: Text(
          label.toUpperCase(),
          style: GoogleFonts.outfit(
            fontSize: (screenWidth * 0.031).clamp(11.0, 13.0),
            fontWeight: FontWeight.bold,
            letterSpacing: 0.6,
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
            width: 1.2,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        elevation: isSelected ? 1.5 : 0,
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
    double screenWidth,
    double screenHeight,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.015),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.lightBlueBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              meaning.partOfSpeech.toUpperCase(),
              style: GoogleFonts.outfit(
                fontSize: screenWidth * 0.03,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                color: AppColors.primary,
              ),
            ),
          ),
          const Divider(height: 20, color: AppColors.borderLight),
          ...meaning.definitions.asMap().entries.map((entry) {
            final idx = entry.key + 1;
            final def = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.only(top: 2, right: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$idx',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
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
                            fontSize: screenWidth * 0.037,
                            color: AppColors.textPrimary,
                            height: 1.35,
                          ),
                        ),
                        if (def.example != null && def.example!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            '"${def.example!}"',
                            style: GoogleFonts.outfit(
                              fontSize: screenWidth * 0.033,
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
    double screenWidth,
    double screenHeight,
  ) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.045),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Synonyms & Antonyms',
            style: GoogleFonts.outfit(
              fontSize: screenWidth * 0.038,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: screenHeight * 0.012),
          if (entry.allSynonyms.isNotEmpty) ...[
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: entry.allSynonyms.take(8).map((syn) {
                return InkWell(
                  onTap: () => vm.searchWord(syn),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.lightGreenBackground,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      syn,
                      style: GoogleFonts.outfit(
                        fontSize: screenWidth * 0.031,
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
