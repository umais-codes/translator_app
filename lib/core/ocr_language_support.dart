enum OcrScriptKind { latin, chinese, devanagari, japanese, korean, unsupported }

class OcrLanguageSupport {
  final OcrScriptKind kind;
  final String? unavailableMessage;

  const OcrLanguageSupport.supported(this.kind) : unavailableMessage = null;

  const OcrLanguageSupport.unsupported(String message)
    : kind = OcrScriptKind.unsupported,
      unavailableMessage = message;

  bool get isSupported => kind != OcrScriptKind.unsupported;

  static OcrLanguageSupport forCode(String code) {
    switch (code) {
      case 'zh-cn':
      case 'zh':
        return const OcrLanguageSupport.supported(OcrScriptKind.chinese);
      case 'ja':
        return const OcrLanguageSupport.supported(OcrScriptKind.japanese);
      case 'ko':
        return const OcrLanguageSupport.supported(OcrScriptKind.korean);
      case 'hi':
        return const OcrLanguageSupport.supported(OcrScriptKind.devanagari);
      case 'ar':
        return const OcrLanguageSupport.unsupported(
          'On-device text recognition cannot read Arabic. Switch the source language to a supported script, or type the text instead.',
        );
      case 'ur':
        return const OcrLanguageSupport.unsupported(
          'On-device text recognition cannot read Urdu. Switch the source language to a supported script, or type the text instead.',
        );
      case 'fa':
        return const OcrLanguageSupport.unsupported(
          'On-device text recognition cannot read Persian. Switch the source language to a supported script, or type the text instead.',
        );
      case 'bn':
        return const OcrLanguageSupport.unsupported(
          'On-device text recognition cannot read Bengali. Switch the source language to a supported script, or type the text instead.',
        );
      case 'th':
        return const OcrLanguageSupport.unsupported(
          'On-device text recognition cannot read Thai. Switch the source language to a supported script, or type the text instead.',
        );
      case 'ru':
        return const OcrLanguageSupport.unsupported(
          'On-device text recognition cannot read Cyrillic. Switch the source language to a supported script, or type the text instead.',
        );
      default:
        return const OcrLanguageSupport.supported(OcrScriptKind.latin);
    }
  }
}
