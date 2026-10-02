import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:translator_app/apptheme/app_theme.dart';
import 'package:translator_app/core/router/app_routes.dart';
import 'package:translator_app/data/models/translation_history_model.dart';
import 'package:translator_app/view/components/custom_app_bar.dart';
import 'package:translator_app/view/components/custom_button.dart';
import 'package:translator_app/view/components/custom_chip.dart';
import 'package:translator_app/viewmodel/lang_model.dart';
import 'package:translator_app/viewmodel/translation_history_viewmodel.dart';
import 'package:translator_app/viewmodel/translation_viewmodel.dart';

class TranslationHistoryScreen extends StatelessWidget {
  const TranslationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TranslationHistoryViewModel>();

    final horizontalPadding = 17.w;

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
              size: 23.w,
            ),
            onPressed: vm.toggleSearch,
          ),

          // More Options Menu (Sort / Clear)
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert_rounded,
              color: AppColors.textWhite,
              size: 23.w,
            ),
            onSelected: (value) {
              if (value == 'sort_newest') {
                vm.setSortOrder(HistorySortOrder.newest);
              } else if (value == 'sort_oldest') {
                vm.setSortOrder(HistorySortOrder.oldest);
              } else if (value == 'clear_history') {
                _showClearHistoryDialog(context, vm);
              } else if (value == 'add_category') {
                _showAddCategoryDialog(context, vm);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'sort_newest',
                child: Row(
                  children: [
                    Icon(Icons.arrow_downward_rounded, size: 18.w, color: AppColors.primary),
                    SizedBox(width: 8.w),
                    const Text('Sort by Newest'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'sort_oldest',
                child: Row(
                  children: [
                    Icon(Icons.arrow_upward_rounded, size: 18.w, color: AppColors.primary),
                    SizedBox(width: 8.w),
                    const Text('Sort by Oldest'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'add_category',
                child: Row(
                  children: [
                    Icon(Icons.create_new_folder_rounded, size: 18.w, color: AppColors.primary),
                    SizedBox(width: 8.w),
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
                      Icon(Icons.delete_sweep_rounded, size: 18.w, color: AppColors.error),
                      SizedBox(width: 8.w),
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
                  vertical: 10.h,
                ),
                color: AppColors.surface,
                child: TextField(
                  controller: vm.searchController,
                  autofocus: true,
                  onChanged: vm.setSearchQuery,
                  style: GoogleFonts.outfit(
                    color: AppColors.textPrimary,
                    fontSize: 15.sp,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search words, phrases, or categories...',
                    hintStyle: GoogleFonts.outfit(
                      color: AppColors.textMuted,
                      fontSize: 14.sp,
                    ),
                    prefixIcon: Icon(Icons.search_rounded, color: AppColors.primary),
                    suffixIcon: vm.searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear_rounded, size: 18.w),
                            onPressed: vm.clearSearch,
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.inputBackground,
                    contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

            // 2. Category & Filter Tabs
            _buildCategoryTabs(context, vm),

            // 3. Main List or Empty State
            Expanded(
              child: vm.isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    )
                  : vm.filteredItems.isEmpty
                      ? _buildEmptyState(context, vm)
                      : _buildHistoryList(context, vm),
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
  ) {
    final tabs = [
      'All',
      '⭐ Favorites',
      ...vm.categories,
    ];

    return Container(
      height: 53.h,
      padding: EdgeInsets.symmetric(vertical: 7.h),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 17.w),
        itemCount: tabs.length + 1,
        separatorBuilder: (_, _) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          if (index == tabs.length) {
            // "+ Category" button
            return CustomChip(
              icon: Icons.add_rounded,
              label: 'Category',
              variant: CustomChipVariant.outlined,
              onTap: () => _showAddCategoryDialog(context, vm),
            );
          }

          final tab = tabs[index];
          final isSelected = vm.selectedCategoryFilter == tab;

          return CustomChip(
            label: tab,
            isSelected: isSelected,
            onTap: () => vm.setCategoryFilter(tab),
          );
        },
      ),
    );
  }

  // --- HISTORY LIST ---
  Widget _buildHistoryList(
    BuildContext context,
    TranslationHistoryViewModel vm,
  ) {
    final items = vm.filteredItems;

    return ListView.separated(
      padding: EdgeInsets.symmetric(
        horizontal: 17.w,
        vertical: 12.h,
      ),
      itemCount: items.length,
      separatorBuilder: (_, _) => SizedBox(height: 11.h),
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildHistoryCard(context, vm, item);
      },
    );
  }

  // --- INDIVIDUAL HISTORY CARD ---
  Widget _buildHistoryCard(
    BuildContext context,
    TranslationHistoryViewModel vm,
    TranslationHistoryItem item,
  ) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 19.w),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(17.r),
        ),
        child: Icon(Icons.delete_outline_rounded, color: AppColors.textWhite, size: 28.w),
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
        onTap: () => _showDetailModal(context, vm, item),
        borderRadius: BorderRadius.circular(17.r),
        child: Container(
          padding: EdgeInsets.all(15.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(17.r),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 8.r,
                offset: Offset(0, 2.h),
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
                      Text(item.sourceLanguageFlag, style: TextStyle(fontSize: 16.sp)),
                      SizedBox(width: 4.w),
                      Text(
                        item.sourceLanguageCode.toUpperCase(),
                        style: GoogleFonts.outfit(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Icon(Icons.arrow_forward_rounded, size: 14.w, color: AppColors.textMuted),
                      ),
                      Text(item.targetLanguageFlag, style: TextStyle(fontSize: 16.sp)),
                      SizedBox(width: 4.w),
                      Text(
                        item.targetLanguageCode.toUpperCase(),
                        style: GoogleFonts.outfit(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: 8.w),

                      // Category Badge
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: AppColors.inputBackground,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          item.category,
                          style: GoogleFonts.outfit(
                            fontSize: 10.sp,
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
                      color: item.isFavorite ? AppColors.favorite : AppColors.textMuted,
                      size: 23.w,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => vm.toggleFavorite(item.id),
                  ),
                ],
              ),

              SizedBox(height: 8.h),

              // Source Text
              Text(
                item.sourceText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  fontSize: 14.sp,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),

              SizedBox(height: 5.h),

              // Translated Text
              Text(
                item.translatedText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  fontSize: 14.sp,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),

              SizedBox(height: 8.h),

              // Bottom Actions: Date + Audio Speak + Copy
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatTimestamp(item.timestamp),
                    style: GoogleFonts.outfit(
                      fontSize: 11.sp,
                      color: AppColors.textMuted,
                    ),
                  ),
                  Row(
                    children: [
                      // Audio Speak (Target Language)
                      IconButton(
                        icon: Icon(
                          Icons.volume_up_rounded,
                          size: 18.w,
                          color: AppColors.primary,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: 'Listen',
                        onPressed: () => vm.speakText(item.translatedText, item.targetLanguageCode),
                      ),
                      SizedBox(width: 15.w),

                      // Copy Translated Text
                      IconButton(
                        icon: Icon(
                          Icons.copy_rounded,
                          size: 17.w,
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
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(23.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 19.w,
            right: 19.w,
            top: 20.h,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sheet Handle
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

              // Title & Category Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Translation Details',
                    style: GoogleFonts.outfit(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  // Category Selector Dropdown
                  PopupMenuButton<String>(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.inputBackground,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.folder_outlined, size: 14.w, color: AppColors.primary),
                          SizedBox(width: 4.w),
                          Text(
                            item.category,
                            style: GoogleFonts.outfit(
                              fontSize: 11.sp,
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

              SizedBox(height: 16.h),

              // Source Text Block
              Container(
                padding: EdgeInsets.all(13.w),
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(13.r),
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
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.copy_rounded, size: 16.w, color: AppColors.textSecondary),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => vm.copyToClipboard(context, item.sourceText, 'Original text'),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    SelectableText(
                      item.sourceText,
                      style: GoogleFonts.outfit(
                        fontSize: 15.sp,
                        color: AppColors.textPrimary,
                        height: 1.h,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12.h),

              // Translated Text Block
              Container(
                padding: EdgeInsets.all(13.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(13.r),
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
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.volume_up_rounded, size: 18.w, color: AppColors.primary),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => vm.speakText(item.translatedText, item.targetLanguageCode),
                            ),
                            SizedBox(width: 12.w),
                            IconButton(
                              icon: Icon(Icons.copy_rounded, size: 16.w, color: AppColors.primary),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => vm.copyToClipboard(context, item.translatedText, 'Translation'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    SelectableText(
                      item.translatedText,
                      style: GoogleFonts.outfit(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        height: 1.h,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // "Translate Again" Action
              CustomButton(
                text: 'Translate Again',
                leadingIcon: Icons.refresh_rounded,
                variant: ButtonVariant.filled,
                onPressed: () {
                  final translationVm = context.read<TranslationViewModel>();

                  translationVm.loadTranslationForReuse(
                    source: item.sourceText,
                    translated: item.translatedText,
                    sourceLang: LanguageModel.fromCode(item.sourceLanguageCode),
                    targetLang: LanguageModel.fromCode(item.targetLanguageCode),
                  );

                  Navigator.pop(context);
                  context.go(AppRoutes.translate);
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
        padding: EdgeInsets.all(30.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 68.w, color: AppColors.textMuted),
            SizedBox(height: 16.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 13.sp,
                color: AppColors.textSecondary,
                height: 1.h,
              ),
            ),
            if (vm.totalCount == 0 && vm.searchQuery.isEmpty) ...[
              SizedBox(height: 24.h),
              CustomButton(
                text: 'Start Translating',
                leadingIcon: Icons.translate_rounded,
                onPressed: () => context.go(AppRoutes.translate),
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
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17.r),
          ),
          title: Text(
            'Clear History',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to clear your translation history? You can choose to keep your starred favorites.',
            style: GoogleFonts.outfit(fontSize: 14.sp, color: AppColors.textSecondary),
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
  ) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17.r),
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
