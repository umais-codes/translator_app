import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:translator_app/apptheme/app_theme.dart';
import 'package:translator_app/data/models/ai_models.dart';
import 'package:translator_app/view/components/custom_app_bar.dart';
import 'package:translator_app/view/components/custom_button.dart';
import 'package:translator_app/viewmodel/ai_viewmodel.dart';
import 'package:translator_app/viewmodel/lang_model.dart';

class AIToolsScreen extends StatelessWidget {
  const AIToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AIViewModel>();
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final horizontalPadding = screenWidth * 0.045;

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
            _buildTabSelector(context, vm, screenWidth, screenHeight),

            // 2. Main Tab Body
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: screenHeight * 0.015,
                ),
                child: _buildCurrentTabContent(context, vm, screenWidth, screenHeight),
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
    double screenWidth,
    double screenHeight,
  ) {
    final tabs = [
      {'label': 'Tone Rephraser', 'icon': Icons.auto_fix_high_rounded},
      {'label': 'Grammar Check', 'icon': Icons.spellcheck_rounded},
      {'label': 'Nuance Insights', 'icon': Icons.lightbulb_outline_rounded},
    ];

    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenHeight * 0.01,
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
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      size: screenWidth * 0.05,
                      color: isSelected ? AppColors.primary : AppColors.textMuted,
                    ),
                    SizedBox(height: screenHeight * 0.004),
                    Text(
                      item['label'] as String,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: (screenWidth * 0.029).clamp(11.0, 13.0),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? AppColors.primary : AppColors.textSecondary,
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
    double screenWidth,
    double screenHeight,
  ) {
    switch (vm.selectedTabIndex) {
      case 0:
        return _buildToneRephraseTab(context, vm, screenWidth, screenHeight);
      case 1:
        return _buildGrammarExplainerTab(context, vm, screenWidth, screenHeight);
      case 2:
        return _buildNuanceExplainerTab(context, vm, screenWidth, screenHeight);
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
    double screenWidth,
    double screenHeight,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Input Box
        _buildInputCard(
          controller: vm.toneInputController,
          hintText: 'Enter phrase to rephrase with AI (e.g. Can you send the report?)...',
          title: 'ORIGINAL TEXT',
          screenWidth: screenWidth,
          screenHeight: screenHeight,
        ),

        SizedBox(height: screenHeight * 0.02),

        // Section Title: Tone Options
        Text(
          'Select Target Tone',
          style: GoogleFonts.outfit(
            fontSize: (screenWidth * 0.038).clamp(14.0, 16.0),
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: screenHeight * 0.01),

        // Tone Pills Wrap
        Wrap(
          spacing: screenWidth * 0.02,
          runSpacing: screenHeight * 0.01,
          children: AIToneOption.values.map((tone) {
            final isSelected = vm.selectedTone == tone;
            return ChoiceChip(
              label: Text(tone.label),
              selected: isSelected,
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surface,
              labelStyle: GoogleFonts.outfit(
                fontSize: (screenWidth * 0.032).clamp(12.0, 14.0),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.textWhite : AppColors.textPrimary,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.04),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
              onSelected: (_) => vm.setSelectedTone(tone),
            );
          }).toList(),
        ),

        SizedBox(height: screenHeight * 0.018),

        // Section Title: Length Options
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Length Preference',
              style: GoogleFonts.outfit(
                fontSize: (screenWidth * 0.035).clamp(13.0, 15.0),
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Row(
              children: AILengthOption.values.map((len) {
                final isSelected = vm.selectedLength == len;
                return Padding(
                  padding: EdgeInsets.only(left: screenWidth * 0.015),
                  child: FilterChip(
                    label: Text(len.label),
                    selected: isSelected,
                    selectedColor: AppColors.primary.withValues(alpha: 0.15),
                    backgroundColor: AppColors.surface,
                    showCheckmark: false,
                    labelStyle: GoogleFonts.outfit(
                      fontSize: (screenWidth * 0.03).clamp(11.0, 13.0),
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.03),
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    onSelected: (_) => vm.setSelectedLength(len),
                  ),
                );
              }).toList(),
            ),
          ],
        ),

        SizedBox(height: screenHeight * 0.022),

        // Error message if any
        if (vm.errorMessage != null) _buildErrorBanner(vm.errorMessage!, screenWidth),

        // CTA Button
        CustomButton(
          text: vm.isLoading ? 'Rewriting with AI...' : 'Rephrase with AI',
          leadingIcon: Icons.auto_awesome_rounded,
          isLoading: vm.isLoading,
          onPressed: vm.isLoading ? null : vm.rephraseTone,
        ),

        // Result Card
        if (vm.toneResult != null) ...[
          SizedBox(height: screenHeight * 0.025),
          _buildToneResultCard(context, vm, vm.toneResult!, screenWidth, screenHeight),
        ],
      ],
    );
  }

  Widget _buildToneResultCard(
    BuildContext context,
    AIViewModel vm,
    AIToneResponse result,
    double screenWidth,
    double screenHeight,
  ) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.045),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(screenWidth * 0.045),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 3),
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      '${result.tone.label.toUpperCase()} REPHRASING',
                      style: GoogleFonts.outfit(
                        fontSize: (screenWidth * 0.028).clamp(11.0, 13.0),
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              // Audio & Copy actions
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.volume_up_rounded, size: screenWidth * 0.05, color: AppColors.primary),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Listen',
                    onPressed: () => vm.speakText(result.rephrasedText, vm.selectedLanguage.code),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  IconButton(
                    icon: Icon(Icons.copy_rounded, size: screenWidth * 0.045, color: AppColors.textSecondary),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Copy',
                    onPressed: () => vm.copyToClipboard(context, result.rephrasedText, 'Rephrased text'),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: screenHeight * 0.012),

          // Primary Result Text
          SelectableText(
            result.rephrasedText,
            style: GoogleFonts.outfit(
              fontSize: (screenWidth * 0.042).clamp(15.0, 17.0),
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),

          if (result.toneNotes != null) ...[
            SizedBox(height: screenHeight * 0.01),
            Text(
              result.toneNotes!,
              style: GoogleFonts.outfit(
                fontSize: (screenWidth * 0.032).clamp(11.0, 13.0),
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],

          // Alternative variations
          if (result.alternatives.isNotEmpty) ...[
            SizedBox(height: screenHeight * 0.018),
            Text(
              'Alternative Variations:',
              style: GoogleFonts.outfit(
                fontSize: (screenWidth * 0.032).clamp(11.0, 13.0),
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: screenHeight * 0.008),
            ...result.alternatives.map((alt) => Container(
                  margin: EdgeInsets.only(bottom: screenHeight * 0.008),
                  padding: EdgeInsets.all(screenWidth * 0.03),
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          alt,
                          style: GoogleFonts.outfit(
                            fontSize: (screenWidth * 0.035).clamp(12.0, 14.0),
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy_rounded, size: 16),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => vm.copyToClipboard(context, alt, 'Alternative'),
                      ),
                    ],
                  ),
                )),
          ],

          SizedBox(height: screenHeight * 0.018),

          // "Replace in Translator" CTA
          CustomButton(
            text: 'Use in Translator',
            variant: ButtonVariant.outlined,
            leadingIcon: Icons.swap_horiz_rounded,
            onPressed: () => vm.replaceIntoTranslator(context, result.rephrasedText),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: AI GRAMMAR EXPLAINER
  // ==========================================
  Widget _buildGrammarExplainerTab(
    BuildContext context,
    AIViewModel vm,
    double screenWidth,
    double screenHeight,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInputCard(
          controller: vm.grammarInputController,
          hintText: 'Enter sentence to check (e.g. I has completed my work)...',
          title: 'TEXT TO CHECK',
          screenWidth: screenWidth,
          screenHeight: screenHeight,
        ),

        SizedBox(height: screenHeight * 0.02),

        if (vm.errorMessage != null) _buildErrorBanner(vm.errorMessage!, screenWidth),

        CustomButton(
          text: vm.isLoading ? 'Analyzing Grammar...' : 'Analyze Grammar',
          leadingIcon: Icons.spellcheck_rounded,
          isLoading: vm.isLoading,
          onPressed: vm.isLoading ? null : vm.explainGrammar,
        ),

        if (vm.grammarResult != null) ...[
          SizedBox(height: screenHeight * 0.025),
          _buildGrammarResultCard(context, vm, vm.grammarResult!, screenWidth, screenHeight),
        ],
      ],
    );
  }

  Widget _buildGrammarResultCard(
    BuildContext context,
    AIViewModel vm,
    AIGrammarResponse result,
    double screenWidth,
    double screenHeight,
  ) {
    final statusColor = result.hasErrors ? AppColors.warning : AppColors.success;
    final statusText = result.hasErrors ? 'Grammar Correction' : 'Grammatically Correct';
    final statusIcon = result.hasErrors ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.045),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(screenWidth * 0.045),
        border: Border.all(color: statusColor.withValues(alpha: 0.4)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 3),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(statusIcon, size: 16, color: statusColor),
                    const SizedBox(width: 6),
                    Text(
                      statusText.toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontSize: (screenWidth * 0.028).clamp(11.0, 13.0),
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                icon: Icon(Icons.copy_rounded, size: screenWidth * 0.045, color: AppColors.textSecondary),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Copy Corrected',
                onPressed: () => vm.copyToClipboard(context, result.correctedText, 'Corrected text'),
              ),
            ],
          ),

          SizedBox(height: screenHeight * 0.015),

          // Corrected Text Card
          Container(
            padding: EdgeInsets.all(screenWidth * 0.035),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(screenWidth * 0.03),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CORRECTED SENTENCE',
                  style: GoogleFonts.outfit(
                    fontSize: screenWidth * 0.028,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  result.correctedText,
                  style: GoogleFonts.outfit(
                    fontSize: (screenWidth * 0.04).clamp(14.0, 16.0),
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: screenHeight * 0.015),

          // Why this is incorrect / Explanation
          Text(
            'Explanation:',
            style: GoogleFonts.outfit(
              fontSize: (screenWidth * 0.034).clamp(12.0, 14.0),
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: screenHeight * 0.006),
          Text(
            result.explanation,
            style: GoogleFonts.outfit(
              fontSize: (screenWidth * 0.035).clamp(13.0, 15.0),
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),

          SizedBox(height: screenHeight * 0.015),

          // Grammar Rule Badge
          Container(
            padding: EdgeInsets.all(screenWidth * 0.03),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(screenWidth * 0.03),
            ),
            child: Row(
              children: [
                Icon(Icons.rule_rounded, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Rule: ${result.grammarRule}',
                    style: GoogleFonts.outfit(
                      fontSize: (screenWidth * 0.032).clamp(12.0, 14.0),
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
            SizedBox(height: screenHeight * 0.015),
            Text(
              'Examples & Usage:',
              style: GoogleFonts.outfit(
                fontSize: (screenWidth * 0.032).clamp(11.0, 13.0),
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: screenHeight * 0.006),
            ...result.examples.map((ex) => Padding(
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.003),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• ', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Text(
                          ex,
                          style: GoogleFonts.outfit(
                            fontSize: (screenWidth * 0.032).clamp(11.0, 13.0),
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],

          SizedBox(height: screenHeight * 0.02),

          CustomButton(
            text: 'Use in Translator',
            variant: ButtonVariant.outlined,
            leadingIcon: Icons.swap_horiz_rounded,
            onPressed: () => vm.replaceIntoTranslator(context, result.correctedText),
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
    double screenWidth,
    double screenHeight,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInputCard(
          controller: vm.nuanceSourceController,
          hintText: 'Original phrase (e.g. I miss you)...',
          title: 'ORIGINAL PHRASE',
          screenWidth: screenWidth,
          screenHeight: screenHeight,
        ),

        SizedBox(height: screenHeight * 0.015),

        _buildInputCard(
          controller: vm.nuanceTargetController,
          hintText: 'Translated phrase (e.g. Te extraño)...',
          title: 'TRANSLATED PHRASE',
          screenWidth: screenWidth,
          screenHeight: screenHeight,
        ),

        SizedBox(height: screenHeight * 0.02),

        if (vm.errorMessage != null) _buildErrorBanner(vm.errorMessage!, screenWidth),

        CustomButton(
          text: vm.isLoading ? 'Analyzing Nuances...' : 'Explain Nuances & Context',
          leadingIcon: Icons.lightbulb_outline_rounded,
          isLoading: vm.isLoading,
          onPressed: vm.isLoading ? null : vm.explainNuance,
        ),

        if (vm.nuanceResult != null) ...[
          SizedBox(height: screenHeight * 0.025),
          _buildNuanceResultCard(context, vm, vm.nuanceResult!, screenWidth, screenHeight),
        ],
      ],
    );
  }

  Widget _buildNuanceResultCard(
    BuildContext context,
    AIViewModel vm,
    AINuanceResponse result,
    double screenWidth,
    double screenHeight,
  ) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.045),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(screenWidth * 0.045),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_rounded, size: 16, color: AppColors.info),
                const SizedBox(width: 6),
                Text(
                  'LINGUISTIC & CULTURAL INSIGHTS',
                  style: GoogleFonts.outfit(
                    fontSize: (screenWidth * 0.028).clamp(11.0, 13.0),
                    fontWeight: FontWeight.bold,
                    color: AppColors.info,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: screenHeight * 0.015),

          // Why this wording was chosen
          Text(
            'Why This Wording:',
            style: GoogleFonts.outfit(
              fontSize: (screenWidth * 0.034).clamp(12.0, 14.0),
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: screenHeight * 0.004),
          Text(
            result.whyChosen,
            style: GoogleFonts.outfit(
              fontSize: (screenWidth * 0.035).clamp(13.0, 15.0),
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),

          SizedBox(height: screenHeight * 0.015),

          // Context of Use
          Text(
            'Context of Use:',
            style: GoogleFonts.outfit(
              fontSize: (screenWidth * 0.034).clamp(12.0, 14.0),
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: screenHeight * 0.004),
          Text(
            result.contextOfUse,
            style: GoogleFonts.outfit(
              fontSize: (screenWidth * 0.035).clamp(13.0, 15.0),
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),

          // Cultural Etiquette
          if (result.culturalEtiquette != null) ...[
            SizedBox(height: screenHeight * 0.015),
            Container(
              padding: EdgeInsets.all(screenWidth * 0.03),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(screenWidth * 0.03),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.public_rounded, size: 16, color: AppColors.warning),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      result.culturalEtiquette!,
                      style: GoogleFonts.outfit(
                        fontSize: (screenWidth * 0.032).clamp(12.0, 14.0),
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Alternatives
          if (result.alternatives.isNotEmpty) ...[
            SizedBox(height: screenHeight * 0.015),
            Text(
              'Regional Alternatives:',
              style: GoogleFonts.outfit(
                fontSize: (screenWidth * 0.032).clamp(11.0, 13.0),
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: screenHeight * 0.006),
            ...result.alternatives.map((alt) => Padding(
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.003),
                  child: Text(
                    '• $alt',
                    style: GoogleFonts.outfit(
                      fontSize: (screenWidth * 0.032).clamp(12.0, 14.0),
                      color: AppColors.textSecondary,
                    ),
                  ),
                )),
          ],
        ],
      ),
    );
  }

  // --- REUSABLE INPUT CARD ---
  Widget _buildInputCard({
    required TextEditingController controller,
    required String hintText,
    required String title,
    required double screenWidth,
    required double screenHeight,
  }) {
    return Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: screenWidth * 0.03,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.7,
                  color: AppColors.textSecondary,
                ),
              ),
              if (controller.text.isNotEmpty)
                GestureDetector(
                  onTap: () => controller.clear(),
                  child: Text(
                    'Clear',
                    style: GoogleFonts.outfit(
                      fontSize: screenWidth * 0.03,
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: screenHeight * 0.008),
          TextField(
            controller: controller,
            maxLines: 3,
            minLines: 2,
            style: GoogleFonts.outfit(
              fontSize: (screenWidth * 0.04).clamp(14.0, 16.0),
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.outfit(
                color: AppColors.textMuted,
                fontSize: (screenWidth * 0.036).clamp(13.0, 15.0),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String message, double screenWidth) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(screenWidth * 0.03),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: AppColors.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.outfit(
                fontSize: screenWidth * 0.032,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
