import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:translator_app/apptheme/app_theme.dart';
import 'package:translator_app/data/models/ai_models.dart';
import 'package:translator_app/view/components/custom_app_bar.dart';
import 'package:translator_app/view/components/custom_button.dart';
import 'package:translator_app/view/components/custom_chip.dart';
import 'package:translator_app/viewmodel/ai_viewmodel.dart';
import 'package:translator_app/viewmodel/lang_model.dart';

class AIToolsScreen extends StatelessWidget {
  const AIToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AIViewModel>();

    final horizontalPadding = 17.w;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: const CustomAppBar(
        title: 'AI Language Intelligence',
        showBackButton: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Feature Tabs (Tone / Grammar / Nuance)
            _buildTabSelector(context, vm),

            // 2. Main Tab Body
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 12.h,
                ),
                child: _buildCurrentTabContent(
                  context,
                  vm,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- TAB SELECTOR ---
  Widget _buildTabSelector(
    BuildContext context,
    AIViewModel vm,
  ) {
    final tabs = [
      {'label': 'Tone Rephraser', 'icon': Icons.auto_fix_high_rounded},
      {'label': 'Grammar Check', 'icon': Icons.spellcheck_rounded},
      {'label': 'Nuance Insights', 'icon': Icons.lightbulb_outline_rounded},
    ];

    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.symmetric(
        horizontal: 15.w,
        vertical: 8.h,
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = vm.selectedTabIndex == index;
          final item = tabs[index];

          return Expanded(
            child: GestureDetector(
              onTap: () => vm.setSelectedTab(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : AppColors.transparent,
                  borderRadius: BorderRadius.circular(11.r),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.transparent,
                    width: 2.w,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      size: 19.w,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textMuted,
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      item['label'] as String,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 11.sp,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // --- TAB CONTENT DISPATCHER ---
  Widget _buildCurrentTabContent(
    BuildContext context,
    AIViewModel vm,
  ) {
    switch (vm.selectedTabIndex) {
      case 0:
        return _buildToneRephraseTab(context, vm);
      case 1:
        return _buildGrammarExplainerTab(
          context,
          vm,
        );
      case 2:
        return _buildNuanceExplainerTab(context, vm);
      default:
        return const SizedBox.shrink();
    }
  }

  // ==========================================
  // TAB 1: AI TONE REPHRASER
  // ==========================================
  Widget _buildToneRephraseTab(
    BuildContext context,
    AIViewModel vm,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Input Box
        _buildInputCard(
          vm: vm,
          controller: vm.toneInputController,
          hintText: 'Enter a phrase to rephrase, such as “Can you send the report?”',
          title: 'Original text',
        ),

        SizedBox(height: 16.h),

        // Section Title: Tone Options
        Text(
          'Select Target Tone',
          style: GoogleFonts.outfit(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),

        // Tone Pills Wrap
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: AIToneOption.values.map((tone) {
            final isSelected = vm.selectedTone == tone;
            return CustomChip(
              label: tone.label,
              isSelected: isSelected,
              onTap: () => vm.setSelectedTone(tone),
            );
          }).toList(),
        ),

        SizedBox(height: 16.h),

        // Section: Length Preference
        Text(
          'Length Preference',
          style: GoogleFonts.outfit(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 7.h),

        Row(
          children: AILengthOption.values.map((len) {
            final isSelected = vm.selectedLength == len;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: CustomChip(
                  label: len.label,
                  isSelected: isSelected,
                  isExpanded: true,
                  variant: CustomChipVariant.filled,
                  onTap: () => vm.setSelectedLength(len),
                ),
              ),
            );
          }).toList(),
        ),

        SizedBox(height: 18.h),

        // Error message if any
        if (vm.errorMessage != null)
          _buildErrorBanner(vm.errorMessage!),

        // CTA Button
        CustomButton(
          text: vm.isLoading ? 'Rewriting with AI...' : 'Rephrase with AI',
          leadingIcon: Icons.auto_awesome_rounded,
          isLoading: vm.isLoading,
          onPressed: vm.isLoading ? null : vm.rephraseTone,
        ),

        // Result Card
        if (vm.toneResult != null) ...[
          SizedBox(height: 20.h),
          _buildToneResultCard(
            context,
            vm,
            vm.toneResult!,
          ),
        ],
      ],
    );
  }

  Widget _buildToneResultCard(
    BuildContext context,
    AIViewModel vm,
    AIToneResponse result,
  ) {
    return Container(
      padding: EdgeInsets.all(17.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(17.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        size: 14.w,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 6.w),
                      Flexible(
                        child: Text(
                          '${result.tone.label.toUpperCase()} REPHRASING',
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8.w),

              // Audio & Copy actions
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.volume_up_rounded,
                      size: 19.w,
                      color: AppColors.primary,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Listen',
                    onPressed: () => vm.speakText(
                      result.rephrasedText,
                      vm.selectedLanguage.code,
                    ),
                  ),
                  SizedBox(width: 11.w),
                  IconButton(
                    icon: Icon(
                      Icons.copy_rounded,
                      size: 17.w,
                      color: AppColors.textSecondary,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Copy',
                    onPressed: () => vm.copyToClipboard(
                      context,
                      result.rephrasedText,
                      'Rephrased text',
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 10.h),

          // Primary Result Text
          SelectableText(
            result.rephrasedText,
            style: GoogleFonts.outfit(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.h,
            ),
          ),

          if (result.toneNotes != null) ...[
            SizedBox(height: 8.h),
            Text(
              result.toneNotes!,
              style: GoogleFonts.outfit(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],

          // Alternative variations
          if (result.alternatives.isNotEmpty) ...[
            SizedBox(height: 15.h),
            Text(
              'Alternative Variations:',
              style: GoogleFonts.outfit(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 7.h),
            ...result.alternatives.map(
              (alt) => Container(
                margin: EdgeInsets.only(bottom: 7.h),
                padding: EdgeInsets.all(11.w),
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(11.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        alt,
                        style: GoogleFonts.outfit(
                          fontSize: 13.sp,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.copy_rounded, size: 16.w),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () =>
                          vm.copyToClipboard(context, alt, 'Alternative'),
                    ),
                  ],
                ),
              ),
            ),
          ],

          SizedBox(height: 15.h),

          // "Replace in Translator" CTA
          CustomButton(
            text: 'Use in Translator',
            variant: ButtonVariant.outlined,
            leadingIcon: Icons.swap_horiz_rounded,
            onPressed: () =>
                vm.replaceIntoTranslator(context, result.rephrasedText),
          ),
        ],
      ),
    );
  }

  // ==========================================d
  // TAB 2: AI GRAMMAR EXPLAINER
  // ==========================================
  Widget _buildGrammarExplainerTab(
    BuildContext context,
    AIViewModel vm,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Language Selector Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Target Language',
              style: GoogleFonts.outfit(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            CustomChip(
              label: '${vm.selectedLanguage.flag} ${vm.selectedLanguage.name}',
              isSelected: true,
              size: CustomChipSize.small,
              onTap: () => _showLanguagePicker(
                context,
                vm.selectedLanguage,
                (lang) => vm.setSelectedLanguage(lang),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),

        _buildInputCard(
          vm: vm,
          controller: vm.grammarInputController,
          hintText: 'Enter a sentence to check, such as “I has completed my work”',
          title: 'Text to check',
        ),

        SizedBox(height: 16.h),

        if (vm.errorMessage != null)
          _buildErrorBanner(vm.errorMessage!),

        CustomButton(
          text: vm.isLoading ? 'Analyzing Grammar...' : 'Analyze Grammar',
          leadingIcon: Icons.spellcheck_rounded,
          isLoading: vm.isLoading,
          onPressed: vm.isLoading ? null : vm.explainGrammar,
        ),

        if (vm.grammarResult != null) ...[
          SizedBox(height: 20.h),
          _buildGrammarResultCard(
            context,
            vm,
            vm.grammarResult!,
          ),
        ],
      ],
    );
  }

  Widget _buildGrammarResultCard(
    BuildContext context,
    AIViewModel vm,
    AIGrammarResponse result,
  ) {
    final statusColor = result.hasErrors
        ? AppColors.warning
        : AppColors.success;
    final statusText = result.hasErrors
        ? 'Grammar Correction'
        : 'Grammatically Correct';
    final statusIcon = result.hasErrors
        ? Icons.warning_amber_rounded
        : Icons.check_circle_outline_rounded;

    return Container(
      padding: EdgeInsets.all(17.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(17.r),
        border: Border.all(color: statusColor.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Status Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 16.w, color: statusColor),
                      SizedBox(width: 6.w),
                      Flexible(
                        child: Text(
                          statusText.toUpperCase(),
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8.w),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.volume_up_rounded,
                      size: 19.w,
                      color: AppColors.textSecondary,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Speak',
                    onPressed: () => vm.speakText(
                      result.correctedText,
                      vm.selectedLanguage.code,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  IconButton(
                    icon: Icon(
                      Icons.copy_rounded,
                      size: 17.w,
                      color: AppColors.textSecondary,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Copy Corrected',
                    onPressed: () => vm.copyToClipboard(
                      context,
                      result.correctedText,
                      'Corrected text',
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Corrected Text Card
          Container(
            padding: EdgeInsets.all(13.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(11.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CORRECTED SENTENCE',
                  style: GoogleFonts.outfit(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 4.h),
                SelectableText(
                  result.correctedText,
                  style: GoogleFonts.outfit(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 12.h),

          // Explanation
          Text(
            'Explanation:',
            style: GoogleFonts.outfit(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 5.h),
          if (result.isBasicCheck) ...[
            Text(
              'Basic on-device check. A model service is not configured, so this only fixes common spelling and simple grammar patterns.',
              style: GoogleFonts.outfit(
                fontSize: 12.sp,
                color: AppColors.warning,
                height: 1.h,
              ),
            ),
            SizedBox(height: 7.h),
          ],
          Text(
            result.explanation,
            style: GoogleFonts.outfit(
              fontSize: 13.sp,
              color: AppColors.textSecondary,
              height: 1.h,
            ),
          ),

          SizedBox(height: 12.h),

          // Grammar Rule Badge
          Container(
            padding: EdgeInsets.all(11.w),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(11.r),
            ),
            child: Row(
              children: [
                Icon(Icons.rule_rounded, size: 16.w, color: AppColors.primary),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Rule: ${result.grammarRule}',
                    style: GoogleFonts.outfit(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Examples
          if (result.examples.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text(
              'Examples & Usage:',
              style: GoogleFonts.outfit(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 5.h),
            ...result.examples.map(
              (ex) => Padding(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        ex,
                        style: GoogleFonts.outfit(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          SizedBox(height: 16.h),

          CustomButton(
            text: 'Use in Translator',
            variant: ButtonVariant.outlined,
            leadingIcon: Icons.swap_horiz_rounded,
            onPressed: () =>
                vm.replaceIntoTranslator(context, result.correctedText),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 3: TRANSLATION NUANCE EXPLAINER
  // ==========================================
  Widget _buildNuanceExplainerTab(
    BuildContext context,
    AIViewModel vm,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Language Pairing Selector Bar
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 11.w,
            vertical: 7.h,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(11.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _showLanguagePicker(
                    context,
                    vm.nuanceSourceLang,
                    (lang) => vm.setNuanceSourceLang(lang),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${vm.nuanceSourceLang.flag} ${vm.nuanceSourceLang.name}',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w600,
                          fontSize: 13.sp,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(Icons.arrow_drop_down, size: 18.w, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.swap_horiz_rounded, color: AppColors.primary),
                tooltip: 'Swap Languages',
                onPressed: vm.swapNuanceLanguages,
              ),
              Expanded(
                child: InkWell(
                  onTap: () => _showLanguagePicker(
                    context,
                    vm.nuanceTargetLang,
                    (lang) => vm.setNuanceTargetLang(lang),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${vm.nuanceTargetLang.flag} ${vm.nuanceTargetLang.name}',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w600,
                          fontSize: 13.sp,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(Icons.arrow_drop_down, size: 18.w, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 12.h),

        _buildInputCard(
          vm: vm,
          controller: vm.nuanceSourceController,
          hintText: 'Original phrase, such as “I miss you”',
          title: 'Original phrase · ${vm.nuanceSourceLang.name}',
        ),

        SizedBox(height: 12.h),

        _buildInputCard(
          vm: vm,
          controller: vm.nuanceTargetController,
          hintText: 'Translated phrase, such as “Te extraño”',
          title: 'Translated phrase · ${vm.nuanceTargetLang.name}',
        ),

        SizedBox(height: 16.h),

        if (vm.errorMessage != null)
          _buildErrorBanner(vm.errorMessage!),

        CustomButton(
          text: vm.isLoading
              ? 'Analyzing Nuances...'
              : 'Explain Nuances & Context',
          leadingIcon: Icons.lightbulb_outline_rounded,
          isLoading: vm.isLoading,
          onPressed: vm.isLoading ? null : vm.explainNuance,
        ),

        if (vm.nuanceResult != null) ...[
          SizedBox(height: 20.h),
          _buildNuanceResultCard(
            context,
            vm,
            vm.nuanceResult!,
          ),
        ],
      ],
    );
  }

  Widget _buildNuanceResultCard(
    BuildContext context,
    AIViewModel vm,
    AINuanceResponse result,
  ) {
    return Container(
      padding: EdgeInsets.all(17.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(17.r),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_rounded, size: 16.w, color: AppColors.info),
                    SizedBox(width: 6.w),
                    Text(
                      'LINGUISTIC & CULTURAL INSIGHTS',
                      style: GoogleFonts.outfit(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.info,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.copy_rounded,
                  size: 17.w,
                  color: AppColors.textSecondary,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Copy Insights',
                onPressed: () => vm.copyToClipboard(
                  context,
                  '${result.whyChosen}\n\nContext: ${result.contextOfUse}',
                  'Nuance insights',
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Why this wording was chosen
          Text(
            'Why This Wording:',
            style: GoogleFonts.outfit(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            result.whyChosen,
            style: GoogleFonts.outfit(
              fontSize: 13.sp,
              color: AppColors.textSecondary,
              height: 1.h,
            ),
          ),

          SizedBox(height: 12.h),

          // Context of Use
          Text(
            'Context of Use:',
            style: GoogleFonts.outfit(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            result.contextOfUse,
            style: GoogleFonts.outfit(
              fontSize: 13.sp,
              color: AppColors.textSecondary,
              height: 1.h,
            ),
          ),

          // Cultural Etiquette
          if (result.culturalEtiquette != null) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(11.w),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(11.r),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.public_rounded,
                    size: 16.w,
                    color: AppColors.warning,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      result.culturalEtiquette!,
                      style: GoogleFonts.outfit(
                        fontSize: 12.sp,
                        color: AppColors.textPrimary,
                        height: 1.h,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Alternatives
          if (result.alternatives.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text(
              'Regional & Stylistic Alternatives:',
              style: GoogleFonts.outfit(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 5.h),
            ...result.alternatives.map(
              (alt) => Padding(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                child: Text(
                  '• $alt',
                  style: GoogleFonts.outfit(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputCard({
    required AIViewModel vm,
    required TextEditingController controller,
    required String hintText,
    required String title,
  }) {
    final hasText = controller.text.isNotEmpty;

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Text(
                '${controller.text.length}',
                style: GoogleFonts.outfit(
                  fontSize: 12.sp,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: TextField(
              controller: controller,
              minLines: 3,
              maxLines: 6,
              style: GoogleFonts.outfit(
                fontSize: 16.sp,
                color: AppColors.textPrimary,
                height: 1.35,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: GoogleFonts.outfit(
                  color: AppColors.textMuted,
                  fontSize: 14.sp,
                  height: 1.35,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isCollapsed: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _fieldAction(
                icon: Icons.content_paste_rounded,
                label: 'Paste',
                onTap: () => vm.pasteInto(controller),
              ),
              if (hasText) ...[
                SizedBox(width: 8.w),
                _fieldAction(
                  icon: Icons.close_rounded,
                  label: 'Clear',
                  color: AppColors.error,
                  onTap: () => vm.clearInput(controller),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _fieldAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final tint = color ?? AppColors.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: tint.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16.w, color: tint),
            SizedBox(width: 6.w),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: tint,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(11.w),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(11.r),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 18.w, color: AppColors.error),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.outfit(
                fontSize: 12.sp,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker(
    BuildContext context,
    LanguageModel current,
    Function(LanguageModel) onSelect,
  ) {

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Container(
            height: 447.h,
            padding: EdgeInsets.symmetric(
              horizontal: 15.w,
              vertical: 16.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                Text(
                  'Select Language',
                  style: GoogleFonts.outfit(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 10.h),
                Expanded(
                  child: ListView.separated(
                    itemCount: LanguageModel.supportedLanguages.length,
                    separatorBuilder: (_, _) => Divider(height: 1.h),
                    itemBuilder: (ctx, idx) {
                      final lang = LanguageModel.supportedLanguages[idx];
                      final isSelected = lang.code == current.code;

                      return ListTile(
                        leading: Text(lang.flag, style: TextStyle(fontSize: 22.sp)),
                        title: Text(
                          lang.name,
                          style: GoogleFonts.outfit(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? AppColors.primary : AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          lang.nativeName,
                          style: GoogleFonts.outfit(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check_circle_rounded, color: AppColors.primary)
                            : null,
                        onTap: () {
                          onSelect(lang);
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
