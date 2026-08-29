class LanguageModel {
  final String code;
  final String name;
  final String flag;
  final String nativeName;

  const LanguageModel({
    required this.code,
    required this.name,
    required this.flag,
    required this.nativeName,
  });

  static const List<LanguageModel> supportedLanguages = [
    LanguageModel(code: 'en', name: 'English', flag: '🇺🇸', nativeName: 'English'),
    LanguageModel(code: 'es', name: 'Spanish', flag: '🇪🇸', nativeName: 'Español'),
    LanguageModel(code: 'ar', name: 'Arabic', flag: '🇸🇦', nativeName: 'العربية'),
    LanguageModel(code: 'fr', name: 'French', flag: '🇫🇷', nativeName: 'Français'),
    LanguageModel(code: 'de', name: 'German', flag: '🇩🇪', nativeName: 'Deutsch'),
    LanguageModel(code: 'zh-cn', name: 'Chinese', flag: '🇨🇳', nativeName: '中文'),
    LanguageModel(code: 'hi', name: 'Hindi', flag: '🇮🇳', nativeName: 'हिन्दी'),
    LanguageModel(code: 'ur', name: 'Urdu', flag: '🇵🇰', nativeName: 'اردو'),
    LanguageModel(code: 'ja', name: 'Japanese', flag: '🇯🇵', nativeName: '日本語'),
    LanguageModel(code: 'ru', name: 'Russian', flag: '🇷🇺', nativeName: 'Русский'),
    LanguageModel(code: 'ko', name: 'Korean', flag: '🇰🇷', nativeName: '한국어'),
    LanguageModel(code: 'pt', name: 'Portuguese', flag: '🇵🇹', nativeName: 'Português'),
    LanguageModel(code: 'it', name: 'Italian', flag: '🇮🇹', nativeName: 'Italiano'),
    LanguageModel(code: 'tr', name: 'Turkish', flag: '🇹🇷', nativeName: 'Türkçe'),
    LanguageModel(code: 'id', name: 'Indonesian', flag: '🇮🇩', nativeName: 'Bahasa Indonesia'),
    LanguageModel(code: 'nl', name: 'Dutch', flag: '🇳🇱', nativeName: 'Nederlands'),
    LanguageModel(code: 'pl', name: 'Polish', flag: '🇵🇱', nativeName: 'Polski'),
    LanguageModel(code: 'sv', name: 'Swedish', flag: '🇸🇪', nativeName: 'Svenska'),
    LanguageModel(code: 'bn', name: 'Bengali', flag: '🇧🇩', nativeName: 'বাংলা'),
    LanguageModel(code: 'fa', name: 'Persian', flag: '🇮🇷', nativeName: 'فارسی'),
    LanguageModel(code: 'vi', name: 'Vietnamese', flag: '🇻🇳', nativeName: 'Tiếng Việt'),
    LanguageModel(code: 'th', name: 'Thai', flag: '🇹🇭', nativeName: 'ไทย'),
  ];

  static LanguageModel fromCode(String code) {
    return supportedLanguages.firstWhere(
      (lang) => lang.code == code || lang.code.startsWith(code),
      orElse: () => LanguageModel(code: code, name: code.toUpperCase(), flag: '🌐', nativeName: code),
    );
  }
}
