import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:translator_app/apptheme/app_theme.dart';
import 'package:translator_app/data/models/translation_history_model.dart';
import 'package:translator_app/view/components/custom_app_bar.dart';
import 'package:translator_app/view/components/custom_button.dart';
import 'package:translator_app/viewmodel/lang_model.dart';
import 'package:translator_app/viewmodel/main_nav_viewmodel.dart';
import 'package:translator_app/viewmodel/translation_history_viewmodel.dart';
import 'package:translator_app/viewmodel/translation_viewmodel.dart';

class TranslationHistoryScreen extends StatelessWidget {
  const TranslationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TranslationHistoryViewModel>();
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final horizontalPadding = screenWidth * 0.045;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CustomAppBar(
        title: 'History & Favorites',
        showBackButton: true,
        actions: [
          // Search Toggle
          IconButton(
            icon: Icon(
              vm.isSearchOpen ? Icons.close_rounded : Icons.search_rounded,
              color: AppColors.textWhite,
              size: screenWidth * 0.06,
            ),
            onPressed: vm.toggleSearch,
          ),

          // More Options Menu (Sort / Clear)
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert_rounded,
              color: AppColors.textWhite,
              size: screenWidth * 0.06,
            ),
            onSelected: (value) {
              if (value == 'sort_newest') {
                vm.setSortOrder(HistorySortOrder.newest);
              } else if (value == 'sort_oldest') {
                vm.setSortOrder(HistorySortOrder.oldest);
              } else if (value == 'clear_history') {
                _showClearHistoryDialog(context, vm, screenWidth);
              } else if (value == 'add_category') {
                _showAddCategoryDialog(context, vm, screenWidth);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'sort_newest',
                child: Row(
                  children: [
                    Icon(Icons.arrow_downward_rounded, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    const Text('Sort by Newest'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'sort_oldest',
                child: Row(
                  children: [
                    Icon(Icons.arrow_upward_rounded, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    const Text('Sort by Oldest'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'add_category',
                child: Row(
                  children: [
                    Icon(Icons.create_new_folder_rounded, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    const Text('New Category'),
                  ],
                ),
              ),
              if (vm.totalCount > 0) ...[
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'clear_history',
                  child: Row(
                    children: [
                      const Icon(Icons.delete_sweep_rounded, size: 18, color: AppColors.error),
                      const SizedBox(width: 8),
                      Text('Clear History', style: TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Search Bar (When toggled open)
            if (vm.isSearchOpen)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: screenHeight * 0.012,
                ),
                color: AppColors.surface,
                child: TextField(
                  controller: vm.searchController,
                  autofocus: true,
                  onChanged: vm.setSearchQuery,
                  style: GoogleFonts.outfit(
                    color: AppColors.textPrimary,
                    fontSize: screenWidth * 0.04,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search words, phrases, or categories...',
                    hintStyle: GoogleFonts.outfit(
                      color: AppColors.textMuted,
                      fontSize: screenWidth * 0.038,
                    ),
                    prefixIcon: Icon(Icons.search_rounded, color: AppColors.primary),
                    suffixIcon: vm.searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: vm.clearSearch,
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.inputBackground,
                    contentPadding: EdgeInsets.symmetric(vertical: screenHeight * 0.012),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.03),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

            // 2. Category & Filter Tabs
            _buildCategoryTabs(context, vm, screenWidth, screenHeight),

            // 3. Main List or Empty State
            Expanded(
              child: vm.isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    )
                  : vm.filteredItems.isEmpty
                      ? _buildEmptyState(context, vm, screenWidth, screenHeight)
                      : _buildHistoryList(context, vm, screenWidth, screenHeight),
            ),
          ],
        ),
      ),
    );
  }

  // --- CATEGORY TABS BAR ---
  Widget _buildCategoryTabs(
    BuildContext context,
    TranslationHistoryViewModel vm,
    double screenWidth,
    double screenHeight,
  ) {
    final tabs = [
      'All',
      '⭐ Favorites',
      ...vm.categories,
    ];

    return Container(
      height: screenHeight * 0.065,
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.008),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.045),
        itemCount: tabs.length + 1,
        separatorBuilder: (_, _) => SizedBox(width: screenWidth * 0.02),
        itemBuilder: (context, index) {
          if (index == tabs.length) {
            // "+ Category" button
            return ActionChip(
              avatar: Icon(Icons.add_rounded, size: 16, color: AppColors.primary),
              label: Text(
                'Category',
                style: GoogleFonts.outfit(
                  fontSize: screenWidth * 0.032,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.04),
                side: BorderSide(color: AppColors.border),
              ),
              onPressed: () => _showAddCategoryDialog(context, vm, screenWidth),
            );
          }

          final tab = tabs[index];
          final isSelected = vm.selectedCategoryFilter == tab;

          return FilterChip(
            selected: isSelected,
            label: Text(
              tab,
              style: GoogleFonts.outfit(
                fontSize: screenWidth * 0.034,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.textWhite : AppColors.textPrimary,
              ),
            ),
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.surface,
            checkmarkColor: AppColors.textWhite,
            showCheckmark: false,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(screenWidth * 0.04),
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
            ),
            onSelected: (_) => vm.setCategoryFilter(tab),
          );
        },
      ),
    );
  }

  // --- HISTORY LIST ---
  Widget _buildHistoryList(
    BuildContext context,
    TranslationHistoryViewModel vm,
    double screenWidth,
    double screenHeight,
  ) {
    final items = vm.filteredItems;

    return ListView.separated(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.045,
        vertical: screenHeight * 0.015,
      ),
      itemCount: items.length,
      separatorBuilder: (_, _) => SizedBox(height: screenHeight * 0.014),
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildHistoryCard(context, vm, item, screenWidth, screenHeight);
      },
    );
  }

  // --- INDIVIDUAL HISTORY CARD ---
  Widget _buildHistoryCard(
    BuildContext context,
    TranslationHistoryViewModel vm,
    TranslationHistoryItem item,
    double screenWidth,
    double screenHeight,
  ) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: screenWidth * 0.05),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(screenWidth * 0.045),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 28),
      ),
      onDismissed: (_) {
        vm.deleteItem(item.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Translation removed from history'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: InkWell(
        onTap: () => _showDetailModal(context, vm, item, screenWidth, screenHeight),
        borderRadius: BorderRadius.circular(screenWidth * 0.045),
        child: Container(
          padding: EdgeInsets.all(screenWidth * 0.04),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(screenWidth * 0.045),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Language Pair Flag + Category Badge + Star Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(item.sourceLanguageFlag, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 4),
                      Text(
                        item.sourceLanguageCode.toUpperCase(),
                        style: GoogleFonts.outfit(
                          fontSize: screenWidth * 0.03,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.0),
                        child: Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.textMuted),
                      ),
                      Text(item.targetLanguageFlag, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 4),
                      Text(
                        item.targetLanguageCode.toUpperCase(),
                        style: GoogleFonts.outfit(
                          fontSize: screenWidth * 0.03,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Category Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.inputBackground,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.category,
                          style: GoogleFonts.outfit(
                            fontSize: screenWidth * 0.026,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Favorite Toggle Star
                  IconButton(
                    icon: Icon(
                      item.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: item.isFavorite ? Colors.amber : AppColors.textMuted,
                      size: screenWidth * 0.06,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => vm.toggleFavorite(item.id),
                  ),
                ],
              ),

              SizedBox(height: screenHeight * 0.01),

              // Source Text
              Text(
                item.sourceText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  fontSize: (screenWidth * 0.038).clamp(13.0, 15.0),
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),

              SizedBox(height: screenHeight * 0.006),

              // Translated Text
              Text(
                item.translatedText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  fontSize: (screenWidth * 0.038).clamp(13.0, 15.0),
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),

              SizedBox(height: screenHeight * 0.01),

              // Bottom Actions: Date + Audio Speak + Copy
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatTimestamp(item.timestamp),
                    style: GoogleFonts.outfit(
                      fontSize: screenWidth * 0.028,
                      color: AppColors.textMuted,
                    ),
                  ),
                  Row(
                    children: [
                      // Audio Speak (Target Language)
                      IconButton(
                        icon: Icon(
                          Icons.volume_up_rounded,
                          size: screenWidth * 0.048,
                          color: AppColors.primary,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: 'Listen',
                        onPressed: () => vm.speakText(item.translatedText, item.targetLanguageCode),
                      ),
                      SizedBox(width: screenWidth * 0.04),

                      // Copy Translated Text
                      IconButton(
                        icon: Icon(
                          Icons.copy_rounded,
                          size: screenWidth * 0.045,
                          color: AppColors.textSecondary,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: 'Copy Translation',
                        onPressed: () => vm.copyToClipboard(context, item.translatedText, 'Translation'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- DETAIL MODAL BOTTOM SHEET ---
  void _showDetailModal(
    BuildContext context,
    TranslationHistoryViewModel vm,
    TranslationHistoryItem item,
    double screenWidth,
    double screenHeight,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(screenWidth * 0.06)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: screenWidth * 0.05,
            right: screenWidth * 0.05,
            top: screenHeight * 0.025,
            bottom: MediaQuery.of(context).viewInsets.bottom + screenHeight * 0.03,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sheet Handle
              Center(
                child: Container(
                  width: screenWidth * 0.12,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              // Title & Category Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Translation Details',
                    style: GoogleFonts.outfit(
                      fontSize: (screenWidth * 0.048).clamp(17.0, 20.0),
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  // Category Selector Dropdown
                  PopupMenuButton<String>(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.inputBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.folder_outlined, size: 14, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            item.category,
                            style: GoogleFonts.outfit(
                              fontSize: screenWidth * 0.03,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    onSelected: (newCategory) {
                      vm.updateItemCategory(item.id, newCategory);
                      Navigator.pop(context);
                    },
                    itemBuilder: (context) => vm.categories
                        .map(
                          (cat) => PopupMenuItem(
                            value: cat,
                            child: Text(cat),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),

              SizedBox(height: screenHeight * 0.02),

              // Source Text Block
              Container(
                padding: EdgeInsets.all(screenWidth * 0.035),
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(screenWidth * 0.035),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${item.sourceLanguageFlag} ${item.sourceLanguageName.toUpperCase()}',
                          style: GoogleFonts.outfit(
                            fontSize: screenWidth * 0.03,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.copy_rounded, size: 16, color: AppColors.textSecondary),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => vm.copyToClipboard(context, item.sourceText, 'Original text'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    SelectableText(
                      item.sourceText,
                      style: GoogleFonts.outfit(
                        fontSize: (screenWidth * 0.04).clamp(14.0, 16.0),
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenHeight * 0.015),

              // Translated Text Block
              Container(
                padding: EdgeInsets.all(screenWidth * 0.035),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(screenWidth * 0.035),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${item.targetLanguageFlag} ${item.targetLanguageName.toUpperCase()}',
                          style: GoogleFonts.outfit(
                            fontSize: screenWidth * 0.03,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.volume_up_rounded, size: 18, color: AppColors.primary),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => vm.speakText(item.translatedText, item.targetLanguageCode),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              icon: Icon(Icons.copy_rounded, size: 16, color: AppColors.primary),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => vm.copyToClipboard(context, item.translatedText, 'Translation'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    SelectableText(
                      item.translatedText,
                      style: GoogleFonts.outfit(
                        fontSize: (screenWidth * 0.042).clamp(15.0, 17.0),
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenHeight * 0.025),

              // "Translate Again" Action
              CustomButton(
                text: 'Translate Again',
                leadingIcon: Icons.refresh_rounded,
                variant: ButtonVariant.filled,
                onPressed: () {
                  final translationVm = context.read<TranslationViewModel>();
                  final navVm = context.read<MainNavViewModel>();

                  translationVm.loadTranslationForReuse(
                    source: item.sourceText,
                    translated: item.translatedText,
                    sourceLang: LanguageModel.fromCode(item.sourceLanguageCode),
                    targetLang: LanguageModel.fromCode(item.targetLanguageCode),
                  );

                  Navigator.pop(context); // Close sheet
                  Navigator.pop(context); // Exit history screen
                  navVm.setIndex(0); // Switch to Home Translator tab
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // --- EMPTY STATES ---
  Widget _buildEmptyState(
    BuildContext context,
    TranslationHistoryViewModel vm,
    double screenWidth,
    double screenHeight,
  ) {
    String title;
    String subtitle;
    IconData icon;

    if (vm.searchQuery.isNotEmpty) {
      title = 'No search results';
      subtitle = 'No translations match "${vm.searchQuery}". Try another keyword.';
      icon = Icons.search_off_rounded;
    } else if (vm.selectedCategoryFilter == '⭐ Favorites') {
      title = 'No starred favorites yet';
      subtitle = 'Tap the star icon on any translation to save it to your favorites for quick access.';
      icon = Icons.star_border_rounded;
    } else if (vm.selectedCategoryFilter != 'All') {
      title = 'No translations in ${vm.selectedCategoryFilter}';
      subtitle = 'Assign translations to this category to organize them neatly.';
      icon = Icons.folder_open_rounded;
    } else {
      title = 'No translation history';
      subtitle = 'Your translated sentences and phrases will automatically appear here.';
      icon = Icons.history_rounded;
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.08),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: screenWidth * 0.18, color: AppColors.textMuted),
            SizedBox(height: screenHeight * 0.02),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: (screenWidth * 0.048).clamp(17.0, 20.0),
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: (screenWidth * 0.035).clamp(13.0, 15.0),
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            if (vm.totalCount == 0 && vm.searchQuery.isEmpty) ...[
              SizedBox(height: screenHeight * 0.03),
              CustomButton(
                text: 'Start Translating',
                leadingIcon: Icons.translate_rounded,
                onPressed: () {
                  Navigator.pop(context);
                  context.read<MainNavViewModel>().setIndex(0);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  // --- DIALOGS ---
  void _showClearHistoryDialog(
    BuildContext context,
    TranslationHistoryViewModel vm,
    double screenWidth,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.045),
          ),
          title: Text(
            'Clear History',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to clear your translation history? You can choose to keep your starred favorites.',
            style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                vm.clearHistory(keepFavorites: true);
                Navigator.pop(context);
              },
              child: const Text('Clear (Keep Favorites)'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              onPressed: () {
                vm.clearHistory(keepFavorites: false);
                Navigator.pop(context);
              },
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
  }

  void _showAddCategoryDialog(
    BuildContext context,
    TranslationHistoryViewModel vm,
    double screenWidth,
  ) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.045),
          ),
          title: Text(
            'New Category',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'e.g. Shopping, Airport, Medical',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  vm.addCategory(controller.text.trim());
                  Navigator.pop(context);
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inDays < 1 && now.day == dt.day) {
      final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      final minute = dt.minute.toString().padLeft(2, '0');
      return 'Today, $hour:$minute $ampm';
    } else if (diff.inDays < 2) {
      return 'Yesterday';
    } else {
      return '${dt.day}/${dt.month}/${dt.year}';
    }
  }
}
